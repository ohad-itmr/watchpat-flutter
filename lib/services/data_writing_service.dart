import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/log/log.dart';
import 'package:rxdart/rxdart.dart';

class DataWritingService {
  static const String TAG = 'DataWritingService';

  SystemStateManager _systemState;
  static File _dataFile;
  static RandomAccessFile _raf;

  // remaining data receiving streams
  BehaviorSubject<int> _remainingDataSeconds = BehaviorSubject<int>();

  Observable<int> get remainingDataSecondsStream =>
      _remainingDataSeconds.stream;

  BehaviorSubject<double> _remainingDataProgress = BehaviorSubject<double>();

  Observable<double> get remainingDataProgressStream =>
      _remainingDataProgress.stream;

  int _remainingNecessaryPackets = 0;
  int _remainingReceivedPackets = 1;
  bool _testIsStopped = false;

  DataWritingService() {
    _systemState = sl<SystemStateManager>();
    _systemState.testStateStream.listen(_handleTestState);
    _systemState.deviceCommStateStream.listen(_handleDeviceState);
  }

  void _handleDeviceState(DeviceStates state) {
    switch (state) {
      case DeviceStates.CONNECTED:
        _initializeFileWriting();
        break;
      default:
    }
  }

  void _handleTestState(TestStates state) {
    switch (state) {
      case TestStates.STOPPED:
        startRemainingPacketsTimer();
        break;
      case TestStates.ENDED:
        _closeFileWriting();
        break;
      default:
    }
  }

  Future<void> _initializeFileWriting() async {
    Log.info(TAG, "Initializing data file for writing");
    _dataFile = await sl<FileSystemService>().localDataFile;
    _raf = await _dataFile.open(mode: FileMode.write);
  }

  void writeToLocalFile(List<int> bytes) {
    try {
      final int currentOffset = PrefsProvider.loadTestDataRecordingOffset();
      _raf.setPositionSync(currentOffset);
      _raf.writeFromSync(bytes);
      PrefsProvider.saveTestDataRecordingOffset(currentOffset + bytes.length);
      Log.info(TAG, "Data packet stored to local file");

      _reportRemainingDataProgress();
    } catch (e) {
      Log.shout(TAG, "Failed to store data packet to local file $e");
    }
  }

  void startRemainingPacketsTimer() {
    _testIsStopped = true;
    final int receivedPackets = PrefsProvider.loadTestPacketCount();
    final int necessaryPackets = PrefsProvider.loadTestElapsedTime() *
        (GlobalSettings.dataTransferRate ~/ 60);
    _remainingNecessaryPackets = necessaryPackets - receivedPackets;
  }

  void _reportRemainingDataProgress() {
    if (!_testIsStopped) return;

    _remainingReceivedPackets++;

    print(
        "REMAINING PACKETS: $_remainingReceivedPackets / $_remainingNecessaryPackets");

    final int deltaPackets =
        _remainingNecessaryPackets - _remainingReceivedPackets;
    final int secondsToFullData =
        deltaPackets ~/ (GlobalSettings.dataTransferRate ~/ 60);
    _remainingDataSeconds.sink
        .add(secondsToFullData > 0 ? secondsToFullData : 0);

    final double fullDataProgress =
        _remainingReceivedPackets / _remainingNecessaryPackets;
    _remainingDataProgress.sink.add(fullDataProgress);
  }

  void _closeFileWriting() async {
    _raf.close();
    _remainingDataProgress.close();
    _remainingDataSeconds.close();
  }
}

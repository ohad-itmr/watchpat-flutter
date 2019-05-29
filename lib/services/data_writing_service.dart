import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/log/log.dart';
import 'package:my_pat/utils/time_utils.dart';
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

  int _currentProgress;
  int _maxProgress;
  int _numberOfSecondsToDownloadAllPackets;

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
    Log.info(TAG, "Opening data file for writing");
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

    // calculate number of seconds left to download the data
    _numberOfSecondsToDownloadAllPackets = TimeUtils.getPacketRealTimeDiffSec();

    // when time is growing then there is no communication with device.
    // in this case update timer only and don't touch progress bar
    if (_numberOfSecondsToDownloadAllPackets < _maxProgress) {
      // time is decreasing, some packets has been transmitted so recalculate progress bar value now
      int changeDelta = _maxProgress - _numberOfSecondsToDownloadAllPackets;
      increaseProgress(changeDelta);
    } else {
      _maxProgress = _numberOfSecondsToDownloadAllPackets;
    }

//    _remainingReceivedPackets++;
//
//    print(
//        "REMAINING PACKETS: $_remainingReceivedPackets / $_remainingNecessaryPackets");
//
//
//
//    final int deltaPackets =
//        _remainingNecessaryPackets - _remainingReceivedPackets;
//    final int secondsToFullData =
//        deltaPackets ~/ (GlobalSettings.dataTransferRate ~/ 60);
//    _remainingDataSeconds.sink
//        .add(secondsToFullData > 0 ? secondsToFullData : 0);
//
//    final double fullDataProgress =
//        _remainingReceivedPackets / _remainingNecessaryPackets;
//    _remainingDataProgress.sink.add(fullDataProgress);
  }

  void increaseProgress(final int delta) {
    if (delta <= 0) {
      return;
    }

    Log.info(TAG, "increasing progress: $delta");

    int currentProgress = _remainingDataProgress.value.toInt();
    int currentMax = 1;

    // calculate new progress according to value
    double newProgress = currentProgress +
        ((currentMax - currentProgress) * delta /~ (_maxProgress - _currentProgress));

    _remainingDataProgress.sink.add(newProgress);
    _remainingDataSeconds.sink.add(_numberOfSecondsToDownloadAllPackets);

    _currentProgress += delta;
  }

  void _closeFileWriting() async {
    _raf.close();
    _remainingDataProgress.close();
    _remainingDataSeconds.close();
  }
}

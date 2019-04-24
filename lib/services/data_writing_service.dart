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
    final TestStates testState = await sl<SystemStateManager>().testStateStream.first;
    if (testState != TestStates.INTERRUPTED && testState != TestStates.RESUMED) {
      await PrefsProvider.saveTestDataRecordingOffset(0);
    }
  }

  void writeToLocalFile(List<int> bytes) {
    try {
      final int currentOffset = PrefsProvider.loadTestDataRecordingOffset();
      _raf.setPositionSync(currentOffset);
      _raf.writeFromSync(bytes);
      PrefsProvider.saveTestDataRecordingOffset(currentOffset + bytes.length);
      Log.info(TAG, "Data packet stored to local file");
    } catch (e) {
      Log.shout(TAG, "Failed to store data packet to local file $e");
    }
  }

  void _closeFileWriting() async {
      _raf.close();
  }
}

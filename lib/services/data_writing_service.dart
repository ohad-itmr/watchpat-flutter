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
  static IOSink _fileSink;

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
    Log.info(TAG, "Opening data file for writing");
    _dataFile = await sl<FileSystemService>().localDataFile;
    print("DATA FILE BEFORE RAF OPEN: ${_dataFile.lengthSync()}");
    _raf = await _dataFile.open(mode: FileMode.write);

    print("DATA FILE AFTER RAF OPEN: ${_dataFile.lengthSync()}");

    // todo debug
    _raf.closeSync();
    print("DATA FILE AFTER RAF CLOSE: ${_dataFile.lengthSync()}");
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

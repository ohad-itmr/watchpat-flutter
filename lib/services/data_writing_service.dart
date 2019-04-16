import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/log/log.dart';

class DataWritingService {
  static const String TAG = 'DataWritingService';

  ListQueue<List<int>> _queue = ListQueue();

  SystemStateManager _systemState;
  File _dataFile;
  IOSink _dataFileSink;
  bool _queueBeingProcessed = false;

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
      case DeviceStates.DISCONNECTED:
        _closeFileWriting();
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
    _dataFileSink = _dataFile.openWrite();
  }

  void enqueueWritingToFile(List<int> bytes) async {
    _queue.add(bytes);
    _processQueue();
  }

  void _processQueue() {
    if (_queueBeingProcessed) return;
    _queueBeingProcessed = true;
    while (_queue.isNotEmpty) {
      _dataFileSink.add(_queue.removeFirst());
    }
    _queueBeingProcessed = false;
  }

  void _closeFileWriting() async {
    if (_queue.isNotEmpty) {
      Future.delayed(Duration(seconds: 1));
      _closeFileWriting();
    } else {
      _dataFileSink.close();
    }
  }
}

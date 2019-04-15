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
  bool _queueIsProcessed = false;

  DataWritingService() {
    _systemState = sl<SystemStateManager>();
    _systemState.testStateStream.listen(_handleTestState);
  }

  void _handleTestState(TestStates state) {
    switch (state) {
      case TestStates.STARTED:
        _initializeFileWriting();
        break;
      case TestStates.ENDED:
        _closeFileWriting();
        break;
      default:
    }
  }

  Future<void> _initializeFileWriting() async {
    Log.info(TAG, "Initializing data file writing");
    _dataFile = await sl<FileSystemService>().localDataFile;
    _dataFileSink = _dataFile.openWrite();
  }

  void enqueueWritingToFile(List<int> bytes) async {
    _queue.add(bytes);
    _processQueue();
  }

  void _processQueue() {
    if (_queueIsProcessed) return;
    _queueIsProcessed = true;
    while (!_queue.isEmpty) {
      _dataFileSink.writeAll(_queue.removeFirst());
    }
    _queueIsProcessed = false;
  }

  void _closeFileWriting() async {
    _dataFileSink.close();
  }
}

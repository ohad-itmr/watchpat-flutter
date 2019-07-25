import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/log/log.dart';
import 'package:my_pat/utils/time_utils.dart';
import 'package:rxdart/rxdart.dart';

class DataWritingService {
  static const String TAG = 'DataWritingService';

  SystemStateManager _systemState;
  static File _dataFile;

  PublishSubject<List<int>> _data = PublishSubject<List<int>>();
  Observable<List<int>> get _dataStream => _data.stream;

  DataWritingService() {
    _systemState = sl<SystemStateManager>();
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

  Future<void> _initializeFileWriting() async {
    Log.info(TAG, "Opening data file for writing");
    _dataFile = await sl<FileSystemService>().localDataFile;

    _dataStream.asyncMap(_writeToLocalFileAsync).listen(null);
  }

  void writeToLocalFile(List<int> bytes) {
    _data.sink.add(List.from(bytes));
  }

  void _writeToLocalFileAsync(List<int> bytes) async {
    try {
      final int currentOffset = PrefsProvider.loadTestDataRecordingOffset();
      await _dataFile.writeAsBytes(bytes, mode: FileMode.append, flush: true);
      await PrefsProvider.saveTestDataRecordingOffset(currentOffset + bytes.length);
      Log.info(TAG, "Data packet stored to local file");
    } catch (e) {
      Log.shout(TAG, "Failed to store data packet to local file $e");
    }
  }
}

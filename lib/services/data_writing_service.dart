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
  }

  void writeToLocalFile(List<int> bytes) {
    try {
      final int currentOffset = PrefsProvider.loadTestDataRecordingOffset();
        RandomAccessFile raf = _dataFile.openSync(mode: FileMode.write);
        raf.setPositionSync(currentOffset);
        raf.writeFromSync(bytes);
        raf.close();
      PrefsProvider.saveTestDataRecordingOffset(currentOffset + bytes.length);
      Log.info(TAG, "Data packet stored to local file");
      print(_dataFile.readAsBytesSync());
    } catch (e) {
      Log.shout(TAG, "Failed to store data packet to local file $e");
    }
  }
}

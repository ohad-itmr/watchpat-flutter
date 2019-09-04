import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:my_pat/domain_model/received_packet.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/log/log.dart';
import 'package:my_pat/utils/time_utils.dart';
import 'package:rxdart/rxdart.dart';

class DataWritingService {
  static const String TAG = 'DataWritingService';

  SystemStateManager _systemState;
  static File _dataFile;

  PublishSubject<DataPacket> _data = PublishSubject<DataPacket>();
  Observable<DataPacket> get _dataStream => _data.stream;

  DataWritingService() {
    _systemState = sl<SystemStateManager>();
    _systemState.deviceCommStateStream.listen(_handleDeviceState);
    _dataStream.asyncMap(_writeToLocalFileAsync).listen(null);
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
    if (await _dataFile.exists()) {
      await PrefsProvider.saveTestDataRecordingOffset(await _dataFile.length());
    }
  }

  void writeToLocalFile(DataPacket packet) {
    _data.sink.add(packet);
    _data.sink.add(packet);
    _data.sink.add(packet);
    _data.sink.add(packet);
    _data.sink.add(packet);
    _data.sink.add(packet);
    _data.sink.add(packet);
    _data.sink.add(packet);
    _data.sink.add(packet);
  }

  void _writeToLocalFileAsync(DataPacket packet) async {
    try {
      final int currentOffset = PrefsProvider.loadTestDataRecordingOffset();
      await _dataFile.writeAsBytes(packet.data, mode: FileMode.append, flush: true);
      await PrefsProvider.saveTestDataRecordingOffset(currentOffset + packet.data.length);
      print("Data packet < ${packet.id} > stored to local file");
    } catch (e) {
      Log.shout(TAG, "Failed to store data packet to local file $e");
    }
  }
}

class DataPacket {
  final List<int> data;
  final int id;

  DataPacket({this.data, this.id});
}

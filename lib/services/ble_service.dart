import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/log/log.dart';
import 'package:hex/hex.dart';

class BleService {
  static const String TAG = 'BleService';

  static const String SERVICE_UID = '6e400001-b5a3-f393-e0a9-e50e24dcca9e';
  static const String TX_CHAR_UUID = '6e400003-b5a3-f393-e0a9-e50e24dcca9e';
  static const String RX_CHAR_UUID = '6e400002-b5a3-f393-e0a9-e50e24dcca9e';

  static const int SEND_COMMANDS_DELAY = 10;
  static const int SEND_ACK_DELAY = 2000;
  static const int MAX_COMMAND_TIMEOUT = 10000;

  FlutterBlue _flutterBlue = FlutterBlue.instance;
  BluetoothDevice _device;
  List<BluetoothService> _services = new List();
  BluetoothService _service;
  BluetoothCharacteristic _charForWrite;
  BluetoothCharacteristic _charForRead;

//  Map<Guid, StreamSubscription> _valueChangedSubscriptions = {};

  StreamSubscription _readCharSubscription;

  Future<BluetoothState> get btState => _flutterBlue.state;

  Stream<BluetoothState> get btStateOnChange => _flutterBlue.onStateChanged();

  Stream<ScanResult> scanForDevices(int time) {
    return _flutterBlue.scan(timeout: Duration(milliseconds: time));
  }

  Stream<BluetoothDeviceState> connect(BluetoothDevice d) {
    PrefsProvider.saveBluetoothDeviceID(d.id.toString());
    Log.info(TAG, '## Connection to device ${d.id}');
    _device = d;
    _flutterBlue.connect(_device).listen(null);
    return _device.onStateChanged();
  }

  Future<BluetoothDevice> restoreConnectedDevice(String deviceId) async {
    try {
      final BluetoothDevice d = await _flutterBlue.restoreConnectedDevice(deviceId);
      return d;
    } catch (e) {
      Log.shout(TAG, "Previously connected device is not present");
      return null;
    }
  }

  Future setServicesAndChars() async {
    await _device.discoverServices().then((List<BluetoothService> services) {
      _services = services;
      _services.forEach((ser) {
        if ((ser.uuid).toString() == BleService.SERVICE_UID) {
          _service = ser;
          _service.characteristics.forEach((char) {
            if ((char.uuid).toString() == BleService.RX_CHAR_UUID) {
              _charForWrite = char;
            }
            if ((char.uuid).toString() == BleService.TX_CHAR_UUID) {
              _charForRead = char;
            }
          });
        }
      });
      Log.info(TAG, "### services discovered");
    });
  }

  Future setNotification() async {
    Log.info(TAG, "setNotification");
    await _device.setNotifyValue(_charForRead, false);
    await _device.setNotifyValue(_charForRead, true);
    if (_readCharSubscription == null) {
      _readCharSubscription = _device.onValueChanged(_charForRead).listen(_handleData);
    } else {
      _readCharSubscription.cancel();
      _readCharSubscription = _device.onValueChanged(_charForRead).listen(_handleData);
    }
  }

  void _handleData(List<int> data) {
    sl<IncomingPacketHandlerService>().acceptAndHandleData(data);
  }

  void clearDevice() {
    _device = null;
    if (_readCharSubscription != null) {
      _readCharSubscription.cancel();
    }
    _readCharSubscription = null;
  }

  Future<void> writeCharacteristic(List<int> data, bool ensureSuccess) async {
    var status = ensureSuccess ? 'success' : 'unknown';
    try {
      await _device
          .writeCharacteristic(
            _charForWrite,
            data,
            type: ensureSuccess
                ? CharacteristicWriteType.withResponse
                : CharacteristicWriteType.withoutResponse,
          )
          .timeout(Duration(milliseconds: 200),
              onTimeout: () => throw Exception('Characteristic writing timeout'));
      await Future.delayed(Duration(milliseconds: 2));
    } catch (e) {
      status = 'failure ${e.toString()}';
    }
    Log.info(TAG, "Writing TX characteristic ${HEX.encode(data)}, status: $status");
    print("Writing TX characteristic $data, status: $status");
  }
}

import 'dart:async';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:meta/meta.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/log/log.dart';

class BleService {
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

  Map<Guid, StreamSubscription> _valueChangedSubscriptions = {};

  Future<BluetoothState> get btState => _flutterBlue.state;

  Stream<BluetoothState> get btStateOnChange => _flutterBlue.onStateChanged();

  Stream<ScanResult> scanForDevices({int time, @required bool connectToFirstDevice}) {
    return _flutterBlue.scan(timeout: time != null ? Duration(seconds: time) : null);
  }

  Stream<BluetoothDeviceState> connect(BluetoothDevice d) {
    Log.info('## Connection to device ${d.id}');
    _device = d;
    _flutterBlue
        .connect(
          _device,
        )
        .listen(
          null,
//          onDone: _disconnect,
        );
    return _device.onStateChanged();
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
      Log.info("### services discovered");
    });
  }

  Future setNotification(IncomingPacketHandlerService notificationHandler) async {
    Log.info("setNotification");

    if (_charForRead.isNotifying) {
      await _device.setNotifyValue(_charForRead, false);
      // Cancel subscription
      _valueChangedSubscriptions[_charForRead.uuid]?.cancel();
      _valueChangedSubscriptions.remove(_charForRead.uuid);
    } else {
      await _device.setNotifyValue(_charForRead, true);
      // ignore: cancel_subscriptions
      final sub = _device.onValueChanged(_charForRead).listen((data) {
        notificationHandler.acceptAndHandleData(data);
      });
      // Add to map
      _valueChangedSubscriptions[_charForRead.uuid] = sub;
    }
  }

  void disconnect() {
    _valueChangedSubscriptions.forEach((uuid, sub) => sub.cancel());
    _valueChangedSubscriptions.clear();
    _device = null;
  }

  Future<void> writeCharacteristic(List<int> data) async {
    Log.info("Start writing TX characteristic: ${data.toString()}");

    var status = 'success';
    try {
      await _device.writeCharacteristic(
        _charForWrite,
        data,
        type: CharacteristicWriteType.withoutResponse,
      );
    } catch (e) {
      status = 'failure';
    }

    Log.info("Finish writing TX characteristic: ${data.toString()} $status");
  }
}

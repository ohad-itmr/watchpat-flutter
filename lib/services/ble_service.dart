import 'dart:async';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/log/log.dart';

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
    return _flutterBlue.scan(
        timeout: time != null ? Duration(milliseconds: time) : null);
  }

  Stream<BluetoothDeviceState> connect(BluetoothDevice d) {
    Log.info(TAG, '## Connection to device ${d.id}');
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
      Log.info(TAG, "### services discovered");
    });
  }

  Future setNotification(
      IncomingPacketHandlerService notificationHandler) async {
    Log.info(TAG, "setNotification");

    if (_charForRead.isNotifying) {
      await _device.setNotifyValue(_charForRead, false);
    }
    await _device.setNotifyValue(_charForRead, true);
    _readCharSubscription = _device.onValueChanged(_charForRead).listen((data) {
      notificationHandler.acceptAndHandleData(data);
    });
  }

  void clearSubscriptions() {
    _readCharSubscription.cancel();
  }

  void disconnect() {
    _device = null;
    _readCharSubscription.cancel();
  }

  Future<void> writeCharacteristic(List<int> data) async {
    var status = 'success';
    try {
      await _device.writeCharacteristic(
        _charForWrite,
        data,
        type: CharacteristicWriteType.withoutResponse,
      );
    } catch (e) {
      status = 'failure ${e.toString()}';
    }
    Log.info(
        TAG, "Writing TX characteristic: ${data.toString()} $status");
  }
}

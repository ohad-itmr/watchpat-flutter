import 'dart:async';

import 'package:meta/meta.dart';
import 'package:my_pat/utility/log/log.dart';
import 'package:rxdart/rxdart.dart';
import 'package:my_pat/bloc/helpers/bloc_base.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:my_pat/api/ble_provider.dart';
import 'package:my_pat/generated/i18n.dart';

enum ScanState { NOT_STARTED, SCANNING, COMPLETE }

enum ScanResultSate { NOT_FOUND, FOUND_SINGLE, FOUND_MULTIPLE }

class BleBloc extends BlocBase {
  S lang;

  BleProvider _bleProvider = BleProvider();

  FlutterBlue _flutterBlue;

  //#region Scanning
  StreamSubscription _scanSubscription;

  BehaviorSubject<Map<DeviceIdentifier, ScanResult>> _scanResultsSubject =
      BehaviorSubject<Map<DeviceIdentifier, ScanResult>>();

  BehaviorSubject<ScanResultSate> _scanResultStateSubject =
      BehaviorSubject<ScanResultSate>();

  Observable<Map<DeviceIdentifier, ScanResult>> get scanResults =>
      _scanResultsSubject.stream;

  BehaviorSubject<ScanState> _scanStateSubject = BehaviorSubject<ScanState>();

  Observable<ScanState> get scanState => _scanStateSubject.stream;

  Observable<ScanResultSate> get scanResultState => _scanResultStateSubject.stream;

  Sink<ScanResultSate> get changeScanResultState => _scanResultStateSubject.sink;

  int get scanResultsLength => _scanResultsSubject.value.length;

  //#endregion Scanning

  //#region States
  PublishSubject<BluetoothState> _bleStateSubject = PublishSubject<BluetoothState>();

  Observable<BluetoothState> get bleState => _bleStateSubject.stream;

  BehaviorSubject<BluetoothDeviceState> _deviceStateSubject =
      BehaviorSubject<BluetoothDeviceState>();

  Observable<BluetoothDeviceState> get deviceState => _deviceStateSubject.stream;

  //#endregion States

  //#region Device
  BehaviorSubject<BluetoothDevice> _deviceSubject = BehaviorSubject<BluetoothDevice>();

  Observable<BluetoothDevice> get device => _deviceSubject.stream;

  //#endregion Device

  //#region Services and Characteristics
  BehaviorSubject<List<BluetoothService>> _servicesSubject =
      BehaviorSubject<List<BluetoothService>>();

  Observable<List<BluetoothService>> get services => _servicesSubject.stream;

  BehaviorSubject<BluetoothService> _serviceSubject = BehaviorSubject<BluetoothService>();

  Observable<BluetoothService> get service => _serviceSubject.stream;

  BehaviorSubject<BluetoothCharacteristic> _charForWriteSubject =
      BehaviorSubject<BluetoothCharacteristic>();

  Observable<BluetoothCharacteristic> get charForWrite => _charForWriteSubject.stream;

  BehaviorSubject<BluetoothCharacteristic> _charForReadSubject =
      BehaviorSubject<BluetoothCharacteristic>();

  Observable<BluetoothCharacteristic> get charForRead => _charForReadSubject.stream;

  //#endregion Services and Characteristics

  startScan({int time, @required bool connectToFirstDevice}) {
    Log.info('## START SCAN $this');
    _scanStateSubject.sink.add(ScanState.SCANNING);

    _scanResultsSubject.sink.add(Map());
    _scanSubscription = _flutterBlue
        .scan(timeout: time != null ? Duration(seconds: time) : null)
        .listen((scanResult) {
      if (scanResult.advertisementData.localName == 'ITAMAR_UART') {
        Log.info('## FOUND DEVICE $this');

        if (connectToFirstDevice) {
          stopScan();
          // TODO connect to device
        } else {
          var currentResults = _scanResultsSubject.value;
          currentResults[scanResult.device.id] = scanResult;
        }
      }
    }, onDone: stopScan);
  }

  stopScan() {
    Log.info('## STOP SCAN $this');
    _scanSubscription?.cancel();
    _scanSubscription = null;

    _scanStateSubject.sink.add(ScanState.COMPLETE);
  }

  BleBloc(s) {
    lang = s;
    _scanStateSubject.sink.add(ScanState.NOT_STARTED);
    _flutterBlue = _bleProvider.flutterBlue;
    _flutterBlue.onStateChanged().listen((BluetoothState s) {
      _bleStateSubject.sink.add(s);
    });

    _flutterBlue.state.then((BluetoothState s) {
      _bleStateSubject.sink.add(s);
    });
  }

  @override
  void dispose() {
    _deviceSubject.close();
    _scanStateSubject.close();
    _scanResultsSubject.close();
    _servicesSubject.close();
    _deviceStateSubject.close();
    _serviceSubject.close();
    _charForWriteSubject.close();
    _charForReadSubject.close();
    _bleStateSubject.close();
    _scanResultStateSubject.close();
  }
}

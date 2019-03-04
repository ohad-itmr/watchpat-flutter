import 'package:rxdart/rxdart.dart';
import 'package:my_pat/bloc/helpers/bloc_base.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:my_pat/api/ble_provider.dart';
import 'package:my_pat/generated/i18n.dart';

class BleBloc extends BlocBase {
  S lang;

  BleProvider provider=bleProvider;

  FlutterBlue _flutterBlue;

  //#region Scanning
  BehaviorSubject<Map<DeviceIdentifier, ScanResult>> _scanResultsSubject =
      BehaviorSubject<Map<DeviceIdentifier, ScanResult>>();

  Observable<Map<DeviceIdentifier, ScanResult>> get scanResults =>
      _scanResultsSubject.stream;

  BehaviorSubject<bool> _scanStateSubject = BehaviorSubject<bool>();

  Observable<bool> get isScanning => _scanStateSubject.stream;

  //#endregion Scanning

  //#region States
  BehaviorSubject<BluetoothState> _stateSubject = BehaviorSubject<BluetoothState>();

  Observable<BluetoothState> get state => _stateSubject.stream;

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

  Map<String, dynamic> message;

  BleBloc(s) {
    lang = s;
    _flutterBlue = bleProvider.flutterBlue;

    _flutterBlue.onStateChanged().listen((BluetoothState s) => _stateSubject.add(s));

    _flutterBlue.state.then((BluetoothState s) {
      _stateSubject.add(s);
    });
  }

  @override
  void dispose() {
    _deviceSubject.close();
    _stateSubject.close();
    _scanStateSubject.close();
    _scanResultsSubject.close();
    _servicesSubject.close();
    _deviceStateSubject.close();
    _serviceSubject.close();
    _charForWriteSubject.close();
    _charForReadSubject.close();
  }
}

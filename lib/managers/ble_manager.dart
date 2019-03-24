import 'dart:async';
import 'package:meta/meta.dart';
import 'package:my_pat/domain_model/device_commands.dart';
import 'package:my_pat/managers/managers.dart';
import 'package:my_pat/utils/log/log.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:my_pat/service_locator.dart';

class BleManager extends ManagerBase {
  S lang;

  BleService _bleProvider = BleService();
  IncomingPacketHandlerService _incomingPacketHandler;

  FlutterBlue _flutterBlue;

  BluetoothDevice _device;
  List<BluetoothService> _services = new List();
  BluetoothService _service;
  BluetoothCharacteristic _charForWrite;
  BluetoothCharacteristic _charForRead;
  Map<Guid, StreamSubscription> _valueChangedSubscriptions = {};

  //#region Scanning
  StreamSubscription _scanSubscription;
  StreamSubscription deviceStateSubscription;

  BehaviorSubject<Map<DeviceIdentifier, ScanResult>> _scanResultsSubject =
      BehaviorSubject<Map<DeviceIdentifier, ScanResult>>();

  Observable<Map<DeviceIdentifier, ScanResult>> get scanResults =>
      _scanResultsSubject.stream;

  int get scanResultsLength => _scanResultsSubject.value.length;

  String get tag => Trace.from(StackTrace.current).terse.toString();

  //#endregion Scanning

  //#region States
  PublishSubject<BluetoothState> _bleStateSubject = PublishSubject<BluetoothState>();

  Observable<BluetoothState> get bleState => _bleStateSubject.stream;

  //#endregion States

  //#region Device
  StreamSubscription _deviceConnection;
  BehaviorSubject<BluetoothDeviceState> _deviceStateSubject =
      BehaviorSubject<BluetoothDeviceState>();

  Observable<BluetoothDeviceState> get deviceState => _deviceStateSubject.stream;

  //#endregion Device

  BleManager() {
    lang = sl<S>();

    _incomingPacketHandler = sl<IncomingPacketHandlerService>();
    _initTasker();
    initializeBT();
  }

  void _btStateHandler(BluetoothState s) {
    switch (s) {
      case BluetoothState.unknown:
      case BluetoothState.unavailable:
      case BluetoothState.off:
        sl<SystemStateManager>().setBtState(BtStates.NOT_AVAILABLE);
        break;
      default:
        sl<SystemStateManager>().setBtState(BtStates.ENABLED);
        break;
    }
    _bleStateSubject.sink.add(s);
  }

  void connect(BluetoothDevice d) async {
    Log.info('## Connection to device ${d.id}');
    _device = d;
    // Connect to device
    _deviceConnection = _flutterBlue
        .connect(
          _device,
        )
        .listen(
          null,
//          onDone: _disconnect,
        );

    // Update the connection state immediately
//    _device.state.then(_deviceConnectionStateHandler);

    // Subscribe to connection changes
    deviceStateSubscription =
        _device.onStateChanged().listen(_deviceConnectionStateHandler);
  }

  void _deviceConnectionStateHandler(BluetoothDeviceState state) {
    Log.info('## Device State Changed to $state');
    _deviceStateSubject.sink.add(state);

    if (state == BluetoothDeviceState.connected) {
      Log.info("### connected to device: ${_device.name}");
      Log.info("### starting services discovery");
      sl<SystemStateManager>().setDeviceCommState(DeviceStates.CONNECTED);

      _device.discoverServices().then((List<BluetoothService> services) {
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
        _setNotification();
        _sendStartSession(DeviceCommands.SESSION_START_USE_TYPE_PATIENT);
        if (PrefsProvider.getIsFirstDeviceConnection() != null &&
            PrefsProvider.getIsFirstDeviceConnection()) {
          sl<SystemStateManager>().setFirmwareState(FirmwareUpgradeStates.UNKNOWN);
        }
      });
    } else if (state == BluetoothDeviceState.disconnected) {
      Log.info("disconnected from device");
      _incomingPacketHandler.resetPacket();
      _disconnect();
      if (sl<SystemStateManager>().isBTEnabled) {
        if (sl<SystemStateManager>().isScanCycleEnabled) {
          startScan(connectToFirstDevice: false);
        }
      } else {
        Log.shout("BT not enabled scan cycle not initiated $tag");
      }
    }
  }

  void _disconnect() {
    // Remove all value changed listeners
    Log.info('Remove all value changed listeners');
    _valueChangedSubscriptions.forEach((uuid, sub) => sub.cancel());
    _valueChangedSubscriptions.clear();
    deviceStateSubscription?.cancel();
    deviceStateSubscription = null;
    _deviceConnection?.cancel();
    _deviceConnection = null;
    _device = null;
  }

  void _initTasker() {
    sl<SystemStateManager>().stateChangeStream.listen(_systemStateHandler);

    sl<CommandTaskerManager>().setDelays(BleService.SEND_COMMANDS_DELAY, BleService.SEND_ACK_DELAY,
        BleService.MAX_COMMAND_TIMEOUT);
    sl<CommandTaskerManager>().ackOpCode = DeviceCommands.CMD_OPCODE_ACK;
    sl<CommandTaskerManager>().sendCmdCallback = _sendCallback;
    sl<CommandTaskerManager>().timeoutCallback = _sendTimeoutCallback;
  }

  Future<dynamic> _sendCallback(CommandTaskerItem command) {
    Log.info('_sendCallback $tag');
    try {
      if (sl<SystemStateManager>().deviceCommState == DeviceStates.CONNECTED) {
//        _sendCommand(command.data);
        return _sendCommand(command.data);
      } else {
        Log.warning("device disconnected, command not sent ");
      }
    } catch (e) {
      Log.shout('$e $tag');
    }
    return null;
  }

  _sendTimeoutCallback() {
    Log.info(">>> CommandTasker timeout");
    _disconnect();
    if (sl<SystemStateManager>().isBTEnabled) {
      if (sl<SystemStateManager>().isScanCycleEnabled) {
        startScan(connectToFirstDevice: false);
      }
    } else {
      Log.warning("BT not enabled scan cycle not initiated");
    }
  }

  void initializeBT() {
    Log.info("initializing BT");
    _flutterBlue = _bleProvider.flutterBlue;
    _flutterBlue.onStateChanged().listen(_btStateHandler);
    _flutterBlue.state.then(_btStateHandler);
  }

  bool _preScanChecks() {
    Log.info("performing pre-scan checks");
    if (!sl<SystemStateManager>().isBTEnabled) {
      Log.warning("[preScanChecks] BT disabled, LE scan canceled");
      return false;
    }

    if (sl<SystemStateManager>().bleScanResult == ScanResultStates.LOCATED_SINGLE) {
      Log.warning("[preScanChecks] device already located");
      return false;
    }

    if (sl<SystemStateManager>().isConnectionToDevice) {
      Log.warning("[preScanChecks] connection to device already in progress");
      return false;
    }

    return true;
  }

  void _postScan() {
    sl<SystemStateManager>().setBleScanState(ScanStates.COMPLETE);
    final Map<DeviceIdentifier, ScanResult> _discoveredDevices =
        _scanResultsSubject.value;
    Log.info('Discovered ${_discoveredDevices.length} devices');
    if (_discoveredDevices.isEmpty) {
      Log.info("no device discovered on scan");
      sl<SystemStateManager>().setBleScanResult(ScanResultStates.NOT_LOCATED);
    } else if (_discoveredDevices.length == 1) {
      Log.info("discovered a SINGLE device on scan");
      sl<SystemStateManager>().setBleScanResult(ScanResultStates.LOCATED_SINGLE);
      sl<SystemStateManager>().setDeviceCommState(DeviceStates.CONNECTING);
      connect(_discoveredDevices.values.toList()[0].device);
    } else {
      Log.info("discovered MULTIPLE devices on scan");
      sl<SystemStateManager>().setBleScanResult(ScanResultStates.LOCATED_MULTIPLE);
    }
  }

  void _setNotification() async {
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
        _incomingPacketHandler.acceptAndHandleData(data);
      });
      // Add to map
      _valueChangedSubscriptions[_charForRead.uuid] = sub;
    }
  }

  _sendCommand(List<List<int>> byteList) async {
    Log.info("### _sendCommand $tag");

    if (byteList != null) {
      try {
        List<Future<void>> futures = [];
        for (var req in byteList) {
          print('Subrequest $req');
          futures.add(writeCharacteristic(req));
        }
        await Future.wait(futures);
      } catch (e) {
        Log.shout("sendCommand exception: ${e.toString()} $tag");
      }
    } else {
      Log.shout("sendCommand failed: byteList is null $tag");
    }
  }

  void _sendStartSession(int useType) {
    Log.info("### sending start session $tag");
    sl<CommandTaskerManager>().addCommandWithNoCb(
        DeviceCommands.getStartSessionCmd(0x0000, useType, [0, 0, 0, 1]));
  }

  void startScan({int time, @required bool connectToFirstDevice}) {
    Log.info('## START SCAN');
    if (!_preScanChecks()) {
      return;
    }

    _scanResultsSubject.sink.add(Map());
    sl<SystemStateManager>().setBleScanState(ScanStates.SCANNING);
    _scanSubscription =
        _flutterBlue.scan(timeout: time != null ? Duration(seconds: time) : null).listen(
      (scanResult) {
        final String name = scanResult.advertisementData.localName;
        print('Found $name ${scanResult.device.id}');
        if (name.contains('ITAMAR')) {
          Log.info(
              ">>> name on scan: $name | name local: ${PrefsProvider.loadDeviceName()}");

          Log.info('## FOUND DEVICE ${scanResult.device.id}');
          var currentResults = _scanResultsSubject.value;
          currentResults[scanResult.device.id] = scanResult;

          _scanResultsSubject.sink.add(currentResults);
          if (connectToFirstDevice) {
            stopScan();
            return;
          }
        }
      },
      onDone: stopScan,
    );
  }

  void stopScan() {
    Log.info('## STOP SCAN $this');
    _scanSubscription?.cancel();
    _scanSubscription = null;
    _postScan();
  }

  void _systemStateHandler(StateChangeActions action) {
    switch (action) {
      case StateChangeActions.TEST_STATE_CHANGED:
        final TestStates testState = sl<SystemStateManager>().testState;
        if (testState == TestStates.STARTED) {
          sl<CommandTaskerManager>().addCommandWithNoCb(DeviceCommands.getStartAcquisitionCmd());
          _incomingPacketHandler.startPacketAnalysis();
        }
        break;
      case StateChangeActions.APP_MODE_CHANGED:
        final AppModes mode = sl<SystemStateManager>().appMode;
        Log.info("receiverAppMode: " + SystemStateManager.getAppModeName(mode.index));
        switch (mode) {
          case AppModes.USER:
            Log.info("### sending start session");
            // todo add real SW ID
            sl<CommandTaskerManager>().addCommandWithNoCb(DeviceCommands.getStartSessionCmd(
                0x0000, DeviceCommands.SESSION_START_USE_TYPE_PATIENT, [0, 0, 0, 1]));
            break;
          case AppModes.CS:
            Future.delayed(Duration(milliseconds: 2000), () {
              if (sl<SystemStateManager>().appMode != AppModes.TECH) {
                // todo add real SW ID
                sl<CommandTaskerManager>().addCommandWithNoCb(DeviceCommands.getStartSessionCmd(
                    0x0000, DeviceCommands.SESSION_START_USE_TYPE_SERVICE, [0, 0, 0, 1]));
              }
            });
            break;
          default:
            break;
        }
        break;
      default:
        break;
    }
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

  @override
  void dispose() {
    _scanResultsSubject.close();
    _deviceStateSubject.close();
    _bleStateSubject.close();
    _deviceStateSubject.close();
    _deviceConnection.cancel();
    deviceStateSubscription.cancel();
  }
}

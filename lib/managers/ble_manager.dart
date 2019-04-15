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
  static const String TAG = 'BleManager';

  S lang;

  IncomingPacketHandlerService _incomingPacketHandler;

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

  //#endregion States

  //#region Device
  StreamSubscription _deviceConnection;
  BehaviorSubject<BluetoothDeviceState> _deviceStateSubject =
      BehaviorSubject<BluetoothDeviceState>();

  Observable<BluetoothDeviceState> get deviceState =>
      _deviceStateSubject.stream;

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
  }

  void connect(BluetoothDevice d) {
    sl<BleService>().connect(d).listen(_deviceConnectionStateHandler);
  }

  void _deviceConnectionStateHandler(BluetoothDeviceState state) async {
    Log.info(TAG, '## Device State Changed to $state');
    _deviceStateSubject.sink.add(state);

    final sysStateManager = sl<SystemStateManager>();

    if (state == BluetoothDeviceState.connected) {
      Log.info(TAG, "### connected to device");
      sysStateManager.setDeviceCommState(DeviceStates.CONNECTED);

      Log.info(TAG, "### starting services discovery");
      await sl<BleService>().setServicesAndChars();
      await sl<BleService>().setNotification(_incomingPacketHandler);

      if (sysStateManager.testState == TestStates.INTERRUPTED) {
        Log.info(TAG, '### Successfully reconnected to device');
        sysStateManager.setTestState(TestStates.RESUMED);
        return;
      }

      _sendStartSession(DeviceCommands.SESSION_START_USE_TYPE_PATIENT);
      if (PrefsProvider.getIsFirstDeviceConnection() != null &&
          PrefsProvider.getIsFirstDeviceConnection()) {
        sysStateManager
            .setFirmwareState(FirmwareUpgradeStates.UNKNOWN);
      }
    } else if (state == BluetoothDeviceState.disconnected) {
      Log.info(TAG, "disconnected from device");
      sysStateManager.setDeviceCommState(DeviceStates.DISCONNECTED);
      if (sysStateManager.testState == TestStates.STARTED || sysStateManager.testState == TestStates.RESUMED) {
        sysStateManager.setTestState(TestStates.INTERRUPTED);
        sysStateManager.changeState.add(StateChangeActions.TEST_STATE_CHANGED);
      } else {
        _incomingPacketHandler.resetPacket();
        _disconnect();
        if (sysStateManager.isBTEnabled) {
          if (sysStateManager.isScanCycleEnabled) {
            startScan(connectToFirstDevice: false);
          }
        } else {
          Log.shout(TAG, "BT not enabled scan cycle not initiated $tag");
        }
      }
    }
  }

  void _disconnect() {
    Log.info(TAG, 'Remove all value changed listeners');
    deviceStateSubscription?.cancel();
    deviceStateSubscription = null;
    _deviceConnection?.cancel();
    sl<BleService>().disconnect();
  }

  void initializeBT() {
    Log.info(TAG, "initializing BT");
    sl<BleService>().btStateOnChange.listen(_btStateHandler);
    sl<BleService>().btState.then(_btStateHandler);
  }

  void _initTasker() {
    sl<SystemStateManager>().stateChangeStream.listen(_systemStateHandler);
    sl<CommandTaskerManager>().setDelays(BleService.SEND_COMMANDS_DELAY,
        BleService.SEND_ACK_DELAY, BleService.MAX_COMMAND_TIMEOUT);
    sl<CommandTaskerManager>().ackOpCode = DeviceCommands.CMD_OPCODE_ACK;
    sl<CommandTaskerManager>().sendCmdCallback = _sendCallback;
    sl<CommandTaskerManager>().timeoutCallback = _sendTimeoutCallback;
  }

  bool _preScanChecks() {
    Log.info(TAG, "performing pre-scan checks");
    if (!sl<SystemStateManager>().isBTEnabled) {
      Log.warning(TAG, "[preScanChecks] BT disabled, LE scan canceled");
      return false;
    }

    if (sl<SystemStateManager>().bleScanResult ==
            ScanResultStates.LOCATED_SINGLE &&
        sl<SystemStateManager>().testState != TestStates.INTERRUPTED) {
      Log.warning(TAG, "[preScanChecks] device already located");
      return false;
    }

    if (sl<SystemStateManager>().isConnectionToDevice) {
      Log.warning(
          TAG, "[preScanChecks] connection to device already in progress");
      return false;
    }

    return true;
  }

  void _postScan() {
    sl<SystemStateManager>().setBleScanState(ScanStates.COMPLETE);
    final Map<DeviceIdentifier, ScanResult> _discoveredDevices =
        _scanResultsSubject.value;
    Log.info(TAG, 'Discovered ${_discoveredDevices.length} devices');
    if (_discoveredDevices.isEmpty) {
      Log.info(TAG, "no device discovered on scan");
      sl<SystemStateManager>().setBleScanResult(ScanResultStates.NOT_LOCATED);
    } else if (_discoveredDevices.length == 1) {
      Log.info(TAG, "discovered a SINGLE device on scan");
      sl<SystemStateManager>()
          .setBleScanResult(ScanResultStates.LOCATED_SINGLE);
      sl<SystemStateManager>().setDeviceCommState(DeviceStates.CONNECTING);
//
      connect(_discoveredDevices.values.toList()[0].device);
    } else {
      Log.info(TAG, "discovered MULTIPLE devices on scan");
      sl<SystemStateManager>()
          .setBleScanResult(ScanResultStates.LOCATED_MULTIPLE);
    }
  }

  Future<dynamic> _sendCallback(CommandTaskerItem command) {
    Log.info(TAG, '_sendCallback ');
    try {
      if (sl<SystemStateManager>().deviceCommState == DeviceStates.CONNECTED) {
        return _sendCommand(command.data);
      } else {
        Log.warning(TAG, "device disconnected, command not sent ");
      }
    } catch (e) {
      Log.shout(TAG, '$e $tag', e);
    }
    return null;
  }

  _sendTimeoutCallback() {
    Log.info(TAG, ">>> CommandTasker timeout");
    _disconnect();
    if (sl<SystemStateManager>().isBTEnabled) {
      if (sl<SystemStateManager>().isScanCycleEnabled) {
        startScan(connectToFirstDevice: false);
      }
    } else {
      Log.warning(TAG, "BT not enabled scan cycle not initiated");
    }
  }

  _sendCommand(List<List<int>> byteList) async {
    Log.info(TAG, "### _sendCommand ");

    if (byteList != null) {
      for (var req in byteList) {
        await sl<BleService>().writeCharacteristic(req);
      }
    } else {
      Log.shout(TAG, "sendCommand failed: byteList is null $tag");
    }
  }

  void _sendStartSession(int useType) {
    Log.info(TAG, "### sending start session ");
    sl<CommandTaskerManager>().addCommandWithNoCb(
        DeviceCommands.getStartSessionCmd(0x0000, useType, [0, 0, 0, 1]));
  }

  void startScan(
      {int time, @required bool connectToFirstDevice, String deviceName}) {
    Log.info(TAG, '## START SCAN');

    if (!_preScanChecks()) {
      return;
    }

    _scanResultsSubject.sink.add(Map());
    sl<SystemStateManager>().setBleScanState(ScanStates.SCANNING);
    _scanSubscription = sl<BleService>().scanForDevices(time).listen(
          (scanResult) => _scanResultHandler(
                scanResult,
                connectToFirstDevice,
                deviceName: deviceName,
              ),
          onDone: stopScan,
        );
  }

  void _scanResultHandler(ScanResult scanResult, bool connectToFirstDevice,
      {String deviceName}) {
    final String name = scanResult.advertisementData.localName;
    // Commented for the purpose of not pissing the developer off
    //    print('Found $name');
    //    print('Found ID ${scanResult.device.id}');

    if (deviceName != null) {
      // todo add implementation

    } else {
      if (name.contains('ITAMAR')) {
        Log.info(TAG,
            ">>> name on scan: $name | name local: ${PrefsProvider.loadDeviceName()}");

        Log.info(TAG, '## FOUND DEVICE ${scanResult.device.id}');
        var currentResults = _scanResultsSubject.value;
        currentResults[scanResult.device.id] = scanResult;

        _scanResultsSubject.sink.add(currentResults);
        if (connectToFirstDevice) {
          stopScan();
          return;
        }
      }
    }
  }

  void stopScan() {
    Log.info(TAG, '## STOP SCAN $this');
    _scanSubscription?.cancel();
    _scanSubscription = null;

    _postScan();
  }

  void _systemStateHandler(StateChangeActions action) {
    switch (action) {
      case StateChangeActions.TEST_STATE_CHANGED:
        final TestStates testState = sl<SystemStateManager>().testState;
        if (testState == TestStates.STARTED) {
          sl<CommandTaskerManager>()
              .addCommandWithNoCb(DeviceCommands.getStartAcquisitionCmd());
          _incomingPacketHandler.startPacketAnalysis();
        } else if (testState == TestStates.INTERRUPTED) {
          Log.shout(TAG, "Test interrupted because of device connection lost");
          sl<BleService>().clearSubscriptions();
        }
        break;
      case StateChangeActions.APP_MODE_CHANGED:
        final AppModes mode = sl<SystemStateManager>().appMode;
        Log.info(
            TAG,
            "receiverAppMode: " +
                SystemStateManager.getAppModeName(mode.index));
        switch (mode) {
          case AppModes.USER:
            Log.info(TAG, "### sending start session");
            // todo add real SW ID
            sl<CommandTaskerManager>()
                .addCommandWithNoCb(DeviceCommands.getStartSessionCmd(
              0x0000,
              DeviceCommands.SESSION_START_USE_TYPE_PATIENT,
              [0, 0, 0, 1],
            ));
            break;
          case AppModes.CS:
            Future.delayed(Duration(milliseconds: 2000), () {
              if (sl<SystemStateManager>().appMode != AppModes.TECH) {
                // todo add real SW ID
                sl<CommandTaskerManager>().addCommandWithNoCb(
                    DeviceCommands.getStartSessionCmd(
                        0x0000,
                        DeviceCommands.SESSION_START_USE_TYPE_SERVICE,
                        [0, 0, 0, 1]));
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

  @override
  void dispose() {
    _scanResultsSubject.close();
    _deviceStateSubject.close();
    _deviceStateSubject.close();
    _deviceConnection.cancel();
    deviceStateSubscription.cancel();
  }
}

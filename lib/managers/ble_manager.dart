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

  bool _isFirstConnection = true;

  String _deviceAdvName;

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

  Timer _testInterruptedTimer;
  bool _scanInProgress = false;

  BleManager() {
    lang = sl<S>();
    _incomingPacketHandler = sl<IncomingPacketHandlerService>();
    _initTasker();
    initializeBT();
    _initStatesDependencies();
  }

  void _btStateHandler(BluetoothState s) {
    switch (s) {
      case BluetoothState.unknown:
      case BluetoothState.unavailable:
      case BluetoothState.off:
        sl<SystemStateManager>().setBtState(BtStates.NOT_AVAILABLE);
        sl<SystemStateManager>().setDeviceCommState(DeviceStates.DISCONNECTED);
        break;
      default:
        sl<SystemStateManager>().setBtState(BtStates.ENABLED);
        break;
    }
  }

  //
  // handling situations when one state depends on one or more other states
  //
  _initStatesDependencies() {
    // handle bt disabling during test
    sl<SystemStateManager>()
        .btStateStream
        .where((_) => sl<SystemStateManager>().isTestActive)
        .listen(_handleDisconnectAndReconnectDuringTest);
  }

  _handleDisconnectAndReconnectDuringTest(BtStates state) {
    if (state == BtStates.NOT_AVAILABLE) {
      sl<SystemStateManager>()
          .setDataTransferState(DataTransferState.NOT_STARTED);
      sl<SystemStateManager>().setTestState(TestStates.INTERRUPTED);
      _disconnect();
    } else if (state == BtStates.ENABLED) {
      sl<SystemStateManager>().setScanCycleEnabled = true;
      startScan(
          time: GlobalSettings.btScanTimeout, connectToFirstDevice: false);
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
        Log.info(TAG, "### reconnected to device after test started");
        _testInterruptedTimer = Timer(Duration(seconds: 2), () {
          if (sysStateManager.testState != TestStates.RESUMED) {
            sl<CommandTaskerManager>()
                .sendDirectCommand(DeviceCommands.getIsDevicePairedCmd());
          }
        });
        return;
      }

      Log.info(TAG, "Device name: $_deviceAdvName");
      if (_isFirstConnection ||
          !_isFirstConnection && _deviceAdvName.endsWith("N")) {
        Log.info(TAG,
            "Connected to ${_isFirstConnection ? 'new' : 'previously paired'} device $_deviceAdvName, checking 'paired' flag");
        sl<CommandTaskerManager>()
            .sendDirectCommand(DeviceCommands.getIsDevicePairedCmd());
        return;
      }

      // start session
      sl<SystemStateManager>().setAppMode(AppModes.USER);
      sl<SystemStateManager>()
          .changeState
          .add(StateChangeActions.APP_MODE_CHANGED);

      if (_isFirstConnection) {
        sysStateManager.setFirmwareState(FirmwareUpgradeStates.UNKNOWN);
      }
    } else if (state == BluetoothDeviceState.disconnected) {
      Log.info(TAG, "disconnected from device");
      sysStateManager.setDeviceCommState(DeviceStates.DISCONNECTED);
      if (sysStateManager.testState == TestStates.STARTED ||
          sysStateManager.testState == TestStates.RESUMED) {
        sysStateManager.setTestState(TestStates.INTERRUPTED);
        sysStateManager.changeState.add(StateChangeActions.TEST_STATE_CHANGED);
      } else {
        _incomingPacketHandler.resetPacket();
        _disconnect();
        if (sysStateManager.isBTEnabled) {
          if (sysStateManager.testState != TestStates.ENDED) {
            sl<SystemStateManager>().setScanCycleEnabled = true;
            startScan(
                time: GlobalSettings.btScanTimeout,
                connectToFirstDevice: false);
          }
        } else {
          Log.shout(TAG, "BT not enabled scan cycle not initiated $tag");
        }
      }
    }
  }

  void _disconnect() {
    Log.info(TAG, 'Remove all value changed listeners');
    sl<SystemStateManager>().setBleScanResult(ScanResultStates.NOT_LOCATED);
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

    if (_scanInProgress) {
      Log.warning(TAG, "[preScanChecks] Scan already in progress");
      return false;
    }

    return true;
  }

  Future<dynamic> _sendCallback(CommandTaskerItem command) {
    print('_sendCallback ');
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
        startScan(
            time: GlobalSettings.btScanTimeout, connectToFirstDevice: false);
      }
    } else {
      Log.warning(TAG, "BT not enabled scan cycle not initiated");
    }
  }

  _sendCommand(List<List<int>> byteList) async {
    print("### _sendCommand ");

    if (byteList != null) {
      for (var req in byteList) {
        await sl<BleService>().writeCharacteristic(req);
      }
    } else {
      Log.shout(TAG, "sendCommand failed: byteList is null $tag");
    }
  }

  void _sendStartSession(int useType) {
    //todo add real SW id
    Log.info(TAG, "### sending start session ");
    sl<CommandTaskerManager>().addCommandWithNoCb(
        DeviceCommands.getStartSessionCmd(
            808598064, useType, [55, 46, 49, 46, 50]));
  }

  void forgetDeviceAndRestartScan() {
    sl<SystemStateManager>().setBleScanResult(ScanResultStates.NOT_LOCATED);
    sl<SystemStateManager>().setDeviceCommState(DeviceStates.DISCONNECTED);
    PrefsProvider.clearDeviceName();
    startScan(time: GlobalSettings.btScanTimeout, connectToFirstDevice: false);
  }

  void startScan(
      {int time, @required bool connectToFirstDevice, String deviceName}) {
    if (!_preScanChecks()) {
      return;
    }

    Log.info(TAG, '## START SCAN');
    _scanInProgress = true;
    _isFirstConnection = PrefsProvider.loadDeviceName() == null;

    Log.info(
        TAG,
        _isFirstConnection
            ? "First connection to device"
            : "Device was already connected, looking for device: ${PrefsProvider.loadDeviceName()}");

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
    final String localName = scanResult.advertisementData.localName;
    if (deviceName != null) {
      // todo add implementation

    } else {
      if (localName.contains('ITAMAR')) {
        Log.info(TAG,
            ">>> name on scan: $localName | stored name: ${PrefsProvider.loadDeviceName()}");

        if ((_isFirstConnection && localName.endsWith("N")) ||
            (!_isFirstConnection && localName.contains(PrefsProvider.loadDeviceName()))) {

          Log.info(TAG, '## FOUND DEVICE ${scanResult.device.id}');
          var currentResults = _scanResultsSubject.value;
          currentResults[scanResult.device.id] = scanResult;
          _scanResultsSubject.sink.add(currentResults);
        }

        if (connectToFirstDevice) {
          stopScan();
          return;
        }
      }
    }
  }

  void stopScan() {
    Log.info(TAG, '## STOP SCAN');
    _scanInProgress = false;
    if (_scanSubscription != null) {
      _scanSubscription.cancel();
      _scanSubscription = null;
    }

    _postScan();
  }

  void _postScan() async {
    sl<SystemStateManager>().setBleScanState(ScanStates.COMPLETE);
    final Map<DeviceIdentifier, ScanResult> _discoveredDevices =
        _scanResultsSubject.value;
    Log.info(TAG, 'Discovered ${_discoveredDevices.length} devices');
    if (_discoveredDevices.isEmpty) {
      Log.info(TAG, "no device discovered on scan");
      sl<SystemStateManager>().setBleScanResult(ScanResultStates.NOT_LOCATED);

      if (sl<SystemStateManager>().isScanCycleEnabled) {
        startScan(
            time: GlobalSettings.btScanTimeout, connectToFirstDevice: false);
      }
    } else if (_discoveredDevices.length == 1) {
      Log.info(TAG, "discovered a SINGLE device on scan");
      sl<SystemStateManager>()
          .setBleScanResult(ScanResultStates.LOCATED_SINGLE);

      sl<SystemStateManager>().setDeviceCommState(DeviceStates.CONNECTING);

      final BluetoothDevice device =
          _discoveredDevices.values.toList()[0].device;
      _deviceAdvName =
          _discoveredDevices.values.toList()[0].advertisementData.localName;

      connect(device);
    } else {
      Log.info(TAG, "discovered MULTIPLE devices on scan");
      sl<SystemStateManager>()
          .setBleScanResult(ScanResultStates.LOCATED_MULTIPLE);
      if (sl<SystemStateManager>().isScanCycleEnabled) {
        startScan(
            time: GlobalSettings.btScanTimeout, connectToFirstDevice: false);
      }
    }
  }

  void _systemStateHandler(StateChangeActions action) {
    switch (action) {
      case StateChangeActions.TEST_STATE_CHANGED:
        final TestStates testState = sl<SystemStateManager>().testState;
        if (testState == TestStates.STARTED) {
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
            _sendStartSession(DeviceCommands.SESSION_START_USE_TYPE_PATIENT);
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
          case AppModes.TECH:
            sl<CommandTaskerManager>().addCommandWithNoCb(
                DeviceCommands.getStartSessionCmd(
                    0x0000,
                    DeviceCommands.SESSION_START_USE_TYPE_PRODUCTION,
                    [0, 0, 0, 1]));
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

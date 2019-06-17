import 'package:connectivity/connectivity.dart';
import 'package:my_pat/managers/manager_base.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/log/log.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/rxdart.dart' as prefix0;
import 'package:tuple/tuple.dart';

enum BtStates { NONE, NOT_AVAILABLE, BLE_NOT_SUPPORTED, DISABLED, ENABLED }
enum ScanResultStates {
  NOT_STARTED,
  NOT_LOCATED,
  LOCATED_SINGLE,
  LOCATED_MULTIPLE
}
enum ScanStates { NOT_STARTED, SCANNING, COMPLETE }
enum DeviceStates { DISCONNECTED, CONNECTING, CONNECTED }
enum DeviceErrorStates {
  UNKNOWN,
  NO_ERROR,
  CHANGE_BATTERY,
  INSERT_FINGER,
  USED_DEVICE,
  HW_ERROR
}
enum SessionErrorState { UNKNOWN, NO_ERROR, PIN_ERROR }

enum ServerStates { DISCONNECTED, CONNECTING, CONNECTED }

enum TestStates {
  NOT_STARTED,
  STARTED,
  INTERRUPTED,
  RESUMED,
  MINIMUM_PASSED,
  STOPPED,
  ENDED
}

enum DataTransferState { NOT_STARTED, TRANSFERRING, ENDED }

enum SftpUploadingState {
  NOT_STARTED,
  UPLOADING,
  WAITING_FOR_DATA,
  ALL_UPLOADED
}

enum AppModes { USER, CS, TECH, BACKGROUND }
enum FirmwareUpgradeStates { UNKNOWN, UPGRADING, UP_TO_DATE, UPDATE_FAILED }
enum DispatcherStates {
  DISCONNECTED,
  CONFIG_RECEIVED,
  CONFIG_ERROR,
  AUTHENTICATING,
  AUTHENTICATED,
  AUTHENTICATION_FAILURE,
  FAILURE
}

enum StateChangeActions {
  BT_STATE_CHANGED,
  SCAN_STATE_CHANGED,
  SCAN_RESULT_CHANGED,
  DEVICE_STATE_CHANGED,
  DEVICE_ERROR_STATE_CHANGED,
  SERVER_STATE_CHANGED,
  TEST_STATE_CHANGED,
  DATA_TRANSFER_STATE_CHANGED,
  APP_MODE_CHANGED,
  FIRMWARE_STATE_CHANGED,
  DISPATCHER_STATE_CHANGED,
  FIRMWARE_UPGRADE_PROGRESS,
  NOTIFY_RECEIVED_FROM_DEVICE,
  NOTIFY_UPLOADING_TO_CLOUD,
  NOTIFY_UPLOADING_TO_CLOUD_DONE
}

enum StartSessionState { UNCONFIRMED, CONFIRMED }

class SystemStateManager extends ManagerBase {
  static const String TAG = 'SystemStateManager';

  // BT STATES
  static List<String> _btStates = [
    "None",
    "Not available",
    "BLE not supported",
    "Disabled",
    "Enabled"
  ];

  static String getBTStateName(int state) => _btStates[state];

  // SCAN RESULT STATES
  static List<String> _scanResults = [
    "Not started",
    "Not located",
    "Located single",
    "Located multiple"
  ];

  static String getScanResultStateName(int state) => _scanResults[state];

  // SCAN STATES
  static List<String> _scanStates = [
    "Not started",
    "Scanning",
    "Scanning complete"
  ];

  static String getScanStateName(int state) => _scanStates[state];

  // DEVICE STATES
  static List<String> _deviceStates = [
    "Disconnected",
    "Connecting",
    "Connected"
  ];

  static String getDeviceStateName(int state) => _deviceStates[state];

  // DEVICE ERROR STATES
  static List<String> _deviceErrorStates = [
    "Unknown",
    "No error",
    "Change battery",
    "Insert finger",
    "Used device",
    "Hardware error",
    "PIN error"
  ];

  static String getDeviceErrorStateName(int state) => _deviceErrorStates[state];

  // SERVER STATES
  static List<String> _serverStates = [
    "Disconnected",
    "Connecting",
    "Connected"
  ];

  static String getServerStateName(int state) => _serverStates[state];

  // TEST STATES
  static List<String> _testStates = [
    "Not started",
    "Started",
    "Interrupted",
    "Resumed",
    "Minimum passed",
    "Stopped",
    "Ended"
  ];

  static String getTestStateName(int state) => _testStates[state];

  // DATA TRANSFER STATES
  static List<String> _dataTransferStates = [
    "Not started",
    "Transferring",
    "Waiting for data",
    "Uploading to server",
    "Stopped",
    "All transferred"
  ];

  static String getDataTransferStateName(int state) =>
      _dataTransferStates[state];

  // APP MODES
  static List<String> _appStates = [
    "User",
    "Customer service",
    "Technician",
    "Background"
  ];

  static String getAppModeName(int state) => _appStates[state];

  // FIRMWARE UPGRADE STATES
  static List<String> _fwStates = ["None", "Upgrading", "Up to date", "Failed"];

  static String getFirmwareStateName(int state) => _fwStates[state];

  // DISPATCHER STATES
  static List<String> _dispatcherStates = [
    "Disconnected",
    "Configuration received",
    "Configuration error",
    "Authenticating",
    "Authenticated",
    "Authentication failure",
    "Failure"
  ];

  static String getDispatcherStateName(int state) => _dispatcherStates[state];

  Connectivity _connectivity = Connectivity();

  SystemStateManager() {
    initAllStates();
    _initInternetConnectivity();
    _initPersistentState();
  }

  // States
  BehaviorSubject<BtStates> _btState = BehaviorSubject<BtStates>();
  BehaviorSubject<ScanStates> _bleScanState = BehaviorSubject<ScanStates>();
  BehaviorSubject<ScanResultStates> _bleScanResult =
      BehaviorSubject<ScanResultStates>();
  BehaviorSubject<DeviceStates> _deviceCommState =
      BehaviorSubject<DeviceStates>();
  BehaviorSubject<DeviceErrorStates> _deviceErrorState =
      BehaviorSubject<DeviceErrorStates>();
  BehaviorSubject<SessionErrorState> _sessionErrorState =
      BehaviorSubject<SessionErrorState>();
  BehaviorSubject<ServerStates> _serverCommState =
      BehaviorSubject<ServerStates>();
  BehaviorSubject<TestStates> _testState = BehaviorSubject<TestStates>();
  BehaviorSubject<DataTransferState> _dataTransferState =
      BehaviorSubject<DataTransferState>();
  BehaviorSubject<AppModes> _appMode = BehaviorSubject<AppModes>();
  BehaviorSubject<FirmwareUpgradeStates> _firmwareState =
      BehaviorSubject<FirmwareUpgradeStates>();
  BehaviorSubject<DispatcherStates> _dispatcherState =
      BehaviorSubject<DispatcherStates>();
  BehaviorSubject<ConnectivityResult> _inetConnectionState =
      BehaviorSubject<ConnectivityResult>();

  PublishSubject<StateChangeActions> _stateChangeSubject =
      PublishSubject<StateChangeActions>();

  BehaviorSubject<StartSessionState> _startSessionState =
      BehaviorSubject<StartSessionState>();

  BehaviorSubject<SftpUploadingState> _sftpUploadingState =
      BehaviorSubject<SftpUploadingState>();

  Observable<BtStates> get btStateStream => _btState.stream;

  Observable<ScanStates> get bleScanStateStream => _bleScanState.stream;

  Observable<ScanResultStates> get bleScanResultStream => _bleScanResult.stream;

  Observable<DeviceStates> get deviceCommStateStream => _deviceCommState.stream;

  Observable<DeviceErrorStates> get deviceErrorStateStream =>
      _deviceErrorState.stream;

  Observable<SessionErrorState> get sessionErrorStateStream =>
      _sessionErrorState.stream;

  Observable<ServerStates> get serverCommStateStream => _serverCommState.stream;

  Observable<TestStates> get testStateStream => _testState.stream;

  Observable<DataTransferState> get dataTransferStateStream =>
      _dataTransferState.stream;

  Observable<AppModes> get appModeStream => _appMode.stream;

  Observable<FirmwareUpgradeStates> get firmwareStateStream =>
      _firmwareState.stream;

  Observable<DispatcherStates> get dispatcherStateStream =>
      _dispatcherState.stream;

  Observable<ConnectivityResult> get inetConnectionStateStream =>
      _inetConnectionState.stream;

  Observable<StateChangeActions> get stateChangeStream =>
      _stateChangeSubject.stream;

  Observable<StartSessionState> get startSessionStateStream =>
      _startSessionState.stream;

  Observable<SftpUploadingState> get sftpUploadingStateStream =>
      _sftpUploadingState.stream;

  bool _isServiceModeEnabled = false;
  bool _isScanCycleEnabled = false;

  String _deviceErrors = "";
  String _sessionErrors = "";

  void _initInternetConnectivity() {
    _connectivity
        .checkConnectivity()
        .then((res) => _inetConnectionState.sink.add(res));
    _connectivity.onConnectivityChanged
        .listen((result) => _inetConnectionState.sink.add(result));
  }

  //
  // Reset all the application persistent properties in case the app started
  // normally, not restored after started test
  //
  _initPersistentState() {
    if (testState != TestStates.INTERRUPTED &&
        testState != TestStates.STOPPED) {
      PrefsProvider.resetPersistentState();
    }
  }

  void initAllBTStates() {
    Log.info(TAG, "initializing all BT states");
    setBtState(BtStates.NONE);
    setBleScanState(ScanStates.NOT_STARTED);
    setBleScanResult(ScanResultStates.NOT_LOCATED);
    setDeviceCommState(DeviceStates.DISCONNECTED);
  }

  void initAllStates() {
    Log.info(TAG, "initializing all system states");
    setBtState(BtStates.NONE);
    setBleScanState(ScanStates.NOT_STARTED);
    setBleScanResult(ScanResultStates.NOT_STARTED);
    setDeviceCommState(DeviceStates.DISCONNECTED);
    setAppMode(AppModes.USER);
    setDataTransferState(DataTransferState.NOT_STARTED);
    setDeviceErrorState(DeviceErrorStates.UNKNOWN);
    setServerCommState(ServerStates.DISCONNECTED);
    setFirmwareState(FirmwareUpgradeStates.UNKNOWN);
    setDispatcherState(DispatcherStates.DISCONNECTED);
    setStartSessionState(StartSessionState.UNCONFIRMED);
    setSftpUploadingState(SftpUploadingState.NOT_STARTED);
    _initTestState();
  }

  void _initTestState() {
    TestStates currentTestState;
    if (PrefsProvider.getTestStarted() &&
        PrefsProvider.getTestStoppedByUser()) {
      currentTestState = TestStates.STOPPED;
    } else if (PrefsProvider.getTestStarted()) {
      currentTestState = TestStates.INTERRUPTED;
    } else {
      currentTestState = TestStates.NOT_STARTED;
    }
    setTestState(currentTestState);
  }

  void setBtState(final BtStates state) {
    if (state != _btState.value) {
      Log.info(TAG, "setBtState: ${getBTStateName(state.index)}");
      _btState.sink.add(state);
    }
  }

  void setBleScanState(ScanStates state) {
    Log.info(TAG, "setBleScanState: ${getScanStateName(state.index)}");
    _bleScanState.sink.add(state);
  }

  void setBleScanResult(ScanResultStates state) {
    if (state != _bleScanResult.value) {
      Log.info(TAG, "setBleScanResult: ${getScanResultStateName(state.index)}");
      _bleScanResult.sink.add(state);
    }
  }

  void setDeviceCommState(DeviceStates state) {
    if (state != _deviceCommState.value) {
      Log.info(TAG, "setDeviceCommState: ${getDeviceStateName(state.index)}");
      _deviceCommState.sink.add(state);
    }
  }

  void setDeviceErrorState(DeviceErrorStates state, {String errors}) {
    if (state != _deviceErrorState.value) {
      Log.info(TAG,
          "setDeviceErrorState: ${getDeviceErrorStateName(state.index)} ${errors != null ? errors : ''}");
      if (errors != null) {
        _deviceErrors = errors;
      }
      _deviceErrorState.sink.add(state);
    }
  }

  void setSessionErrorState(SessionErrorState state, {String errors}) {
    if (state != _sessionErrorState.value) {
      Log.info(TAG, "Session error state: ${state.toString()}");
      if (errors != null) {
        _sessionErrors = errors;
      }
      _sessionErrorState.sink.add(state);
    }
  }

  void setServerCommState(ServerStates state) {
    if (state != _serverCommState.value) {
      Log.info(TAG, "setServerCommState: ${getServerStateName(state.index)}");
      _serverCommState.sink.add(state);
    }
  }

  void setTestState(TestStates state) {
    if (state != _testState.value) {
      Log.info(TAG, "setTestState: ${getTestStateName(state.index)}");
      _testState.sink.add(state);
    }
  }

  void setDataTransferState(DataTransferState state) {
    if (state != _dataTransferState.value) {
      Log.info(TAG, "setDataTransferState: ${state.toString()}");
      _dataTransferState.sink.add(state);
    }
  }

  void setAppMode(AppModes state) {
    if (state != _appMode.value) {
      Log.info(TAG, "setAppMode: ${getAppModeName(state.index)}");
      _appMode.sink.add(state);
    }
  }

  void setFirmwareState(FirmwareUpgradeStates state) {
    if (state != _firmwareState.value) {
      Log.info(TAG, "setFirmwareState: ${getFirmwareStateName(state.index)}");
      _firmwareState.sink.add(state);
    }
  }

  void setDispatcherState(DispatcherStates state) {
    if (state != _dispatcherState.value) {
      Log.info(
          TAG, "setDispatcherState: ${getDispatcherStateName(state.index)}");
      _dispatcherState.sink.add(state);
    }
  }

  void setStartSessionState(StartSessionState state) {
    Log.info(TAG, "setStartSessionState: ${state.toString()}");
    _startSessionState.sink.add(state);
  }

  void setSftpUploadingState(SftpUploadingState state) {
    if (state != sftpUploadingState) {
      Log.info(TAG, "setSftpUploadingState ${state.toString()}");
      _sftpUploadingState.sink.add(state);
    }
  }

  Sink<StateChangeActions> get changeState => _stateChangeSubject.sink;

  bool get isServiceModeEnabled => _isServiceModeEnabled;

  set serviceModeEnabled(bool value) => _isServiceModeEnabled = value;

  set setScanCycleEnabled(bool value) => _isScanCycleEnabled = value;

  bool get isScanCycleEnabled => _isScanCycleEnabled;

  BtStates get btState => _btState.value;

  ScanStates get bleScanState => _bleScanState.value;

  ScanResultStates get bleScanResult => _bleScanResult.value;

  DeviceStates get deviceCommState => _deviceCommState.value;

  DeviceErrorStates get deviceErrorState => _deviceErrorState.value;

  String get deviceErrors => _deviceErrors;

  String get sessionErrors => _sessionErrors;

  ServerStates get serverCommState => _serverCommState.value;

  TestStates get testState => _testState.value;

  DataTransferState get dataTransferState => _dataTransferState.value;

  AppModes get appMode => _appMode.value;

  FirmwareUpgradeStates get firmwareState => _firmwareState.value;

  DispatcherStates get dispatcherState => _dispatcherState.value;

  StartSessionState get startSessionState => _startSessionState.value;

  SftpUploadingState get sftpUploadingState => _sftpUploadingState.value;

  bool get isBTEnabled => btState == BtStates.ENABLED;

  bool get isConnectionToDevice =>
      deviceCommState == DeviceStates.CONNECTED ||
      deviceCommState == DeviceStates.CONNECTING;

  bool get isConnectionToServer =>
      serverCommState == ServerStates.CONNECTED ||
      serverCommState == ServerStates.CONNECTING;

  bool get isTestActive =>
      testState != TestStates.NOT_STARTED && testState != TestStates.ENDED;

  @override
  void dispose() {
    _btState.close();
    _bleScanState.close();
    _bleScanResult.close();
    _deviceCommState.close();
    _dataTransferState.close();
    _deviceErrorState.close();
    _appMode.close();
    _serverCommState.close();
    _testState.close();
    _firmwareState.close();
    _dispatcherState.close();
    _stateChangeSubject.close();
    _inetConnectionState.close();
    _startSessionState.close();
    _sftpUploadingState.close();
  }

  Future<bool> get deviceHasErrors {
    if (PrefsProvider.getIgnoreDeviceErrors() ||
        bleScanResult == ScanResultStates.NOT_LOCATED)
      return Future.value(false);
    return Observable.combineLatest2<DeviceStates, DeviceErrorStates, Tuple2>(
            deviceCommStateStream,
            deviceErrorStateStream,
            (DeviceStates deviceState, DeviceErrorStates errorState) =>
                Tuple2(deviceState, errorState))
        .firstWhere((Tuple2 values) =>
            values.item1 == DeviceStates.CONNECTED &&
            values.item2 != DeviceErrorStates.UNKNOWN)
        .then((Tuple2 values) => values.item2 != DeviceErrorStates.NO_ERROR);
  }

  Future<bool> get sessionHasErrors {
    if (bleScanResult == ScanResultStates.NOT_LOCATED)
      return Future.value(false);
    return sessionErrorStateStream
        .firstWhere((SessionErrorState st) => st != SessionErrorState.UNKNOWN)
        .then((SessionErrorState state) => state != SessionErrorState.NO_ERROR);
  }
}

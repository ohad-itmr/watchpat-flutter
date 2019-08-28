import 'package:connectivity/connectivity.dart';
import 'package:my_pat/managers/manager_base.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/log/log.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

enum BtStates { NONE, NOT_AVAILABLE, BLE_NOT_SUPPORTED, DISABLED, ENABLED }
enum ScanResultStates { NOT_STARTED, NOT_LOCATED, LOCATED_SINGLE, LOCATED_MULTIPLE }
enum ScanStates { NOT_STARTED, SCANNING, COMPLETE }
enum DeviceStates { NOT_INITIALIZED, DISCONNECTED, CONNECTING, CONNECTED }
enum DeviceErrorStates { UNKNOWN, NO_ERROR, CHANGE_BATTERY, INSERT_FINGER, USED_DEVICE, HW_ERROR }
enum SessionErrorState { UNKNOWN, NO_ERROR, PIN_ERROR, SN_NOT_REGISTERED, NO_DISPATCHER }

enum ServerStates { DISCONNECTED, CONNECTING, CONNECTED }

enum TestStates {
  NOT_STARTED,
  STARTED,
  INTERRUPTED,
  RESUMED,
  MINIMUM_PASSED,
  STOPPED,
  ENDED,
  SFTP_UPLOAD_INCOMPLETE
}

enum DataTransferState { NOT_STARTED, TRANSFERRING, ENDED }

enum TestDataAmountState { MINIMUM_NOT_PASSED, MINIMUM_PASSED }

enum SftpUploadingState { NOT_STARTED, UPLOADING, WAITING_FOR_DATA, ALL_UPLOADED }

enum AppModes { USER, CS, TECH, BACKGROUND }
enum FirmwareUpgradeState { UNKNOWN, UPGRADING, UP_TO_DATE, UPGRADE_FAILED }
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

enum GlobalProcedureState { INCOMPLETE, COMPLETE }

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
  static List<String> _scanStates = ["Not started", "Scanning", "Scanning complete"];

  static String getScanStateName(int state) => _scanStates[state];

  // DEVICE STATES
  static List<String> _deviceStates = [
    "Not Initialized",
    "Disconnected",
    "Connecting",
    "Connected"
  ];

  static String getDeviceStateName(int state) => _deviceStates[state];

  // SERVER STATES
  static List<String> _serverStates = ["Disconnected", "Connecting", "Connected"];

  static String getServerStateName(int state) => _serverStates[state];

  // DATA TRANSFER STATES
  static List<String> _dataTransferStates = [
    "Not started",
    "Transferring",
    "Waiting for data",
    "Uploading to server",
    "Stopped",
    "All transferred"
  ];

  static String getDataTransferStateName(int state) => _dataTransferStates[state];

  // APP MODES
  static List<String> _appStates = ["User", "Customer service", "Technician", "Background"];

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
    _initDependentStates();
  }

  // States
  BehaviorSubject<BtStates> _btState = BehaviorSubject<BtStates>();
  BehaviorSubject<ScanStates> _bleScanState = BehaviorSubject<ScanStates>();
  BehaviorSubject<ScanResultStates> _bleScanResult = BehaviorSubject<ScanResultStates>();
  BehaviorSubject<DeviceStates> _deviceCommState = BehaviorSubject<DeviceStates>();
  BehaviorSubject<DeviceErrorStates> _deviceErrorState = BehaviorSubject<DeviceErrorStates>();
  BehaviorSubject<SessionErrorState> _sessionErrorState = BehaviorSubject<SessionErrorState>();
  BehaviorSubject<ServerStates> _serverCommState = BehaviorSubject<ServerStates>();
  BehaviorSubject<TestStates> _testState = BehaviorSubject<TestStates>();
  BehaviorSubject<DataTransferState> _dataTransferState = BehaviorSubject<DataTransferState>();
  BehaviorSubject<TestDataAmountState> _testDataAmountState =
      BehaviorSubject<TestDataAmountState>();
  BehaviorSubject<AppModes> _appMode = BehaviorSubject<AppModes>();
  BehaviorSubject<FirmwareUpgradeState> _firmwareState = BehaviorSubject<FirmwareUpgradeState>();
  BehaviorSubject<DispatcherStates> _dispatcherState = BehaviorSubject<DispatcherStates>();
  BehaviorSubject<ConnectivityResult> _inetConnectionState = BehaviorSubject<ConnectivityResult>();
  BehaviorSubject<GlobalProcedureState> _globalProcedureState =
      BehaviorSubject<GlobalProcedureState>();

  PublishSubject<StateChangeActions> _stateChangeSubject = PublishSubject<StateChangeActions>();

  BehaviorSubject<StartSessionState> _startSessionState = BehaviorSubject<StartSessionState>();

  BehaviorSubject<SftpUploadingState> _sftpUploadingState = BehaviorSubject<SftpUploadingState>();

  Observable<BtStates> get btStateStream => _btState.stream;

  Observable<ScanStates> get bleScanStateStream => _bleScanState.stream;

  Observable<ScanResultStates> get bleScanResultStream => _bleScanResult.stream;

  Observable<DeviceStates> get deviceCommStateStream => _deviceCommState.stream;

  Observable<DeviceErrorStates> get deviceErrorStateStream => _deviceErrorState.stream;

  Observable<SessionErrorState> get sessionErrorStateStream => _sessionErrorState.stream;

  Observable<ServerStates> get serverCommStateStream => _serverCommState.stream;

  Observable<TestStates> get testStateStream => _testState.stream;

  Observable<DataTransferState> get dataTransferStateStream => _dataTransferState.stream;

  Observable<TestDataAmountState> get testDataAmountState => _testDataAmountState.stream;

  Observable<AppModes> get appModeStream => _appMode.stream;

  Observable<FirmwareUpgradeState> get firmwareStateStream => _firmwareState.stream;

  Observable<DispatcherStates> get dispatcherStateStream => _dispatcherState.stream;

  Observable<ConnectivityResult> get inetConnectionStateStream => _inetConnectionState.stream;

  Observable<StateChangeActions> get stateChangeStream => _stateChangeSubject.stream;

  Observable<StartSessionState> get startSessionStateStream => _startSessionState.stream;

  Observable<SftpUploadingState> get sftpUploadingStateStream => _sftpUploadingState.stream;

  Observable<GlobalProcedureState> get globalProcedureStateStream => _globalProcedureState.stream;

  bool _isScanCycleEnabled = true;

  String _deviceErrors = "";
  String _sessionErrors = "";

  void _initInternetConnectivity() {
    _connectivity.checkConnectivity().then((res) => _inetConnectionState.sink.add(res));
    _connectivity.onConnectivityChanged.listen((result) => _inetConnectionState.sink.add(result));
  }

  //
  // Reset all the application persistent properties in case the app started
  // normally, not restored after started test
  //
  _initPersistentState() {
    if (testState == TestStates.NOT_STARTED) {
      PrefsProvider.resetPersistentState();
    }
  }

  //
  // Init subscriptions which should take care of the situation when
  // changing one state leads to changing of another
  //
  _initDependentStates() {
    // set proper TestState when device communication state has changed
    deviceCommStateStream
        .where((_) => isTestActive && deviceCommState == DeviceStates.DISCONNECTED)
        .listen((_) => setTestState(TestStates.INTERRUPTED));
  }

  void initAllBTStates() {
    Log.info(TAG, "initializing all BT states");
    setBtState(BtStates.NONE);
    setBleScanState(ScanStates.NOT_STARTED);
    setBleScanResult(ScanResultStates.NOT_LOCATED);
    setDeviceCommState(DeviceStates.NOT_INITIALIZED);
  }

  void initAllStates() {
    Log.info(TAG, "initializing all system states");
    setBtState(BtStates.NONE);
    setBleScanState(ScanStates.NOT_STARTED);
    setBleScanResult(ScanResultStates.NOT_STARTED);
    setDeviceCommState(DeviceStates.NOT_INITIALIZED);
    setAppMode(AppModes.USER);
    setDataTransferState(DataTransferState.NOT_STARTED);
    setTestDataAmountState(TestDataAmountState.MINIMUM_NOT_PASSED);
    setDeviceErrorState(DeviceErrorStates.UNKNOWN);
    setServerCommState(ServerStates.DISCONNECTED);
    setFirmwareState(FirmwareUpgradeState.UNKNOWN);
    setDispatcherState(DispatcherStates.DISCONNECTED);
    setStartSessionState(StartSessionState.UNCONFIRMED);
    setSftpUploadingState(SftpUploadingState.NOT_STARTED);
    setGlobalProcedureState(GlobalProcedureState.INCOMPLETE);
    _initTestState();
  }

  void _initTestState() {
    TestStates currentTestState;
    if (PrefsProvider.getTestStarted() && PrefsProvider.getTestStoppedByUser()) {
      currentTestState = TestStates.STOPPED;
    } else if (PrefsProvider.getTestStarted()) {
      currentTestState = TestStates.INTERRUPTED;
    } else if (PrefsProvider.getDataUploadingIncomplete()) {
      currentTestState = TestStates.SFTP_UPLOAD_INCOMPLETE;
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
          "setDeviceErrorState: $state, $errors");
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
      Log.info(TAG, "setTestState: ${state.toString()}");
      _testState.sink.add(state);
    }
  }

  void setDataTransferState(DataTransferState state) {
    if (state != _dataTransferState.value) {
      Log.info(TAG, "setDataTransferState: ${state.toString()}");
      _dataTransferState.sink.add(state);
    }
  }

  void setTestDataAmountState(TestDataAmountState state) {
    if (state != _testDataAmountState.value) {
      Log.info(TAG, "setTestDataAmountState: ${state.toString()}");
      _testDataAmountState.sink.add(state);
    }
  }

  void setAppMode(AppModes state) {
    if (state != _appMode.value) {
      Log.info(TAG, "setAppMode: ${getAppModeName(state.index)}");
      _appMode.sink.add(state);
    }
  }

  void setFirmwareState(FirmwareUpgradeState state) {
    if (state != _firmwareState.value) {
      Log.info(TAG, "setFirmwareState: ${state.toString().toUpperCase()}");
      _firmwareState.sink.add(state);
    }
  }

  void setDispatcherState(DispatcherStates state) {
    if (state != _dispatcherState.value) {
      Log.info(TAG, "setDispatcherState: ${getDispatcherStateName(state.index)}");
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

  void setGlobalProcedureState(GlobalProcedureState state) {
    Log.info(TAG, "Set global procedure state ${state.toString()}");
    _globalProcedureState.sink.add(state);
  }

  Sink<StateChangeActions> get changeState => _stateChangeSubject.sink;

  set setScanCycleEnabled(bool value) => _isScanCycleEnabled = value;

  bool get isScanCycleEnabled => _isScanCycleEnabled;

  BtStates get btState => _btState.value;

  ScanStates get bleScanState => _bleScanState.value;

  ScanResultStates get bleScanResult => _bleScanResult.value;

  DeviceStates get deviceCommState => _deviceCommState.value;

  DeviceErrorStates get deviceErrorState => _deviceErrorState.value;

  String get deviceErrors => _deviceErrors;

  void clearDeviceErrors() {
    _deviceErrors = '';
    sl<IncomingPacketHandlerService>().clearDeviceErrors();
  }

  String get sessionErrors => _sessionErrors;

  ServerStates get serverCommState => _serverCommState.value;

  TestStates get testState => _testState.value;

  DataTransferState get dataTransferState => _dataTransferState.value;

  AppModes get appMode => _appMode.value;

  FirmwareUpgradeState get firmwareState => _firmwareState.value;

  DispatcherStates get dispatcherState => _dispatcherState.value;

  StartSessionState get startSessionState => _startSessionState.value;

  SftpUploadingState get sftpUploadingState => _sftpUploadingState.value;

  GlobalProcedureState get globalProcedureState => _globalProcedureState.value;

  ConnectivityResult get inetConnectionState => _inetConnectionState.value;

  bool get isBTEnabled => btState == BtStates.ENABLED;

  bool get isConnectionToDevice =>
      deviceCommState == DeviceStates.CONNECTED || deviceCommState == DeviceStates.CONNECTING;

  bool get isConnectionToServer =>
      serverCommState == ServerStates.CONNECTED || serverCommState == ServerStates.CONNECTING;

  bool get isTestActive => testState != TestStates.NOT_STARTED && testState != TestStates.ENDED;

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
    _sessionErrorState.close();
    _testDataAmountState.close();
    _globalProcedureState.close();
  }

  Future<bool> get deviceHasErrors {
    if (PrefsProvider.getIgnoreDeviceErrors() ||
        bleScanResult == ScanResultStates.NOT_LOCATED ||
        bleScanResult == ScanResultStates.LOCATED_MULTIPLE) return Future.value(false);
    return Observable.combineLatest2<DeviceStates, DeviceErrorStates, Tuple2>(
            deviceCommStateStream,
            deviceErrorStateStream,
            (DeviceStates deviceState, DeviceErrorStates errorState) =>
                Tuple2(deviceState, errorState))
        .firstWhere((Tuple2 values) =>
            values.item1 == DeviceStates.CONNECTED && values.item2 != DeviceErrorStates.UNKNOWN)
        .then((Tuple2 values) => values.item2 != DeviceErrorStates.NO_ERROR);
  }

  Future<bool> get sessionHasErrors {
    if (bleScanResult == ScanResultStates.NOT_LOCATED ||
        bleScanResult == ScanResultStates.LOCATED_MULTIPLE) return Future.value(false);
    return sessionErrorStateStream
        .firstWhere((SessionErrorState st) => st != SessionErrorState.UNKNOWN)
        .then((SessionErrorState state) => state != SessionErrorState.NO_ERROR);
  }
}

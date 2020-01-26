import 'dart:async';
import 'dart:math';
import 'package:connectivity/connectivity.dart';
import 'package:my_pat/domain_model/response_model.dart';
import 'package:my_pat/utils/log/log.dart';
import 'package:rxdart/rxdart.dart';
import 'package:my_pat/service_locator.dart';
import 'package:rxdart/rxdart.dart' as prefix0;

enum WelcomeActivityState { NOT_STARTED, WORKING, DONE_FAILED, DONE_SUCCESS }
enum FileCreationState { NOT_STARTED, STARTED, DONE_SUCCESS, DONE_FAILED }

class WelcomeActivityManager extends ManagerBase {
  static const String TAG = 'WelcomeActivityManager';

  static const int MAX_TIME_GAP_BETWEEN_RUNS_HOURS = 24;

  final _lang = sl<S>();
  final Connectivity _connectivity = Connectivity();

  String _deviceName;

  WelcomeActivityManager() {
    _initErrorsSubject.add(List());
//    allocateSpace();
    createStartFiles();
    _welcomeState.add(WelcomeActivityState.NOT_STARTED);
    _fileCreationStateSubject.add(FileCreationState.NOT_STARTED);
    _fileAllocationStateSubject.add(FileCreationState.NOT_STARTED);
  }

  BehaviorSubject<WelcomeActivityState> _welcomeState = BehaviorSubject<WelcomeActivityState>();

  BehaviorSubject<FileCreationState> _fileCreationStateSubject = BehaviorSubject<FileCreationState>();

  Observable<FileCreationState> get fileCreationState => _fileCreationStateSubject.stream;

  BehaviorSubject<FileCreationState> _fileAllocationStateSubject = BehaviorSubject<FileCreationState>();

  Observable<FileCreationState> get fileAllocationState => _fileAllocationStateSubject.stream;

  BehaviorSubject<bool> _initFiles = BehaviorSubject<bool>.seeded(false);

  Observable<bool> get _initFilesState => _initFiles.stream;

  BehaviorSubject<bool> _internetExists = BehaviorSubject<bool>();

  Observable<bool> get internetExists => _internetExists.stream;

  BehaviorSubject<List<String>> _initErrorsSubject = BehaviorSubject<List<String>>.seeded(List());

  Observable<List<String>> get initErrors => _initErrorsSubject.stream;

  BehaviorSubject<bool> _configurationFinished = BehaviorSubject<bool>.seeded(false);

  Observable<bool> get configFinished => _configurationFinished.stream;

  Future<void> configureApplication() async {
    // Check if external config is enabled
    final Map<String, dynamic> configEnabledResponse = await sl<DispatcherService>().checkExternalConfig();

    if (!configEnabledResponse['error']) {
      if (configEnabledResponse['isEnabled']) {
        Log.info(TAG, "External config enabled, getting config from dispatcher");
        // get config from server
        final Map<String, dynamic> response = await sl<DispatcherService>().getExternalConfig();
        // set config
        if (response["error"]) {
          Log.shout(TAG, "Failed to receive config from dispatcher: ${response["message"]}");
//          addInitialErrors("Connection to dispatchers failed");
        } else {
          Log.info(TAG, "External config received from dispatcher, configuring application");
          GlobalSettings.setExternalConfiguration(response["config"]);
          GlobalSettings.persistConfiguration(response["config"]);
        }
      }
    } else {
      addInitialErrors("Connection to dispatchers failed");
    }

    // todo testing only
    await GlobalSettings.replaceSettingsFromXML();

    _configurationFinished.sink.add(true);
  }

  Future<void> allocateSpace() async {
    await configFinished.firstWhere((done) => done);
    _fileAllocationStateSubject.sink.add(FileCreationState.STARTED);
    Response res = await sl<FileSystemService>().allocateSpace();
    if (!res.success) {
      addInitialErrors(_lang.insufficient_storage_space_on_smartphone);
    }
    _fileAllocationStateSubject.sink.add(res.success ? FileCreationState.DONE_SUCCESS : FileCreationState.DONE_FAILED);
  }

  Future<void> createStartFiles() async {
    _fileCreationStateSubject.sink.add(FileCreationState.STARTED);
    Response res = await sl<FileSystemService>().init();
    if (!res.success) {
      addInitialErrors(_lang.files_creating_failed);
    }
    _fileCreationStateSubject.sink.add(res.success ? FileCreationState.DONE_SUCCESS : FileCreationState.DONE_FAILED);
  }

  void _initializeFilesOperation() {
    Observable.combineLatest2(fileAllocationState, fileCreationState, (FileCreationState allocationState, FileCreationState fileState) {
      if ((allocationState == FileCreationState.DONE_SUCCESS || allocationState == FileCreationState.DONE_FAILED) &&
          (fileState == FileCreationState.DONE_SUCCESS || fileState == FileCreationState.DONE_FAILED)) {
        _initFiles.sink.add(true);
      }
    }).listen(null);
  }

  Observable<bool> get initialChecksComplete => Observable.combineLatest2(
        sl<SystemStateManager>().bleScanStateStream,
        _initFilesState,
        (ScanStates scanState, bool initFilesComplete) {
          return initFilesComplete && scanState == ScanStates.COMPLETE;
        },
      );

  bool getInternetConnectionState() => _internetExists.value;

  List<String> getInitialErrors() => _initErrorsSubject.value;

  String get initialErrorsAsString {
    var errors = StringBuffer();
    _initErrorsSubject.value.forEach((String val) => errors.write('- $val\n'));
    return errors.toString();
  }

  _connectivityStatusHandler(ConnectivityResult result) => _internetExists.sink.add(result != ConnectivityResult.none);

  addInitialErrors(String err) {
    var currentList = _initErrorsSubject.value;
    currentList.add(err);
    _initErrorsSubject.add(currentList);
  }

  init() {
    _welcomeState.sink.add(WelcomeActivityState.WORKING);
    initConnectivityListener();
    _initializeFilesOperation();
  }

  initConnectivityListener() {
    sl<SystemStateManager>().inetConnectionStateStream.listen((result) => _connectivityStatusHandler(result));
  }

  checkForOutdatedSession() {
    final int prevSession = PrefsProvider.loadPreviousSessionTime();
    final int currentTime = DateTime.now().millisecondsSinceEpoch;
    if (prevSession != null && currentTime - prevSession > MAX_TIME_GAP_BETWEEN_RUNS_HOURS * 60 * 60 * 1000) {
      Log.info(TAG, "Found outdated session, clearing device from memmory");
      PrefsProvider.clearDeviceName();
    }
    PrefsProvider.savePreviousSessionTime(currentTime);
  }

  @override
  void dispose() {
    _initErrorsSubject.close();
    _internetExists.close();
    _welcomeState.close();
    _fileCreationStateSubject.close();
    _fileAllocationStateSubject.close();
    _configurationFinished.close();
    _initFiles.close();
  }
}

import 'dart:async';
import 'dart:math';
import 'package:connectivity/connectivity.dart';
import 'package:my_pat/domain_model/response_model.dart';
import 'package:my_pat/utils/log/log.dart';
import 'package:rxdart/rxdart.dart';
import 'package:my_pat/service_locator.dart';

enum WelcomeActivityState { NOT_STARTED, WORKING, DONE_FAILED, DONE_SUCCESS }
enum FileCreationState { NOT_STARTED, STARTED, DONE_SUCCESS, DONE_FAILED }

class WelcomeActivityManager extends ManagerBase {
  static const String TAG = 'WelcomeActivityManager';

  final _lang = sl<S>();
  final Connectivity _connectivity = Connectivity();

  String _deviceName;

  WelcomeActivityManager() {
    _initErrorsSubject.add(List());
    _allocateSpace();
    createStartFiles();
    _welcomeState.add(WelcomeActivityState.NOT_STARTED);
    _fileCreationStateSubject.add(FileCreationState.NOT_STARTED);
    _fileAllocationStateSubject.add(FileCreationState.NOT_STARTED);
  }

  BehaviorSubject<WelcomeActivityState> _welcomeState = BehaviorSubject<WelcomeActivityState>();

  BehaviorSubject<FileCreationState> _fileCreationStateSubject =
      BehaviorSubject<FileCreationState>();

  Observable<FileCreationState> get fileCreationState => _fileCreationStateSubject.stream;

  BehaviorSubject<FileCreationState> _fileAllocationStateSubject =
      BehaviorSubject<FileCreationState>();

  Observable<FileCreationState> get fileAllocationState => _fileAllocationStateSubject.stream;

  BehaviorSubject<bool> _internetExists = BehaviorSubject<bool>();

  Observable<bool> get internetExists => _internetExists.stream;

  BehaviorSubject<List<String>> _initErrorsSubject = BehaviorSubject<List<String>>();

  Observable<List<String>> get initErrors => _initErrorsSubject.stream;

  BehaviorSubject<bool> _configurationFinished = BehaviorSubject<bool>();

  Observable<bool> get configFinished => _configurationFinished.stream;

  Future<void> _allocateSpace() async {
    _fileAllocationStateSubject.sink.add(FileCreationState.STARTED);
    Response res = await sl<FileSystemService>().allocateSpace();
    _fileAllocationStateSubject.sink
        .add(res.success ? FileCreationState.DONE_SUCCESS : FileCreationState.DONE_FAILED);
  }

  Future<void> configureApplication() async {
    // Check if external config is enabled
    final bool configEnabled = await sl<DispatcherService>().checkExternalConfig();
    if (configEnabled) {
      Log.info(TAG, "External config enabled, getting config from dispatcher");
      // get config from server
      final Map<String, dynamic> response = await sl<DispatcherService>().getExternalConfig();
      // set config
      if (response["error"]) {
        Log.shout(TAG, "Failed to receive config from dispatcher: ${response["message"]}");
      } else {
        Log.info(TAG, "External config received from dispatcher, configuring application");
        GlobalSettings.setExternalConfiguration(response["config"]);
        GlobalSettings.persistConfiguration(response["config"]);
        await PrefsProvider.saveDispatcherUrlIndex(0);
      }
      _configurationFinished.sink.add(true);
    }
  }

  Future<void> createStartFiles() async {
    _fileCreationStateSubject.sink.add(FileCreationState.STARTED);
    Response res = await sl<FileSystemService>().init();
    _fileCreationStateSubject.sink
        .add(res.success ? FileCreationState.DONE_SUCCESS : FileCreationState.DONE_FAILED);
  }

  Observable<Response> _initFiles() {
    return Observable.combineLatest2(fileAllocationState, fileCreationState,
        (FileCreationState allocationState, FileCreationState fileState) {
      if (allocationState == FileCreationState.DONE_SUCCESS &&
          fileState == FileCreationState.DONE_SUCCESS) {
        return Response(success: true);
      }
      _welcomeState.sink.add(WelcomeActivityState.DONE_FAILED);
      return Response(
        success: false,
        error: _lang.insufficient_storage_space_on_smartphone,
      );
    });
  }

  Observable<bool> get initialChecksComplete => Observable.combineLatest3(
        sl<SystemStateManager>().bleScanStateStream,
        sl<SystemStateManager>().bleScanResultStream,
        _initFiles(),
        (ScanStates scanState, ScanResultStates scanResultState, Response initFilesResponse) {
          _initErrorsSubject.add(List());

          if (!initFilesResponse.success) {
            addInitialErrors(initFilesResponse.error);
          }

          if (scanState != ScanStates.COMPLETE) {
            return false;
          }
          return true;
        },
      );

  bool getInternetConnectionState() => _internetExists.value;

  List<String> getInitialErrors() => _initErrorsSubject.value;

  _connectivityStatusHandler(ConnectivityResult result) =>
      _internetExists.sink.add(result != ConnectivityResult.none);

  addInitialErrors(String err) {
    var currentList = _initErrorsSubject.value;
    currentList.add(err);
    _initErrorsSubject.add(currentList);
  }

  init() {
    _welcomeState.sink.add(WelcomeActivityState.WORKING);
    initConnectivityListener();
  }

  initConnectivityListener() {
    sl<SystemStateManager>()
        .inetConnectionStateStream
        .listen((result) => _connectivityStatusHandler(result));
  }

  @override
  void dispose() {
    _initErrorsSubject.close();
    _internetExists.close();
    _welcomeState.close();
    _fileCreationStateSubject.close();
    _fileAllocationStateSubject.close();
    _configurationFinished.close();
  }
}

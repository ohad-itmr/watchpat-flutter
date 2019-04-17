import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:my_pat/domain_model/response_model.dart';
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

  BehaviorSubject<WelcomeActivityState> _welcomeState =
      BehaviorSubject<WelcomeActivityState>();

  BehaviorSubject<FileCreationState> _fileCreationStateSubject =
      BehaviorSubject<FileCreationState>();

  Observable<FileCreationState> get fileCreationState =>
      _fileCreationStateSubject.stream;

  BehaviorSubject<FileCreationState> _fileAllocationStateSubject =
      BehaviorSubject<FileCreationState>();

  Observable<FileCreationState> get fileAllocationState =>
      _fileAllocationStateSubject.stream;

  BehaviorSubject<bool> _internetExists = BehaviorSubject<bool>();

  Observable<bool> get internetExists => _internetExists.stream;

  BehaviorSubject<List<String>> _initErrorsSubject =
      BehaviorSubject<List<String>>();

  Observable<List<String>> get initErrors => _initErrorsSubject.stream;

  Future<void> _allocateSpace() async {
    _fileAllocationStateSubject.sink.add(FileCreationState.STARTED);
    Response res = await sl<FileSystemService>().allocateSpace();
    _fileAllocationStateSubject.sink.add(res.success
        ? FileCreationState.DONE_SUCCESS
        : FileCreationState.DONE_FAILED);
  }

  Future<void> createStartFiles() async {
    _fileCreationStateSubject.sink.add(FileCreationState.STARTED);
    Response res = await sl<FileSystemService>().init();
    _fileCreationStateSubject.sink.add(res.success
        ? FileCreationState.DONE_SUCCESS
        : FileCreationState.DONE_FAILED);
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
        (ScanStates scanState, ScanResultStates scanResultState,
            Response initFilesResponse) {
          print(scanState);
          if (scanState != ScanStates.COMPLETE) {
            return false;
          }
          _initErrorsSubject.add(List());
          if (!initFilesResponse.success) {
            addInitialErrors(initFilesResponse.error);
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

    if (PrefsProvider.getIsFirstTimeRun() == null ||
        PrefsProvider.getIsFirstTimeRun()) {
      sl<BleManager>().startScan(time: 3000, connectToFirstDevice: false);
    }

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
  }
}

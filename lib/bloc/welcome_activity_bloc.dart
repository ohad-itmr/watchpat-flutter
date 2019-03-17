import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:my_pat/api/file_system_provider.dart';
import 'package:my_pat/api/network_provider.dart';
import 'package:my_pat/bloc/app_bloc.dart';
import 'package:my_pat/bloc/bloc_provider.dart';
import 'package:my_pat/bloc/helpers/bloc_base.dart';
import 'package:my_pat/models/response_model.dart';
import 'package:rxdart/rxdart.dart';
import 'helpers/bloc_base.dart';
import 'package:my_pat/generated/i18n.dart';

enum WelcomeActivityState { NOT_STARTED, WORKING, DONE_FAILED, DONE_SUCCESS }
enum FileCreationState { NOT_STARTED, STARTED, DONE_SUCCESS, DONE_FAILED }

class WelcomeActivityBloc extends BlocBase {
  AppBloc _root;

  final _networkProvider = NetworkProvider();
  final _filesProvider = fileSystemProvider;
  final lang = S();

  BehaviorSubject<WelcomeActivityState> _welcomeState =
      BehaviorSubject<WelcomeActivityState>();

  PublishSubject<FileCreationState> _fileCreationStateSubject =
      PublishSubject<FileCreationState>();

  Observable<FileCreationState> get fileCreationState => _fileCreationStateSubject.stream;

  PublishSubject<FileCreationState> _fileAllocationStateSubject =
      PublishSubject<FileCreationState>();

  Observable<FileCreationState> get fileAllocationState =>
      _fileAllocationStateSubject.stream;

  BehaviorSubject<bool> _internetExists = BehaviorSubject<bool>();

  Observable<bool> get internetExists => _internetExists.stream;

  BehaviorSubject<List<String>> _initErrorsSubject = BehaviorSubject<List<String>>();

  Observable<List<String>> get initErrors => _initErrorsSubject.stream;

  Future<void> _allocateSpace() async {
    _fileAllocationStateSubject.sink.add(FileCreationState.STARTED);
    Response res = await _filesProvider.allocateSpace();
    if (res.success) {
      _fileAllocationStateSubject.sink.add(FileCreationState.DONE_SUCCESS);
    } else {
      _fileAllocationStateSubject.sink.add(FileCreationState.DONE_FAILED);
    }
  }

  Future<void> createStartFiles() async {
    _fileCreationStateSubject.sink.add(FileCreationState.STARTED);
    Response res = await _filesProvider.init();
    if (res.success) {
      _fileCreationStateSubject.sink.add(FileCreationState.DONE_SUCCESS);
    } else {
      _fileCreationStateSubject.sink.add(FileCreationState.DONE_FAILED);
    }
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
        error: lang.insufficient_storage_space_on_smartphone,
      );
    });
  }

  Observable<bool> get initialChecksComplete => Observable.combineLatest3(
        _root.systemStateBloc.bleScanStateStream,
        _root.systemStateBloc.bleScanResultStream,
        _initFiles(),
        (ScanStates scanState, ScanResultStates scanResultState, Response f) {
          print(scanState);
          if (scanState != ScanStates.COMPLETE) {
            return false;
          }
          _initErrorsSubject.add(List());
          if (!f.success) {
            addInitialErrors(f.error);
          }

          return true;
        },
      );

  bool getInternetConnectionState() => _internetExists.value;

  List<String> getInitialErrors() => _initErrorsSubject.value;

  _connectivityStatusHandler(ConnectivityResult result) {
    _internetExists.sink.add(result != ConnectivityResult.none);
  }

  addInitialErrors(String err) {
    var currentList = _initErrorsSubject.value;
    currentList.add(err);
    _initErrorsSubject.add(currentList);
  }

  init() {
    _welcomeState.sink.add(WelcomeActivityState.WORKING);
//    initErrors.listen((errs) => Log.info('## INIT ERRORS ${errs.toString()} $this'));

    _networkProvider.connectivity
        .checkConnectivity()
        .then((ConnectivityResult result) => _connectivityStatusHandler(result));

    _networkProvider.connectivity.onConnectivityChanged
        .listen((ConnectivityResult result) => _connectivityStatusHandler(result));
  }

  WelcomeActivityBloc(AppBloc root) {
    this._root = root;
    _fileCreationStateSubject.sink.add(FileCreationState.NOT_STARTED);
    _fileAllocationStateSubject.sink.add(FileCreationState.NOT_STARTED);
    _initErrorsSubject.add(List());
    _welcomeState.sink.add(WelcomeActivityState.NOT_STARTED);
    _allocateSpace();
    createStartFiles();
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

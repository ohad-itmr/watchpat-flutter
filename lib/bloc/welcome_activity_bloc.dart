import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:my_pat/api/file_system_provider.dart';
import 'package:my_pat/api/network_provider.dart';
import 'package:my_pat/bloc/app_bloc.dart';
import 'package:my_pat/bloc/ble_bloc.dart';
import 'package:my_pat/bloc/helpers/bloc_base.dart';
import 'package:my_pat/models/response_model.dart';
import 'package:my_pat/utility/log/log.dart';
import 'package:rxdart/rxdart.dart';
import 'helpers/bloc_base.dart';
import 'package:my_pat/generated/i18n.dart';

class WelcomeActivityBloc extends BlocBase {
  AppBloc _root;

  final _networkProvider = NetworkProvider();
  final filesProvider = FileSystemProvider();

  final lang = S();

  BehaviorSubject<bool> _internetExists = BehaviorSubject<bool>();

  Observable<bool> get internetExists => _internetExists.stream;

  BehaviorSubject<List<String>> _initErrorsSubject = BehaviorSubject<List<String>>();

  Observable<List<String>> get initErrors => _initErrorsSubject.stream;

  Stream<Response> _allocateSpace() {
    return filesProvider.allocateSpace().asStream();
  }

  Stream<Response> _createStartFiles() {
    return filesProvider.init().asStream();
  }

  Observable<Response> _initFiles() {
    Log.info('[FileBloc INIT]');
    return Observable.combineLatest2(_allocateSpace(), _createStartFiles(),
        (Response as, Response cf) {
      if (as.success == true && cf.success == true) {
        return Response(success: true);
      }
      return Response(
        success: false,
        error: lang.insufficient_storage_space_on_smartphone,
      );
    });
  }

  Observable<bool> get initialChecksComplete => Observable.combineLatest3(
        _root.bleBloc.scanState,
        _root.bleBloc.scanResults,
        _initFiles(),
        (ScanState scanState, Map<DeviceIdentifier, ScanResult> scanResults, Response f) {
          print(scanState);
          if (scanState == ScanState.COMPLETE) {
            if (scanResults.length > 1) {
              Log.warning('## Found multiple devices: ${scanResults.length} $this');
              _root.bleBloc.changeScanResultState.add(ScanResultSate.FOUND_MULTIPLE);
            } else if (scanResults.length == 0) {
              Log.warning('## Devices not found $this');
              _root.bleBloc.changeScanResultState.add(ScanResultSate.NOT_FOUND);
            } else {
              Log.info('## Device found $this');
              _root.bleBloc.changeScanResultState.add(ScanResultSate.FOUND_SINGLE);
            }
          } else {
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

  WelcomeActivityBloc(AppBloc root) {
    this._root = root;
    _initErrorsSubject.add(List());

    initErrors.listen((errs) => Log.info('## INIT ERRORS ${errs.toString()} $this'));

    _networkProvider.connectivity
        .checkConnectivity()
        .then((ConnectivityResult result) => _connectivityStatusHandler(result));

    _networkProvider.connectivity.onConnectivityChanged
        .listen((ConnectivityResult result) => _connectivityStatusHandler(result));
  }

  @override
  void dispose() {
    _initErrorsSubject.close();
    _internetExists.close();
  }
}

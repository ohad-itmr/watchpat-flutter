import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:my_pat/api/file_system_provider.dart';
import 'package:my_pat/api/network_provider.dart';
import 'package:my_pat/bloc/helpers/bloc_base.dart';
import 'package:my_pat/models/response_model.dart';
import 'package:my_pat/utility/log/log.dart';
import 'package:rxdart/rxdart.dart';
import 'helpers/bloc_base.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:my_pat/generated/i18n.dart';
import 'package:my_pat/api/ble_provider.dart';

class WelcomeActivityBloc extends BlocBase {
  final _flutterBlue = bleProvider.flutterBlue;
  final _networkProvider = NetworkProvider();
  final filesProvider = FileSystemProvider();

  final lang = S();

  PublishSubject<BluetoothState> _bleStateSubject = PublishSubject<BluetoothState>();

  Observable<BluetoothState> get bleState => _bleStateSubject.stream;

  Observable<bool> get showBTWarning => _showBTWarning.stream;

  BehaviorSubject<bool> _internetExists = BehaviorSubject<bool>();

  Observable<bool> get internetExists => _internetExists.stream;

  BehaviorSubject<List<String>> _initErrorsSubject = BehaviorSubject<List<String>>();
  PublishSubject<bool> _showBTWarning = PublishSubject<bool>();

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

  Observable<bool> get initialChecksComplete => Observable.combineLatest2(
        internetExists,
        _initFiles(),
        (bool n, Response f) {
          _initErrorsSubject.add(List());
          if (!n) {
            addInitialErrors(lang.inet_unavailable);
          }
          if (!f.success) {
            addInitialErrors(f.error);
          }

          return true;
        },
      );

  bool getInternetConnectionState() => _internetExists.value;

  List<dynamic> getInitialErrors() => _initErrorsSubject.value;

  _bleStateHandler(BluetoothState state) {
    print('_bleStateHandler $state');
    _showBTWarning.sink.add(state != BluetoothState.on);
  }

  _connectivityStatusHandler(ConnectivityResult result) {
    _internetExists.sink.add(result != ConnectivityResult.none);
  }

  addInitialErrors(String err) {
    var currentList = _initErrorsSubject.value;
    currentList.add(err);
    _initErrorsSubject.add(currentList);
  }

  startInitialChecks(){

  }

  WelcomeActivityBloc() {
    _initErrorsSubject.add(List());

    initErrors.listen((errs) => print('MY LIST ${errs.toString()}'));

    _flutterBlue.onStateChanged().listen((BluetoothState s) {
      _bleStateSubject.sink.add(s);
    });

    _flutterBlue.state.then((BluetoothState s) {
      _bleStateSubject.sink.add(s);
    });

    _networkProvider.connectivity
        .checkConnectivity()
        .then((ConnectivityResult result) => _connectivityStatusHandler(result));

    _networkProvider.connectivity.onConnectivityChanged
        .listen((ConnectivityResult result) => _connectivityStatusHandler(result));

    _bleStateSubject.stream.map(_bleStateHandler).listen(print);
  }

  @override
  void dispose() {
    _initErrorsSubject.close();
    _showBTWarning.close();
    _bleStateSubject.close();
    _internetExists.close();
  }
}

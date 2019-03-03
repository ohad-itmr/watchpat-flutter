import 'dart:async';
import 'package:my_pat/bloc/helpers/bloc_base.dart';
import 'package:rxdart/rxdart.dart';
import 'package:my_pat/api/network_provider.dart';
import 'package:my_pat/generated/i18n.dart';


class NetworkBloc extends BlocBase {
  S lang;

  final _networkProvider = NetworkProvider();

  BehaviorSubject<bool> _internetExists = BehaviorSubject<bool>();

  Observable<bool> get internetExists => _internetExists.stream;

  StreamSubscription<bool> checkInternetExists() {
    return _networkProvider.internetExists
        .asStream()
        .listen((exists) => print('EXISTS: $exists'));
  }

  NetworkBloc(s) {
    lang=s;

    _networkProvider.internetExists
        .asStream()
        .listen((exists) => _internetExists.add(exists));
  }

  void dispose() {
    _internetExists.close();
  }
}

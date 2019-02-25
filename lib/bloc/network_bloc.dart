import 'dart:async';
import 'package:my_pat/bloc/bloc_base.dart';
import 'package:rxdart/rxdart.dart';
import 'package:my_pat/app/model/api/network_provider.dart';


class NetworkBloc extends BlocBase{
  final _networkProvider = NetworkProvider();

  Future<bool> internetExists() async {
    return await _networkProvider.internetExists;
  }

  void dispose() {
    // TODO: implement dispose
  }

}

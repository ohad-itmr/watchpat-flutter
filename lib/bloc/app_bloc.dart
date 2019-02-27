import 'package:my_pat/app/model/api/response.dart';
import 'package:rxdart/rxdart.dart';
import 'helpers/bloc_base.dart';
import 'helpers/bloc_provider.dart';
import 'package:flutter_blue/flutter_blue.dart';

class AppBloc extends BlocBase {
  NetworkBloc networkBloc;
  FileBloc fileBloc;
  PinBloc pinBloc;
  BleBloc bleBloc;

  Observable<bool> get initialChecksComplete => Observable.combineLatest3(
        networkBloc.internetExists,
        fileBloc.init(),
        bleBloc.state,
        (bool n, Response f, BluetoothState state) {
          // todo check for errors
          print('n $n');
          print('f ${f.success} ${f.error}');
          print('BLE State $state');
          return true;
        },
      );

  AppBloc() {
    print('[AppBloc constructor]');
    networkBloc = NetworkBloc();
    fileBloc = FileBloc();
    bleBloc = BleBloc();
    pinBloc = PinBloc();
  }

  @override
  void dispose() {
    networkBloc.dispose();
    fileBloc.dispose();
    pinBloc.dispose();
  }
}

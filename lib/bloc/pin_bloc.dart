import 'package:my_pat/bloc/bloc_base.dart';
import 'package:rxdart/rxdart.dart';

class PinBloc extends BlocBase{
  final _pin = BehaviorSubject<String>();

  Function(String) get changePin => _pin.sink.add;

  Observable<String> get pin => _pin.stream;

  resetPin() {
    _pin.sink.add('');
  }

  dispose() {
    _pin.close();
  }
}

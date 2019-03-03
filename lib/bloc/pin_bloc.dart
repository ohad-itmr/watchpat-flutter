import 'package:my_pat/bloc/helpers/bloc_base.dart';
import 'package:rxdart/rxdart.dart';
import 'package:my_pat/generated/i18n.dart';


class PinBloc extends BlocBase {
  S lang;

  String _pin = '';

  PublishSubject<String> _inputSubject = PublishSubject<String>();
  BehaviorSubject<String> _resultSubject = BehaviorSubject<String>();
  BehaviorSubject<bool> _pinIsValid = BehaviorSubject<bool>();

  Observable<String> get pin => _resultSubject.stream;

  Observable<bool> get pinIsValid => _pinIsValid.stream;

  void onPinChange(int value) {
    var newPin = '';
    if (value >= 0) {
      if (_pin.length < 4) {
        newPin = _pin + '$value';
        _inputSubject.add(newPin);
      }
    } else {
      if (_pin.length > 0) {
        newPin = _pin.substring(0, _pin.length - 1);
        _inputSubject.add(newPin);
      }
    }
  }

  resetPin() {
    _inputSubject.add('');
  }

  PinBloc(s) {
    lang=s;
    _inputSubject
        .map((newVal) => _pin = '$newVal')
        .listen((value) => _resultSubject.add(value));

    _resultSubject.listen((value) => _pinIsValid.add(value.length == 4));
  }

  dispose() {
    _inputSubject.close();
    _resultSubject.close();
    _pinIsValid.close();
  }
}

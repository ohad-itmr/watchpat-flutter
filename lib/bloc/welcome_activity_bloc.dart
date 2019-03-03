import 'package:my_pat/bloc/helpers/bloc_base.dart';
import 'package:my_pat/api/response.dart';
import 'package:rxdart/rxdart.dart';
import 'helpers/bloc_base.dart';
import 'package:my_pat/bloc/bloc_provider.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:my_pat/generated/i18n.dart';

class WelcomeActivityBloc extends BlocBase {
  AppBloc root;
  S lang;

  BehaviorSubject<List<String>> _initErrorsSubject = BehaviorSubject<List<String>>();
  PublishSubject<bool> _showBTWarning = PublishSubject<bool>();

  Observable<List<String>> get initErrors => _initErrorsSubject.stream;

  Observable<BluetoothState> get bleState => root.bleBloc.state;

  Observable<bool> get showBTWarning => _showBTWarning.stream;

  Observable<bool> get initialChecksComplete => Observable.combineLatest2(
        root.networkBloc.internetExists,
        root.fileBloc.init(),
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

  _bleStateHandler(BluetoothState state) {
    print('_bleStateHandler $state');
    _showBTWarning.sink.add(state != BluetoothState.on);
  }

  addInitialErrors(String err) {
    var currentList = _initErrorsSubject.value;
    currentList.add(err);
    _initErrorsSubject.add(currentList);
  }



  WelcomeActivityBloc(AppBloc root) {
    this.root = root;
    _initErrorsSubject.add(List());
    lang = S();
    initErrors.listen((err) => print('MY LIST ${err.toString()}'));
    bleState.map(_bleStateHandler).listen(print);
  }

  @override
  void dispose() {
    _initErrorsSubject.close();
    _showBTWarning.close();
  }
}

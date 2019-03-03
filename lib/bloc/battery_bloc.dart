import 'package:battery/battery.dart';
import 'dart:async';
import 'package:my_pat/bloc/helpers/bloc_base.dart';
import 'package:rxdart/rxdart.dart';
import 'package:my_pat/generated/i18n.dart';

class BatteryBloc extends BlocBase {
  S lang;


  Battery battery;
  BehaviorSubject<BatteryState> _batteryStateSubject = BehaviorSubject<BatteryState>();

  Observable<BatteryState> get batteryState => _batteryStateSubject.stream;

  Stream<int> get batteryLevel => getBatteryLevel().asStream();

  Future<int> getBatteryLevel() async {
    var level = await battery.batteryLevel;
    return level;
  }

  BatteryBloc(s) {
    lang=s;
    battery = Battery();
    battery.onBatteryStateChanged.listen((BatteryState state) {
      _batteryStateSubject.add(state);
    });
  }

  @override
  void dispose() {
    _batteryStateSubject.close();
  }
}

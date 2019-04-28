import 'package:battery/battery.dart';
import 'dart:async';
import 'package:my_pat/managers/manager_base.dart';
import 'package:rxdart/rxdart.dart';

class BatteryManager extends ManagerBase {
  static const String TAG = 'BatteryManager';

  Battery battery;
  BehaviorSubject<BatteryState> _batteryStateSubject =
      BehaviorSubject<BatteryState>();

  Observable<BatteryState> get batteryState => _batteryStateSubject.stream;

  Stream<int> get batteryLevel => getBatteryLevel().asStream();

  Future<int> getBatteryLevel() async {
    var level = await battery.batteryLevel;
    return level;
  }

  Future<BatteryState> getBatteryState() async {
    return await batteryState.first;
  }

  BatteryManager() {
    battery = Battery();
    battery.onBatteryStateChanged.listen((BatteryState state) {
      _batteryStateSubject.add(state);
    });
    battery.batteryState.then((state) => _batteryStateSubject.add(state));
  }

  @override
  void dispose() {
    _batteryStateSubject.close();
  }
}

import 'dart:async';

import 'package:battery/battery.dart';
import 'package:my_pat/managers/managers.dart';
import 'package:my_pat/service_locator.dart';

class RecordingManager extends ManagerBase {
  static const String TAG = 'RecordingManager';
  BatteryManager _batteryManager;

  RecordingManager() {
    _batteryManager = sl<BatteryManager>();
  }

  Future<bool> get canStartRecording async {
    final BatteryState state = await _batteryManager.getBatteryState();
    final int level = await _batteryManager.getBatteryLevel();
    return level >= 95 || state == BatteryState.charging;
  }

  @override
  void dispose() {}
}

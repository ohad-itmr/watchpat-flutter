import 'dart:async';

import 'package:battery/battery.dart';
import 'package:my_pat/config/default_settings.dart';
import 'package:my_pat/managers/managers.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/log/log.dart';

class TestingManager extends ManagerBase {
  static const String TAG = 'RecordingManager';
  BatteryManager _batteryManager;
  SystemStateManager _systemStateManager;

  TestingManager() {
    _batteryManager = sl<BatteryManager>();
    _systemStateManager = sl<SystemStateManager>();
  }

  Future<bool> get canStartTesting async {
//    final BatteryState state = await _batteryManager.getBatteryState();
//    final int level = await _batteryManager.getBatteryLevel();
//    return level >= DefaultSettings.minBatteryLevel || state == BatteryState.charging;
  // todo implement get instant battery state
    return true;
  }

  void startTesting() {
    Log.info(TAG, "### Sending start aquisition command");
    _systemStateManager.setTestState(TestStates.STARTED);
    _systemStateManager.changeState.add(StateChangeActions.TEST_STATE_CHANGED);
  }

  void resumeTesting() {
    sl<BleManager>().startScan(time: 3000, connectToFirstDevice: false);
  }

  @override
  void dispose() {}
}

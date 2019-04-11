import 'dart:async';

import 'package:battery/battery.dart';
import 'package:my_pat/config/default_settings.dart';
import 'package:my_pat/domain_model/device_commands.dart';
import 'package:my_pat/managers/managers.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/log/log.dart';

class TestingManager extends ManagerBase {
  static const String TAG = 'RecordingManager';
  BatteryManager _batteryManager;
  CommandTaskerManager _commandTaskerManager;
  SystemStateManager _systemStateManager;

  TestingManager() {
    _batteryManager = sl<BatteryManager>();
    _commandTaskerManager = sl<CommandTaskerManager>();
    _systemStateManager = sl<SystemStateManager>();
  }

  Future<bool> get canStartTesting async {
    final BatteryState state = await _batteryManager.getBatteryState();
    final int level = await _batteryManager.getBatteryLevel();
    return level >= DefaultSettings.minBatteryLevel || state == BatteryState.charging;
  }

  void startTesting() {
    Log.info(TAG, "### Sending start aquisition command");
    _systemStateManager.setTestState(TestStates.STARTED);
    _systemStateManager.changeState.add(StateChangeActions.TEST_STATE_CHANGED);
//    _systemStateManager.deviceCommStateStream.listen(_deviceConnectionStateListener);
  }

  void _deviceConnectionStateListener(DeviceStates state) {
    print("CURRENT DEVICE STATE $state");
  }

  @override
  void dispose() {}
}

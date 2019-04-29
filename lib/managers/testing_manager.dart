import 'dart:async';

import 'package:battery/battery.dart';
import 'package:my_pat/config/default_settings.dart';
import 'package:my_pat/domain_model/device_commands.dart';
import 'package:my_pat/managers/managers.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/log/log.dart';
import 'package:rxdart/rxdart.dart';

class TestingManager extends ManagerBase {
  static const String TAG = 'RecordingManager';
  BatteryManager _batteryManager;
  SystemStateManager _systemStateManager;

  // Timer of test data amount
  BehaviorSubject<int> _timer = BehaviorSubject<int>();
  Observable<int> get timer => _timer.stream;

  TestingManager() {
    _batteryManager = sl<BatteryManager>();
    _systemStateManager = sl<SystemStateManager>();
  }

  Future<bool> get canStartTesting async {
    final BatteryState state = await _batteryManager.getBatteryState();
    final int level = await _batteryManager.getBatteryLevel();
    return level >= DefaultSettings.minBatteryLevel || state == BatteryState.charging;
  }

  void startTesting() {
    Log.info(TAG, "### Sending START aquisition command");
    sl<CommandTaskerManager>()
        .addCommandWithNoCb(DeviceCommands.getStartAcquisitionCmd());
    sl<NotificationsService>().showLocalNotification("Test in progress");
    _startTimer();
  }

  void _startTimer() async {
    do {
      final int testPacketTime = await PrefsProvider.loadTestPacketTime();
      final int delta = GlobalSettings.minTestLengthSeconds - testPacketTime;
      _timer.sink.add(delta > 0 ? delta : 0);
      await Future.delayed(Duration(seconds: 1));
    } while (_systemStateManager.testState != TestStates.ENDED);
  }

  bool stopTesting() {
    final TestStates testState = _systemStateManager.testState;
    if (testState == TestStates.MINIMUM_PASSED) {
      Log.info(TAG, "### Sending STOP aquisition command");
      sl<CommandTaskerManager>()
          .addCommandWithNoCb(DeviceCommands.getStopAcquisitionCmd());
      return true;
    } else {
      return false;
    }
  }

  void resumeTesting() {
    sl<BleManager>().startScan(time: 3000, connectToFirstDevice: false);
  }

  @override
  void dispose() {
    _timer.close();
  }
}

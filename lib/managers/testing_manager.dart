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
  BehaviorSubject<int> _dataTimerState = BehaviorSubject<int>();
  Observable<int> get dataTimerStream => _dataTimerState.stream;

  // Timer of elapsed test time
  BehaviorSubject<int> _elapsedTimerState = BehaviorSubject<int>();
  Observable<int> get elapsedTimeStream => _elapsedTimerState.stream;

  Timer _elapsedTimer;
  int _elapsedTimerValue = 0;

  TestingManager() {
    _batteryManager = sl<BatteryManager>();
    _systemStateManager = sl<SystemStateManager>();
  }

  Future<bool> get canStartTesting async {
    final BatteryState state = await _batteryManager.getBatteryState();
    final int level = await _batteryManager.getBatteryLevel();
    return level >= DefaultSettings.minBatteryRequiredLevel || state == BatteryState.charging;
  }

  void startTesting() {
    Log.info(TAG, "### Sending START aquisition command");
    sl<CommandTaskerManager>()
        .addCommandWithNoCb(DeviceCommands.getStartAcquisitionCmd());
    sl<NotificationsService>().showLocalNotification("Test in progress");
    _startDataTimer();
    _startElapsedTimer();
  }

  void restartTimers() {
    _startDataTimer();
    _elapsedTimerValue = PrefsProvider.loadTestElapsedTime();
    _startElapsedTimer();
  }

  void _startDataTimer() async {
    do {
      final int testPacketTime = await PrefsProvider.loadTestPacketTime();
      final int delta = GlobalSettings.minTestLengthSeconds - testPacketTime;
      _dataTimerState.sink.add(delta > 0 ? delta : 0);
      await Future.delayed(Duration(seconds: 1));
    } while (_systemStateManager.testState != TestStates.ENDED);
  }

  void _startElapsedTimer() {
    _elapsedTimer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      _elapsedTimerState.sink.add(++_elapsedTimerValue);
      PrefsProvider.saveTestElapsedTime(_elapsedTimerValue);
    });
  }

  bool stopTesting() {
    final TestStates testState = _systemStateManager.testState;
    if (testState == TestStates.MINIMUM_PASSED) {
      Log.info(TAG, "### Sending STOP aquisition command");
      sl<CommandTaskerManager>()
          .addCommandWithNoCb(DeviceCommands.getStopAcquisitionCmd());
      _elapsedTimer.cancel();
      return true;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    _dataTimerState.close();
    _elapsedTimerState.close();
  }
}

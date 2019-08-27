import 'dart:async';

import 'package:battery/battery.dart';
import 'package:my_pat/config/default_settings.dart';
import 'package:my_pat/domain_model/device_commands.dart';
import 'package:my_pat/managers/managers.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/log/log.dart';
import 'package:my_pat/utils/time_utils.dart';
import 'package:rxdart/rxdart.dart';

class TestingManager extends ManagerBase {
  static const String TAG = 'RecordingManager';
  static const int PROGRESS_BAR_UPDATE_PERIOD = 100;
  BatteryManager _batteryManager;
  SystemStateManager _systemStateManager;

  // Timer of elapsed test time
  BehaviorSubject<int> _elapsedTimerState = BehaviorSubject<int>();

  Observable<int> get elapsedTimeStream => _elapsedTimerState.stream;

  // remaining data receiving streams
  BehaviorSubject<int> _remainingDataSeconds = BehaviorSubject<int>.seeded(0);

  Observable<int> get remainingDataSecondsStream => _remainingDataSeconds.stream;

  BehaviorSubject<double> _remainingDataProgress = BehaviorSubject<double>.seeded(0.0);

  Observable<double> get remainingDataProgressStream => _remainingDataProgress.stream;

  Timer _elapsedTimer;
  int _numberOfSecondsToDownloadAllPackets;
  int _maxProgress;
  int _testStoppedTimeMS;

  TestingManager() {
    _batteryManager = sl<BatteryManager>();
    _systemStateManager = sl<SystemStateManager>();
    _restartTimers();
  }

  Future<bool> get canStartTesting async {
    final BatteryState state = await _batteryManager.getBatteryState();
    final int level = await _batteryManager.getBatteryLevel();
    return level >= DefaultSettings.minBatteryRequiredLevel || state == BatteryState.charging;
  }

  void startTesting() {
    Log.info(TAG, "### Sending START aquisition command");
    PrefsProvider.saveTestStartTime(DateTime.now().millisecondsSinceEpoch);
    sl<CommandTaskerManager>().addCommandWithNoCb(DeviceCommands.getStartAcquisitionCmd());
    _startElapsedTimer();
  }

  void _restartTimers() {
    if (_systemStateManager.testState == TestStates.INTERRUPTED ||
        _systemStateManager.testState == TestStates.STOPPED) {
      _startElapsedTimer();
    }
  }

  void _startElapsedTimer() {
    _elapsedTimer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      final int val = TimeUtils.getTimeFromTestStartSec();
      _elapsedTimerState.sink.add(val);
      checkForSessionTimeout();
    });
  }

  void _stopElapsedTimer() {
    if (_elapsedTimer != null && _elapsedTimer.isActive) {
      _elapsedTimer.cancel();
    }
  }

  bool checkForSessionTimeout() {
    final bool sessionTimedOut = TimeUtils.getTimeFromTestStartSec() > GlobalSettings.sessionTimeoutTimeSec;
    if (sessionTimedOut) {
      Log.info(TAG, "Session timeout triggered. Stopping test.");
      if (sl<SystemStateManager>().deviceCommState == DeviceStates.CONNECTED) {
        stopTesting();
      } else {
        forceEndTesting();
      }
    }
    return sessionTimedOut;
  }

  void stopButtonPressed() {
    if (sl<SystemStateManager>().deviceCommState == DeviceStates.CONNECTED) {
      stopTesting();
    } else {
      forceEndTesting();
    }
  }

  void stopTesting() {
    Log.info(TAG, "### STOPPING TEST");
    _systemStateManager.setTestState(TestStates.STOPPED);
    sl<CommandTaskerManager>().addCommandWithNoCb(DeviceCommands.getStopAcquisitionCmd());
    _initDataProgress();
    _stopElapsedTimer();
  }

  void forceEndTesting() {
    Log.info(TAG, "### FORCING TEST TO STOP");
    sl<SystemStateManager>().setTestState(TestStates.ENDED);
    sl<SystemStateManager>().setDataTransferState(DataTransferState.ENDED);
    sl<SystemStateManager>().setScanCycleEnabled = false;
    _stopElapsedTimer();
  }

  void _initDataProgress() {
    _testStoppedTimeMS = DateTime.now().millisecondsSinceEpoch;
    _maxProgress = _getPacketTimeDiffFromStopTest();
    _startDataProgress();
  }

  void _startDataProgress() async {
    do {
      _numberOfSecondsToDownloadAllPackets = _getPacketTimeDiffFromStopTest();
      updateProgressBar(0);
      updateProgressTime();
      await Future.delayed(Duration(milliseconds: PROGRESS_BAR_UPDATE_PERIOD));
    } while (sl<SystemStateManager>().testState != TestStates.ENDED);
  }

  int _getPacketTimeDiffFromStopTest() {
    return (_testStoppedTimeMS - PrefsProvider.loadTestStartTimeMS()) ~/ 1000 -
        PrefsProvider.loadTestPacketCount();
  }

  void updateProgressBar(int changeDelta) {
//    print("PROGRESS: ${(_maxProgress - _numberOfSecondsToDownloadAllPackets)} / $_maxProgress");
    final double newProgress = (_maxProgress - _numberOfSecondsToDownloadAllPackets) / _maxProgress;
    _remainingDataProgress.sink.add(newProgress);
  }

  void updateProgressTime() {
    final int secs = _numberOfSecondsToDownloadAllPackets ~/ 2;
    _remainingDataSeconds.sink.add(secs > 0 ? secs : 0);
  }

  @override
  void dispose() {
    _elapsedTimerState.close();
    _remainingDataSeconds.close();
    _remainingDataProgress.close();
  }
}

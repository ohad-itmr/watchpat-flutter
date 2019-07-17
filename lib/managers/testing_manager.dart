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

  Observable<int> get remainingDataSecondsStream =>
      _remainingDataSeconds.stream;

  BehaviorSubject<double> _remainingDataProgress =
      BehaviorSubject<double>.seeded(0.0);

  Observable<double> get remainingDataProgressStream =>
      _remainingDataProgress.stream;

  Timer _elapsedTimer;
  int _elapsedTimerValue = 0;

  int _numberOfSecondsToDownloadAllPackets;
  int _currentProgress;
  int _maxProgress;

  TestingManager() {
    _batteryManager = sl<BatteryManager>();
    _systemStateManager = sl<SystemStateManager>();
    _restartTimers();
  }

  Future<bool> get canStartTesting async {
    final BatteryState state = await _batteryManager.getBatteryState();
    final int level = await _batteryManager.getBatteryLevel();
    return level >= DefaultSettings.minBatteryRequiredLevel ||
        state == BatteryState.charging;
  }

  void startTesting() {
    Log.info(TAG, "### Sending START aquisition command");
    sl<CommandTaskerManager>()
        .addCommandWithNoCb(DeviceCommands.getStartAcquisitionCmd());
    _startElapsedTimer();
  }

  void _restartTimers() {
    if (_systemStateManager.testState == TestStates.INTERRUPTED) {
      _elapsedTimerValue = PrefsProvider.loadTestElapsedTime();
      _startElapsedTimer();
    }
  }

  void _startElapsedTimer() {
    _elapsedTimer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      _elapsedTimerState.sink.add(++_elapsedTimerValue);
      PrefsProvider.saveTestElapsedTime(_elapsedTimerValue);
    });
  }

  void  stopTesting() {
    Log.info(TAG, "### Sending STOP acquisition command");
    _systemStateManager.setTestState(TestStates.STOPPED);
    sl<CommandTaskerManager>()
        .addCommandWithNoCb(DeviceCommands.getStopAcquisitionCmd());
    _initDataProgress();
    _elapsedTimer.cancel();
  }

  void forceEndTesting() {
    Log.info(TAG, "Forcing end test");
    sl<SystemStateManager>().setTestState(TestStates.ENDED);
    sl<SystemStateManager>().setDataTransferState(DataTransferState.ENDED);
  }

  void _initDataProgress() {
    _numberOfSecondsToDownloadAllPackets = TimeUtils.getPacketRealTimeDiffSec();
    _currentProgress = 0;
    _maxProgress = _numberOfSecondsToDownloadAllPackets;
    _startDataProgress();
  }

  void _startDataProgress() async {
    do {
      // calculate number of seconds left to download the data
      _numberOfSecondsToDownloadAllPackets =
          TimeUtils.getPacketRealTimeDiffSec();

      // when time is growing then there is no communication with device.
      // in this case update timer only and don't touch progress bar
      if (_numberOfSecondsToDownloadAllPackets < _maxProgress) {
        // time is decreasing, some packets has been transmitted so recalculate progress bar value now
        int changeDelta = _maxProgress - _numberOfSecondsToDownloadAllPackets;
        updateProgressBar(changeDelta);
      } else {
        _maxProgress = _numberOfSecondsToDownloadAllPackets;
      }
      updateProgressTime();
      await Future.delayed(Duration(milliseconds: PROGRESS_BAR_UPDATE_PERIOD));
    } while (sl<SystemStateManager>().testState != TestStates.ENDED);
  }

  void updateProgressBar(int changeDelta) {
    if (changeDelta <= 0) return;

    double currentProgress = _remainingDataProgress.value * 100;
    double currentMax = 100;

    // calculate new progress according to value
    double newProgress = currentProgress +
        ((currentMax - currentProgress) *
            changeDelta /
            (_maxProgress - _currentProgress));

    newProgress =
        newProgress.isNaN || newProgress.isInfinite ? 100 : newProgress;

//    print("PROGRESS: ${currentProgress / 100} / ${newProgress / 100}");

    _remainingDataProgress.sink.add(newProgress / 100);

    _currentProgress += changeDelta;
  }

  void updateProgressTime() {
    _remainingDataSeconds.sink.add(_numberOfSecondsToDownloadAllPackets > 0
        ? _numberOfSecondsToDownloadAllPackets
        : 0);
  }

  @override
  void dispose() {
    _elapsedTimerState.close();
    _remainingDataSeconds.close();
    _remainingDataProgress.close();
  }
}

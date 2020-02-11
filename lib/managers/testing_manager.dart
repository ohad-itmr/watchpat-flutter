import 'dart:async';

import 'package:battery/battery.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:my_pat/config/default_settings.dart';
import 'package:my_pat/domain_model/command_task.dart';
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
  Timer _sftpIncompleteTimer;
  int _numberOfSecondsToDownloadAllPackets;

//  int _maxProgress;
//  int _testStoppedTimeMS;

  TestingManager() {
    _batteryManager = sl<BatteryManager>();
    _systemStateManager = sl<SystemStateManager>();
    _restartTimers();
  }

  Future<bool> get canStartTesting async {
    final BatteryState state = await _batteryManager.getBatteryState();
    return state != BatteryState.discharging;
  }

  void startTesting() {
    Log.info(TAG, "### Starting test");
    PrefsProvider.saveTestStartTime(DateTime.now().millisecondsSinceEpoch);
    final CommandTask cmd = DeviceCommands.getStartAcquisitionCmd();
    IncomingPacketHandlerService.startAcquisitionCmdId = cmd.packetIdentifier;
    sl<CommandTaskerManager>().addCommandWithNoCb(cmd);

    sl<DeviceConfigManager>().deviceConfig.updateStartTime(DateTime.now().millisecondsSinceEpoch);
    sl<DataWritingService>().writeToLocalFile(DataPacket(data: sl<DeviceConfigManager>().deviceConfig.payloadBytes, id: -1));

    _startTestTimers();
  }

  void _restartTimers() {
    if (_systemStateManager.testState == TestStates.INTERRUPTED || _systemStateManager.testState == TestStates.STOPPED) {
      _startTestTimers();
    }
  }

  void _startTestTimers() {
    TimeUtils.enableTestTicker();
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

//  void _startSftpTimer() {
//    _sftpIncompleteTimer = Timer(Duration(seconds: 10), () {
//      final AppLifecycleState state = WidgetsBinding.instance.lifecycleState;
//      if (_systemStateManager.sftpUploadingState != SftpUploadingState.ALL_UPLOADED && state != AppLifecycleState.resumed) {
//        sl<NotificationsService>().showLocalNotification(
//            "Data from WatchPAT ONE device finished transferring. Please open the application to upload data to your doctor.");
//        _sftpIncompleteTimer = null;
//      }
//    });
//  }

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
      sl<SystemStateManager>().setTestState(TestStates.STOPPED);
      _waitForDeviceConnectionToEndTest();
    }
  }

  void _waitForDeviceConnectionToEndTest() {
    _systemStateManager.deviceCommStateStream
        .firstWhere((st) => st == DeviceStates.CONNECTED)
        .then((_) => Future.delayed(Duration(seconds: 1)).then((_) => stopTesting()));
  }

  void stopTesting() {
    Log.info(TAG, "### STOPPING TEST");
    _systemStateManager.setTestState(TestStates.STOPPED);
    sl<CommandTaskerManager>().addCommandWithCb(DeviceCommands.getStopAcquisitionCmd(), listener: TestStopCallback());
    TransactionManager.platformChannel.invokeMethod("disableAutoSleep");
    _initDataProgress();
    _stopElapsedTimer();
//    _startSftpTimer();
  }

  void forceEndTesting() {
    Log.info(TAG, "### FORCING TEST TO STOP");
    sl<SystemStateManager>().setTestState(TestStates.ENDED);
    sl<SystemStateManager>().setDataTransferState(DataTransferState.ENDED);
    sl<SystemStateManager>().setScanCycleEnabled = false;
    TransactionManager.platformChannel.invokeMethod("disableAutoSleep");
    _stopElapsedTimer();
//    _startSftpTimer();
  }

  void _initDataProgress() {
//    _testStoppedTimeMS = DateTime.now().millisecondsSinceEpoch;
    PrefsProvider.saveTestStopTime(DateTime.now().millisecondsSinceEpoch);
//    _maxProgress = _getPacketTimeDiffFromStopTest();
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
    return (PrefsProvider.loadTestStopTimeMS() - PrefsProvider.loadTestStartTimeMS()) ~/ 1000 - PrefsProvider.loadTestPacketCount();
  }

  void updateProgressBar(int changeDelta) {
    final int maxProgress = _getPacketTimeDiffFromStopTest();
    final double newProgress = (maxProgress - _numberOfSecondsToDownloadAllPackets) / maxProgress;
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

class TestStopCallback implements OnAckListener {
  @override
  void onAckReceived() {
    final int time = DateTime.now().millisecondsSinceEpoch;
    Log.info("TestStopCallback",
        "Acquisition stopped, saving time: ${TimeUtils.getFullDateStringFromTimeStamp(DateTime.fromMicrosecondsSinceEpoch(time))}");
    PrefsProvider.saveTestStopTime(time);
    sl<SystemStateManager>().setTestState(TestStates.STOPPED);
  }
}

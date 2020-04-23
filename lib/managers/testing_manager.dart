import 'dart:async';

import 'package:battery/battery.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_pat/config/default_settings.dart';
import 'package:my_pat/domain_model/command_task.dart';
import 'package:my_pat/domain_model/device_commands.dart';
import 'package:my_pat/managers/managers.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/log/log.dart';
import 'package:my_pat/utils/time_utils.dart';
import 'package:rxdart/rxdart.dart';

class TestingManager extends ManagerBase with WidgetsBindingObserver {
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

    sl<SftpService>().uploadLogFile();
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
      stopAcquisitionOnDeviceConnect();
    }
  }

  StreamSubscription _stopAcquisitionSub;

  void stopAcquisitionOnDeviceConnect() {
    _stopAcquisitionSub =
        sl<SystemStateManager>().deviceCommStateStream.where((state) => state == DeviceStates.CONNECTED).listen((_) async {
      if (!sl<SystemStateManager>().stopAcquisitionConfirmed) {
        await Future.delayed(Duration(seconds: 2));
        sl<CommandTaskerManager>().addCommandWithCb(DeviceCommands.getStopAcquisitionCmd(), listener: TestStopCallback());
      } else {
        _stopAcquisitionSub.cancel();
      }
    });
  }

  void stopTesting() {
    Log.info(TAG, "### STOPPING TEST");
    _systemStateManager.setTestState(TestStates.STOPPED);
    sl<CommandTaskerManager>().addCommandWithCb(DeviceCommands.getStopAcquisitionCmd(), listener: TestStopCallback());
    TransactionManager.platformChannel.invokeMethod("disableAutoSleep");
    _stopElapsedTimer();
  }

  void forceEndTesting() {
    Log.info(TAG, "### FORCING TEST END");

    if (sl<SystemStateManager>().appLifecycleState == AppLifecycleState.paused) {
      sl<NotificationsService>().showLocalNotification(
          "Data from WatchPAT device finished transferring. Please open the application to upload data to your doctor.");
    }

    sl<SystemStateManager>().setTestState(TestStates.ENDED);
    sl<SystemStateManager>().setDataTransferState(DataTransferState.ENDED);
    sl<SystemStateManager>().setScanCycleEnabled = false;
    TransactionManager.platformChannel.invokeMethod("disableAutoSleep");
    _stopElapsedTimer();
  }

  bool _dataProgressInitialized = false;

  void initDataProgress() {
    if (_dataProgressInitialized) {
      return;
    } else {
      _dataProgressInitialized = true;
    }
    _startDataProgress();
  }

  void _startDataProgress() async {
    do {
      final int maxProgress = TimeUtils.getFullTestTimeSec() - PrefsProvider.loadPacketsCountOnStop();
      final int currentProgress = maxProgress - (TimeUtils.getFullTestTimeSec() - PrefsProvider.loadTestPacketCount());

      updateProgressBar(currentProgress, maxProgress);
      updateProgressTime(currentProgress, maxProgress);

      await Future.delayed(Duration(milliseconds: PROGRESS_BAR_UPDATE_PERIOD));
    } while (sl<SystemStateManager>().testState != TestStates.ENDED);
  }

  void updateProgressBar(int progress, int maxProgress) {
    final double newProgress = progress / maxProgress;
    _remainingDataProgress.sink.add(newProgress);
  }

  void updateProgressTime(int progress, int maxProgress) {
    final int secs = (maxProgress - progress) ~/ 5;
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
    PrefsProvider.savePacketsCountOnStop(PrefsProvider.loadTestPacketCount());
    sl<TestingManager>().initDataProgress();
    sl<SystemStateManager>().setTestState(TestStates.STOPPED);
    sl<SystemStateManager>().setStopAcquisitionConfirmed();
  }
}

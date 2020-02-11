import 'dart:async';

import 'package:intl/intl.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/services/prefs_service.dart';
import 'package:my_pat/services/services.dart';
import 'package:my_pat/utils/log/log.dart';
import 'package:date_format/date_format.dart';
import 'package:sprintf/sprintf.dart';

abstract class TimerCallback {
  void callback();
}

class TimeUtils {
  static const String TAG = 'TimeUtils';

  static const int TICK_SPAN = 1000;
  static const int TIME_DIFF_PACKET_REAL_SEC = 5;
  static const int TIME_DIFF_TEST_START_FIRST_DATA_SEC = 9;
  static int lastPacketTime = 0;

  static Timer _tickerTimer;

  static void _packetCounterTick() async {
    final int testPacketCount = PrefsProvider.loadTestPacketCount();
    if (getTimeFromTestStartSec() > GlobalSettings.minTestLengthSeconds) {
      sl<SystemStateManager>().setTestDataAmountState(TestDataAmountState.MINIMUM_PASSED);
    }
    if (testPacketCount > GlobalSettings.maxTestLengthSeconds * (GlobalSettings.dataTransferRate / 60) &&
        !PrefsProvider.getTestStoppedByUser()) {
      Log.info(TAG, "Maximum test length triggered. Stopping test.");
      sl<TestingManager>().stopTesting();
    }
  }

  static String getFullDateStringFromTimeStamp(DateTime timeStamp) {
    final String pattern = "yyyy.MM.dd_HH-mm-ss";
    return DateFormat(pattern).format(timeStamp);
  }

  static int getTimeStamp() {
    final DateTime now = DateTime.now();
    final int currMillis = now.millisecondsSinceEpoch;
    Log.info(TAG, "## current time: ${getFullDateStringFromTimeStamp(now)}");
    return (currMillis + getGMTDiffMillis()) ~/ 1000;
  }

  static int getGMTDiffMillis() {
    return DateTime.now().timeZoneOffset.inMilliseconds;
  }

  static String convertSecondsToHMmSs(int sec) {
    double seconds = sec.toDouble();
    double s = seconds % 60;
    double m = (seconds / 60) % 60;
    double h = (seconds / (60 * 60)) % 24;
    return sprintf("%02d:%02d:%02d", [h.toInt(), m.toInt(), s.toInt()]);
  }

  static int getPacketRealTimeDiffSec() {
    return getTimeFromTestStartSec() - PrefsProvider.loadTestPacketCount();
  }

  static int getTimeFromTestStartSec() {
    if (PrefsProvider.loadTestStartTimeMS() != 0) {
      return (DateTime.now().millisecondsSinceEpoch - PrefsProvider.loadTestStartTimeMS()) ~/ 1000;
    } else {
      return 0;
    }
  }

  static int getFullTestTimeSec() {
    return (PrefsProvider.loadTestStopTimeMS() - PrefsProvider.loadTestStartTimeMS()) ~/ 1000;
  }

  static void enableTestTicker() {
    disableTestTicker();
    _tickerTimer = Timer.periodic(Duration(seconds: 1), (_) => _packetCounterTick());
  }

  static void disableTestTicker() {
    if (_tickerTimer != null && _tickerTimer.isActive) {
      _tickerTimer.cancel();
    }
    _tickerTimer = null;
  }
}
//
//class WatchPATTimer {
//  static const String TAG = 'WatchPATTimer';
//
//  String _name;
//  int _interval;
//  Timer _timer;
//
//  Function _timeoutCallback;
//  Function _startCallback;
//
//  bool _isRunning;
//  bool _isCycle;
//
//  void onFinish() {
//    Log.info(TAG, "$_name triggered, $this");
//    _timeoutCallback();
//    _isRunning = false;
//    if (_isCycle) {
//      startTimer();
//    }
//  }
//
//  void startTimer() {
//    if (!_isRunning) {
//      if (_startCallback != null) {
//        Log.info(TAG, "$_name started");
//        _startCallback();
//      }
//      _isRunning = true;
//      _timer = Timer(Duration(milliseconds: _interval), _startCallback);
//    }
//  }
//
//  void stopTimer() {
//    if (_isRunning) {
//      _timer.cancel();
//      _isRunning = false;
//    }
//  }
//
//  void restart() {
//    stopTimer();
//    startTimer();
//  }
//
//  WatchPATTimer(this._name, this._interval, this._timeoutCallback) {
//    _startCallback = null;
//    _isRunning = false;
//    _isCycle = false;
//  }
//
//  WatchPATTimer.withStartCallback(
//    this._name,
//    this._interval,
//    this._timeoutCallback,
//    this._startCallback,
//    this._isCycle,
//  ) {
//    _isRunning = false;
//  }
//}

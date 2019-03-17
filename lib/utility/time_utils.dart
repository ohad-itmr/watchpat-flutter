import 'dart:async';

import 'package:my_pat/utility/log/log.dart';
import 'package:date_format/date_format.dart';

abstract class TimerCallback {
  void callback();
}

class TimeUtils {
  static const int TICK_SPAN = 1000;
  static const int TIME_DIFF_PACKET_REAL_SEC = 5;
  static const int TIME_DIFF_TEST_START_FIRST_DATA_SEC = 9;
  static int lastPacketTime = 0;

  static String getFullDateStringFromTimeStamp(DateTime timeStamp) {
    return formatDate(timeStamp, [dd, '-', MM, '-', yyyy, '_', HH, ':', mm, ':', ss]);
  }

  static double getTimeStamp() {
    final DateTime now = DateTime.now();
    final int currMillis = now.millisecond;
    Log.info("## current time: ${getFullDateStringFromTimeStamp(now)}");
    return (currMillis + getGMTDiffMillis()) / 1000;
  }

  static int getGMTDiffMillis() {
    return DateTime.now().timeZoneOffset.inMilliseconds;
  }
}

class WatchPATTimer {

  String _name;
  int _interval;
  Timer _timer;

  Function _timeoutCallback;
  Function _startCallback;

  bool _isRunning;
  bool _isCycle;

  void onFinish() {
    Log.info("$_name triggered, $this");
    _timeoutCallback();
    _isRunning = false;
    if (_isCycle) {
      startTimer();
    }
  }

  void startTimer() {
    if (!_isRunning) {
      if (_startCallback != null) {
        Log.info("$_name started");
        _startCallback();
      }
      _isRunning = true;
      _timer = Timer(Duration(milliseconds: _interval), _startCallback);
    }
  }

  void stopTimer() {
    if (_isRunning) {
      _timer.cancel();
      _isRunning = false;
    }
  }

  void restart() {
    stopTimer();
    startTimer();
  }

  WatchPATTimer(this._name, this._interval, this._timeoutCallback) {
    _startCallback = null;
    _isRunning = false;
    _isCycle = false;
  }

  WatchPATTimer.withStartCallback(
    this._name,
    this._interval,
    this._timeoutCallback,
    this._startCallback,
    this._isCycle,
  ) {
    _isRunning = false;
  }
}

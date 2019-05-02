import 'dart:async';

import 'package:my_pat/service_locator.dart';
import 'package:rxdart/rxdart.dart';

class ServiceScreenManager extends ManagerBase {
  Stopwatch _clickTimer = Stopwatch();
  int _clickCounter = 1;

  BehaviorSubject<String> _counter = BehaviorSubject<String>();

  Observable<String> get counter => _counter.stream;

  void onTitleTap() {
    if (_clickTimer.isRunning) {
      if (_clickTimer.elapsedMilliseconds < 1000) {
        _clickTimer.reset();
        _clickCounter++;
      } else {
        _clickTimer.stop();
        _clickTimer.reset();
        _clickCounter = 1;
      }
    } else {
      _clickTimer.start();
      _clickCounter++;
    }

    _handleCounterState();
  }

  void _handleCounterState() async {
    _counter.sink.add(_clickCounter > 3 ? _clickCounter.toString() : "");

    if (_clickCounter == 7) {
      _enterCustomerServiceMode();
    } else if (_clickCounter == 10) {
      _enterTechnicianMode();
    }

    await Future.delayed(Duration(seconds: 4));
    _counter.sink.add("");
  }

  _enterCustomerServiceMode() {
    Timer(Duration(seconds: 4), () {
      print("CUSTOMER CLICK COUNTER NOW: $_clickCounter");
    });
  }

  _enterTechnicianMode() {
    print("TECHNITIAN MODE YOOOO");
  }

  @override
  void dispose() {
    _counter.close();
  }
}

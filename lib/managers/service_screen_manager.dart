import 'dart:async';

import 'package:my_pat/service_locator.dart';
import 'package:rxdart/rxdart.dart';

enum ServiceMode { customer, technician }

class ServiceScreenManager extends ManagerBase {
  Stopwatch _clickTimer = Stopwatch();
  int _clickCounter = 1;

  PublishSubject<String> _counter = PublishSubject<String>();

  Observable<String> get counter => _counter.stream;

  BehaviorSubject<ServiceMode> _serviceMode = BehaviorSubject<ServiceMode>();

  Observable<ServiceMode> get serviceModesStream => _serviceMode.stream;

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
    Timer(Duration(seconds: 2), () {
      if (_clickCounter == 7) {
        _serviceMode.sink.add(ServiceMode.customer);
      }
    });
  }

  _enterTechnicianMode() {
    _serviceMode.sink.add(ServiceMode.technician);
  }

  @override
  void dispose() {
    _serviceMode.close();
    _counter.close();
  }
}

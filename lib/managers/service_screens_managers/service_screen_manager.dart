import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_pat/domain_model/device_commands.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/ParameterFileHandler.dart';
import 'package:my_pat/utils/log/log.dart';
import 'package:rxdart/rxdart.dart';

enum ServiceMode { customer, technician }

class ServiceScreenManager extends ManagerBase {
  static const String TAG = "ServiceScreenManager";
  final S _loc = sl<S>();

  Stopwatch _clickTimer = Stopwatch();
  int _clickCounter = 1;
  Timer _countDown;

  ParameterFileHandler _paramFileHandler = sl<ParameterFileHandler>();

  PublishSubject<String> _counter = PublishSubject<String>();

  Observable<String> get counter => _counter.stream;

  BehaviorSubject<ServiceMode> _serviceMode = BehaviorSubject<ServiceMode>();

  Observable<ServiceMode> get serviceModesStream => _serviceMode.stream;

  PublishSubject<String> _toasts = PublishSubject<String>();

  Observable<String> get toasts => _toasts.stream;

  static PublishSubject<String> _tapEvents = PublishSubject<String>();

  PublishSubject<String> _progressBar = PublishSubject<String>();

  Observable<String> get progressBar => _progressBar.stream;

  StreamSubscription __logFileStatusSub;
  StreamSubscription _paramFileGetStatusSub;
  StreamSubscription _paramFileSetStatusSub;

  ServiceScreenManager() {
    _tapEvents.stream
        .transform(
            StreamTransformer.fromHandlers(handleData: _filterConseqTaps))
        .listen(_handleConseqTaps);
  }

  _filterConseqTaps(String ev, EventSink<String> sink) {
    if (_clickTimer.isRunning) {
      if (_clickTimer.elapsedMilliseconds < 1000) {
        _clickTimer.reset();
        _clickCounter++;
        sink.add("tick");
      } else {
        _clickTimer.stop();
        _clickTimer.reset();
        _clickCounter = 1;
      }
    } else {
      _clickTimer.start();
      _clickCounter++;
    }
  }

  void _serviceModeLauncher() {
    _countDown = Timer(Duration(seconds: 2), () {
      if (_clickCounter == 7) {
        _serviceMode.sink.add(ServiceMode.customer);
      } else if (_clickCounter == 10) {
        _serviceMode.sink.add(ServiceMode.technician);
      }
      _counter.sink.add("");
    });
  }

  void onTitleTap() {
    _tapEvents.sink.add("tap");
  }

  _handleConseqTaps(String ev) {
    _counter.sink.add(_clickCounter > 3 ? _clickCounter.toString() : "");
    if (_countDown != null && _countDown.isActive) _countDown.cancel();
    _serviceModeLauncher();
  }

  // SERVICE OPTIONS

  Future<String> getFirmwareVersion() async {
    return sl<DeviceConfigManager>().deviceConfig.fWVersionString;
  }

  retrieveAndUploadStoredData() {
    Log.info(TAG, "Retrieving stored data");

    final AckCallback callback =
        AckCallback(action: () => _showToast(_loc.retrieving_stored_test_data));
    sl<CommandTaskerManager>().addCommandWithCb(
        DeviceCommands.getSendStoredDataCmd(),
        listener: callback);
    final Timer timer =
        Timer(Duration(milliseconds: DeviceCommands.TECH_CMD_TIMEOUT), () {
      if (!callback.ackReceived) {
        _showToast(_loc.retrieve_stored_test_data_failed);
      }
    });
  }

  getParametersFile() {
    Log.info(TAG, "Get parameters file");
    sl<FileSystemService>().initParameterFile();
    _progressBar.sink.add(_loc.getting_param_file);
    _paramFileHandler.startParamFileGet();

    // subscribe to result
    _paramFileGetStatusSub =
        _paramFileHandler.paramFileGetStatusStream.listen((bool isDone) {
      if (isDone) _hideProgressbarWithMessage(_loc.getting_param_file_success);
      _paramFileGetStatusSub.cancel();
    });

    // handle timeout
    final Timer timer = Timer(Duration(seconds: 30), () {
      if (!_paramFileHandler.ifFileGetDone)
        _hideProgressbarWithMessage(_loc.getting_param_file_fail);
      _paramFileGetStatusSub.cancel();
    });
  }

  setParametersFile() {
    Log.info(TAG, "Set parameters file");

    _paramFileHandler.startParamFileSet();
  }

  _hideProgressbarWithMessage(String message) {
    _progressBar.sink.add("");
    _toasts.sink.add(message);
  }

  _showToast(String msg) {
    _toasts.sink.add(msg);
  }

  @override
  void dispose() {
    _serviceMode.close();
    _counter.close();
    _tapEvents.close();
    _toasts.close();
    _progressBar.close();
  }
}

class ServiceOption {
  final String title;
  final VoidCallback action;

  ServiceOption({this.title, this.action});
}

class ServiceDialog {
  final Widget title;
  final Widget content;
  final List<Widget> actions;

  ServiceDialog({this.title, this.content, this.actions});
}

class AckCallback extends OnAckListener {
  bool _ackReceived = false;
  final Function action;

  AckCallback({this.action});

  bool get ackReceived => _ackReceived;

  @override
  void onAckReceived() {
    _ackReceived = true;
    if (action != null) action();
  }
}

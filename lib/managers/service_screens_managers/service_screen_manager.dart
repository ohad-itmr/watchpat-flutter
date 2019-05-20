import 'dart:async';
import 'dart:io';

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

  static const int RESET_TYPE_SHUT_AND_RESET = 0X02;
  static const int RESET_TYPE_CLOCK_RESET = 0X04;
  static const int RESET_TYPE_CLEAR_DATA = 0X08;
  static const int RESET_TYPE_FACTORY_DEFAULTS = 0X10;
  static const int RESET_TYPE_WARM_VERSION_CHANGE = 0X20;

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
    _progressBar.sink.add(_loc.writing_param_file);
    _paramFileHandler.startParamFileSet();

    // subscribe to result
    _paramFileSetStatusSub =
        _paramFileHandler.paramFileSetStatusStream.listen((bool isDone) {
      if (isDone)
        _hideProgressbarWithMessage(_loc.param_file_written_successfully);
      _paramFileSetStatusSub.cancel();
    });
  }

  getAfeRegisters() {
    Log.info(TAG, "Get AFE registers");
    final AckCallback callback =
        AckCallback(action: () => _showToast(_loc.afe_registers_get_success));

    sl<CommandTaskerManager>().addCommandWithCb(
        DeviceCommands.getGetAFERegistersCmd(),
        listener: callback);

    final Timer timer =
        Timer(Duration(milliseconds: DeviceCommands.TECH_CMD_TIMEOUT), () {
      if (!callback.ackReceived) {
        _showToast(_loc.afe_registers_get_fail);
      }
    });
  }

  setAfeRegisters() async {
    Log.info(TAG, "Set AFE registers");
    List<int> bytes;

    File dirFile = await sl<FileSystemService>().watchpatDirAFEFile;
    File resourceFile = await sl<FileSystemService>().resourceAFEFile;

    // load data
    if (dirFile.existsSync() && dirFile.lengthSync() != 0) {
      Log.info(
          TAG, "Set AFE registers from WatchPatDir file, received from device");
      bytes = dirFile.readAsBytesSync();
    } else if (resourceFile.lengthSync() != 0) {
      Log.info(TAG, "Set AFE registers from resource file");
      bytes = resourceFile.readAsBytesSync();
    } else {
      Log.shout(TAG, "AFE file not found!");
      _showToast(_loc.afe_registers_write_failed);
      return;
    }

    // send command and handle response
    final AckCallback callback = AckCallback(
        action: () => _showToast(_loc.afe_registers_written_successfully));

    sl<CommandTaskerManager>().addCommandWithCb(
        DeviceCommands.getSetAFERegistersCmd(bytes),
        listener: callback);

    // handle timeout
    final Timer timer =
        Timer(Duration(milliseconds: DeviceCommands.TECH_CMD_TIMEOUT), () {
      if (!callback.ackReceived) _showToast(_loc.afe_registers_write_failed);
    });
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

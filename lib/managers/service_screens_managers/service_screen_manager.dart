import 'dart:async';
import 'dart:io';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:my_pat/config/default_settings.dart';
import 'package:my_pat/domain_model/device_commands.dart';
import 'package:my_pat/domain_model/tech_status_payload.dart';
import 'package:my_pat/main.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/FirmwareUpgrader.dart';
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

  StreamSubscription _paramFileGetStatusSub;
  StreamSubscription _paramFileSetStatusSub;

  ServiceScreenManager() {
    _tapEvents.stream
        .transform(StreamTransformer.fromHandlers(handleData: _filterConseqTaps))
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
    sl<CommandTaskerManager>()
        .addCommandWithCb(DeviceCommands.getSendStoredDataCmd(), listener: callback);
    final Timer timer = Timer(Duration(milliseconds: DeviceCommands.TECH_CMD_TIMEOUT), () {
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
    _paramFileGetStatusSub = _paramFileHandler.paramFileGetStatusStream.listen((bool isDone) {
      if (isDone) _hideProgressbarWithMessage(_loc.getting_param_file_success);
      _paramFileGetStatusSub.cancel();
    });

    // handle timeout
    final Timer timer = Timer(Duration(seconds: 30), () {
      if (!_paramFileHandler.isFileGetDone)
        _hideProgressbarWithMessage(_loc.getting_param_file_fail);
      _paramFileGetStatusSub.cancel();
    });
  }

  setParametersFile() {
    Log.info(TAG, "Set parameters file");
    _progressBar.sink.add(_loc.writing_param_file);
    _paramFileHandler.startParamFileSet();

    // subscribe to result
    _paramFileSetStatusSub = _paramFileHandler.paramFileSetStatusStream.listen((bool isDone) {
      if (isDone) _hideProgressbarWithMessage(_loc.param_file_written_successfully);
      _paramFileSetStatusSub.cancel();
    });
  }

  getLogFileFromDevice() async {
    Log.info(TAG, "Extracting log file from device");
    sl<FileSystemService>().initLogFile();
    _progressBar.sink.add(_loc.getting_log_file);
    sl<ParameterFileHandler>().startLogFileGet();

    // handle timeout
    final Timer timer = Timer(Duration(minutes: 2), () {
      if (!sl<ParameterFileHandler>().isFileGetDone)
        _hideProgressbarWithMessage(_loc.getting_log_file_fail);
    });

    // subscribe to result
    final bool isDone = await _paramFileHandler.logFileStatusStream.first;
    if (isDone) {
      _hideProgressbarWithMessage(_loc.getting_log_file_success);
      final File logFile = await sl<FileSystemService>().deviceLogFile;
      _shareFile(logFile);
    }
  }

  _shareFile(File file) async {
    await Share.file(
        'Device log file', DefaultSettings.deviceLogFileName, file.readAsBytesSync(), 'text/plain');
  }

  // Handle AFE registers
  getAfeRegisters() {
    Log.info(TAG, "Get AFE registers");
    final AckCallback callback =
        AckCallback(action: () => _showToast(_loc.afe_registers_get_success));

    sl<CommandTaskerManager>()
        .addCommandWithCb(DeviceCommands.getGetAFERegistersCmd(), listener: callback);

    final Timer timer = Timer(Duration(milliseconds: DeviceCommands.TECH_CMD_TIMEOUT), () {
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
      Log.info(TAG, "Set AFE registers from WatchPatDir file, received from device");
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
    final AckCallback callback =
        AckCallback(action: () => _showToast(_loc.afe_registers_written_successfully));

    sl<CommandTaskerManager>()
        .addCommandWithCb(DeviceCommands.getSetAFERegistersCmd(bytes), listener: callback);

    // handle timeout
    final Timer timer = Timer(Duration(milliseconds: DeviceCommands.TECH_CMD_TIMEOUT), () {
      if (!callback.ackReceived) _showToast(_loc.afe_registers_write_failed);
    });
  }

  // Handle ACC registers
  void getAccRegisters() {
    Log.info(TAG, "Get ACC registers");
    final AckCallback callback =
        AckCallback(action: () => _showToast(_loc.acc_registers_get_success));

    sl<CommandTaskerManager>()
        .addCommandWithCb(DeviceCommands.getGetACCRegistersCmd(), listener: callback);

    final Timer timer = Timer(Duration(milliseconds: DeviceCommands.TECH_CMD_TIMEOUT), () {
      if (!callback.ackReceived) {
        _showToast(_loc.acc_registers_get_fail);
      }
    });
  }

  void setAccRegisters() async {
    Log.info(TAG, "Set ACC registers");
    List<int> bytes;

    File dirFile = await sl<FileSystemService>().watchpatDirACCFile;
    File resourceFile = await sl<FileSystemService>().resourceACCFile;

    // load data
    if (dirFile.existsSync() && dirFile.lengthSync() != 0) {
      Log.info(TAG, "Set ACC registers from WatchPatDir file, received from device");
      bytes = dirFile.readAsBytesSync();
    } else if (resourceFile.lengthSync() != 0) {
      Log.info(TAG, "Set ACC registers from resource file");
      bytes = resourceFile.readAsBytesSync();
    } else {
      Log.shout(TAG, "ACC file not found!");
      _showToast(_loc.acc_registers_write_failed);
      return;
    }

    // send command and handle response
    final AckCallback callback =
        AckCallback(action: () => _showToast(_loc.acc_registers_written_successfully));

    sl<CommandTaskerManager>()
        .addCommandWithCb(DeviceCommands.getSetACCRegistersCmd(bytes), listener: callback);

    // handle timeout
    final Timer timer = Timer(Duration(milliseconds: DeviceCommands.TECH_CMD_TIMEOUT), () {
      if (!callback.ackReceived) _showToast(_loc.acc_registers_write_failed);
    });
  }

  // Handle EEPROM values
  void getEEPROMvalues() {
    Log.info(TAG, "Get device EEPROM");
    final AckCallback callback = AckCallback(action: () => _showToast(_loc.eeprom_get_success));

    sl<CommandTaskerManager>()
        .addCommandWithCb(DeviceCommands.getGetEEPROMCmd(), listener: callback);

    final Timer timer = Timer(Duration(milliseconds: DeviceCommands.TECH_CMD_TIMEOUT), () {
      if (!callback.ackReceived) {
        _showToast(_loc.eeprom_get_fail);
      }
    });
  }

  void setEEPROMValues() async {
    Log.info(TAG, "Set device EEPROM");
    List<int> bytes;

    File dirFile = await sl<FileSystemService>().watchpatDirEEPROMFile;
    File resourceFile = await sl<FileSystemService>().resourceEEPROMFile;

    // load data
    if (dirFile.existsSync() && dirFile.lengthSync() != 0) {
      Log.info(TAG, "Set EEPROM values from WatchPatDir file, received from device");
      bytes = dirFile.readAsBytesSync();
    } else if (resourceFile.lengthSync() != 0) {
      Log.info(TAG, "Set EEPROM values from resource file");
      bytes = resourceFile.readAsBytesSync();
    } else {
      Log.shout(TAG, "EEPROM file not found!");
      _showToast(_loc.eeprom_write_failed);
      return;
    }

    // send command and handle response
    final AckCallback callback =
        AckCallback(action: () => _showToast(_loc.eeprom_written_successfully));

    sl<CommandTaskerManager>()
        .addCommandWithCb(DeviceCommands.getSetEEPROMCmd(bytes), listener: callback);

    // handle timeout
    final Timer timer = Timer(Duration(milliseconds: DeviceCommands.TECH_CMD_TIMEOUT), () {
      if (!callback.ackReceived) _showToast(_loc.eeprom_write_failed);
    });
  }

  // Handle setting device serial
  void setDeviceSerial(String serial) {
    Log.info(TAG, "Setting device serial to $serial");

    // send command and handle response
    final AckCallback callback =
        AckCallback(action: () => _showToast(_loc.set_device_serial_success));

    sl<CommandTaskerManager>().addCommandWithCb(
        DeviceCommands.getSetDeviceSerialCmd(int.parse(serial)),
        listener: callback);

    // handle timeout
    final Timer timer = Timer(Duration(milliseconds: DeviceCommands.TECH_CMD_TIMEOUT), () {
      if (!callback.ackReceived) _showToast(_loc.set_device_serial_timeout);
    });
  }

  // handle LED
  List<LedOption> get ledOptions => [
        LedOption(color: LedColorOption.None, title: "None", value: 0x00),
        LedOption(color: LedColorOption.Red, title: "Red", value: 0x01),
        LedOption(color: LedColorOption.Green, title: "Green", value: 0x02),
        LedOption(color: LedColorOption.Both, title: "Both", value: 0x03),
      ];

  setLedColor(LedColorOption selectedColor) {
    Log.info(TAG, "Setting LEDs indicator mode to ${selectedColor.toString()}");

    final LedOption selectedOption =
        ledOptions.firstWhere((LedOption o) => o.color == selectedColor);

    // send command and handle response
    final AckCallback callback = AckCallback(action: () => _showToast(_loc.set_led_color_success));

    sl<CommandTaskerManager>()
        .addCommandWithCb(DeviceCommands.getSetLEDsCmd(selectedOption.value), listener: callback);

    // handle timeout
    final Timer timer = Timer(Duration(milliseconds: DeviceCommands.TECH_CMD_TIMEOUT), () {
      if (!callback.ackReceived) _showToast(_loc.set_led_color_timeout);
    });
  }

  // upgrade firmware
  void upgradeFirmware() async {
    sl<FirmwareUpgrader>().upgradeDeviceFirmwareFromWatchPATDir();
  }

  // handle technical status report
  Future<String> techStatusReport() async {
    Log.info(TAG, "Requesting technical status");

    final AckCallback callback = AckCallback();
    sl<CommandTaskerManager>()
        .addCommandWithCb(DeviceCommands.getGetTechnicalStatusCmd(), listener: callback);
    _showToast(_loc.requesting_technical_status);

    // handle timeout
    final Timer timer = Timer(Duration(milliseconds: DeviceCommands.TECH_CMD_TIMEOUT), () {
      if (!callback.ackReceived) _showToast(_loc.get_tech_status_timeout);
    });

    // subscibe to result
    TechStatusPayload techStatusPayload =
        await sl<IncomingPacketHandlerService>().techStatusResponse.first;

    var responseMsg = StringBuffer();
    responseMsg.write("${_loc.battery_voltage}${techStatusPayload.batteryVoltage}\n");
    responseMsg.write("${_loc.vdd_voltage}${techStatusPayload.vddVoltage}\n");
    responseMsg.write("${_loc.ir_led_status}${techStatusPayload.irLedStatus}\n");
    responseMsg.write("${_loc.red_led_status}${techStatusPayload.redLedStatus}\n");
    responseMsg.write("${_loc.pat_led_status}${techStatusPayload.patLedStatus}\n");
    return responseMsg.toString();
  }

  // Reset main device
  List<ResetOption> get resetOptions => [
        ResetOption(
            type: ResetType.shut_reset, title: "Shut and reset", value: RESET_TYPE_SHUT_AND_RESET),
        ResetOption(
            type: ResetType.reset_clock, title: "Reset clock", value: RESET_TYPE_CLOCK_RESET),
        ResetOption(
            type: ResetType.clear_data, title: "Clear all data", value: RESET_TYPE_CLEAR_DATA),
        ResetOption(
            type: ResetType.load_factory_defaults,
            title: "Load factory defaults",
            value: RESET_TYPE_FACTORY_DEFAULTS),
        ResetOption(
            type: ResetType.warm_version_change,
            title: "Warm version change",
            value: RESET_TYPE_WARM_VERSION_CHANGE),
      ];

  resetMainDevice(ResetType type) {
    Log.info(TAG, "Resetting main device...");
    final ResetOption option = resetOptions.firstWhere((ResetOption opt) => opt.type == type);
    sl<CommandTaskerManager>().addCommandWithNoCb(DeviceCommands.getResetDeviceCmd(option.value));
    _toasts.sink.add(_loc.reset_main_device);
  }

  //reset application
  resetApplication() async {
    await sl<FileSystemService>().clear();
    await PrefsProvider.clearAll();
    exit(0);
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

enum LedColorOption { None, Red, Green, Both }

class LedOption {
  final LedColorOption color;
  final String title;
  final int value;

  LedOption({this.color, this.title, this.value});
}

enum ResetType { shut_reset, reset_clock, clear_data, load_factory_defaults, warm_version_change }

class ResetOption {
  final ResetType type;
  final String title;
  final int value;

  ResetOption({this.type, this.title, this.value});
}

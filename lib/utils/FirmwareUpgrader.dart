import 'dart:async';
import 'dart:io';

import 'package:async/async.dart';
import 'package:my_pat/domain_model/device_commands.dart';
import 'package:my_pat/domain_model/device_config_payload.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/convert_formats.dart';
import 'package:rxdart/rxdart.dart';

import 'log/log.dart';

class FirmwareUpgrader extends ManagerBase {
  static const String TAG = "FirmwareUpgrader";

  // FW version offsets
  static const int OFST_FILE_FW_VERSION_MAJOR = 12; // 1 bytes
  static const int OFST_FILE_FW_VERSION_MINOR = 13; // 1 bytes
  static const int OFST_FILE_FW_COMPILATION_NUMBER = 14; // 2 bytes

  static const int FW_UPGRADE_LOAD_DATA_CHUNK = 1024;
  static const int FW_UPGRADE_FIRST_DATA_CHUNK = 512;
  static const int FW_UPGRADE_DATA_CHUNK = 2048;

  Version _upgradeFileFWVersion;
  List<int> _upgradeData;
  int _upgradeDataOffset;
  int _upgradeDataChunkSize;
  int _retransmissionRetries = 3;
  bool _isUpgradeDone;

  RestartableTimer _timeoutTimer;

  BehaviorSubject<double> _updateProgress = BehaviorSubject<double>();
  Observable<double> get updateProgressStream => _updateProgress.stream;

  Future<bool> isDeviceFirmwareVersionUpToDate() async {
    final DeviceConfigPayload config = sl<DeviceConfigManager>().deviceConfig;
    if (config == null) {
      Log.shout(TAG, "Configuration receive failed, FW may not be checked or upgraded");
      return true;
    }

    final bool loaded = await _loadFWUpgradeFileFromResource();
    if (!loaded) {
      Log.shout(TAG, "fw upgrade file loading error");
      return true; // current fw version is up to date because there is no reference for comparison
    }
    return (config.fwVersion.compareTo(_upgradeFileFWVersion) != CompareResults.VERSION_HIGHER);
  }

  _startTimer() {
    _timeoutTimer = RestartableTimer(Duration(seconds: 6), () {
      if (_retransmissionRetries > 0) {
        _retransmissionRetries--;
        _timeoutTimer.reset();
        _firmwareUpgrade();
      } else {
        sl<SystemStateManager>().setFirmwareState(FirmwareUpgradeState.UPGRADE_FAILED);
      }
      _retransmissionRetries = 3;
    });
  }

  _firmwareUpgrade() {
    try {
      List<int> dataChunkToSend = _upgradeData
          .getRange(_upgradeDataOffset, _upgradeDataOffset + _upgradeDataChunkSize)
          .toList();
      sl<CommandTaskerManager>().sendDirectCommand(DeviceCommands.getFWUpgradeRequestCmd(
          _upgradeDataOffset, _upgradeDataChunkSize, dataChunkToSend));
    } catch (e) {
      sl<SystemStateManager>().setFirmwareState(FirmwareUpgradeState.UPGRADE_FAILED);
      Log.shout(TAG, "Firmware upgrade failed: " + e.toString());
    }
    Log.info(TAG, "Firmware upgrade chunk sent to write");
  }

  void responseReceived() {
    _retransmissionRetries = 3;
    if (!_isUpgradeDone) {
      _timeoutTimer.reset();
      _upgradeDataOffset += _upgradeDataChunkSize;

      Log.info(TAG, "Upgrade response received, reporting offset: $_upgradeDataOffset");
      _reportProgress(_upgradeDataOffset);

      if (_upgradeDataOffset + FW_UPGRADE_DATA_CHUNK < _upgradeData.length) {
        _upgradeDataChunkSize = FW_UPGRADE_DATA_CHUNK;
      } else {
        // last chunk
        _upgradeDataChunkSize = _upgradeData.length - _upgradeDataOffset;
        _isUpgradeDone = true;
      }
      _firmwareUpgrade();
    } else {
      _reportProgress(_upgradeData.length);
      Log.info(TAG, "Device firmware upgrade finished, resetting main device");
      _timeoutTimer.cancel();
      sl<SystemStateManager>().setFirmwareState(FirmwareUpgradeState.UP_TO_DATE);
      sl<SystemStateManager>().setStartSessionState(StartSessionState.UNCONFIRMED);
      sl<CommandTaskerManager>().addCommandWithNoCb(
          DeviceCommands.getResetDeviceCmd(ServiceScreenManager.RESET_TYPE_SHUT_AND_RESET));
    }
  }

  void _reportProgress(final int progress) {
    print("Update progress $progress / ${_upgradeData.length}");
    _updateProgress.sink.add(progress / _upgradeData.length);
  }

  void upgradeDeviceFirmwareFromResources() async {
    Log.info(TAG, "upgrading device fw from resources");
    if (_upgradeData == null) {
      Log.warning(TAG, "upgradeData not loaded. trying to load from resources...");
      final bool loaded = await _loadFWUpgradeFileFromResource();
      if (!loaded) {
        sl<SystemStateManager>().setFirmwareState(FirmwareUpgradeState.UPGRADE_FAILED);
        return;
      }
    }
    _startFWUpgrade();
  }

  Future<bool> _loadFWUpgradeFileFromResource() async {
    final bool resExists = await sl<FileSystemService>().resourceFWFileExists;
    if (!resExists) {
      return false;
    }

    File resource = await sl<FileSystemService>().resourceFWFile;
    _upgradeData = resource.readAsBytesSync();
    if (_upgradeData.isEmpty) {
      return false;
    }

    _setFWVersion();
    return true;
  }

  void _setFWVersion() {
    final int compilation = ConvertFormats.twoBytesToInt(
        byte1: _upgradeData[OFST_FILE_FW_COMPILATION_NUMBER],
        byte2: _upgradeData[OFST_FILE_FW_COMPILATION_NUMBER + 1]);
    _upgradeFileFWVersion = new Version(_upgradeData[OFST_FILE_FW_VERSION_MAJOR],
        _upgradeData[OFST_FILE_FW_VERSION_MINOR], compilation, "UpgradeFileVersion");
  }

  void upgradeDeviceFirmwareFromWatchPATDir() async {
    Log.info(TAG, "upgrading device fw from watchPAT dir");

    final bool fileExists = await _loadFWUpgradeFileFromWatchPATDir();
    if (!fileExists) {
      sl<SystemStateManager>().setFirmwareState(FirmwareUpgradeState.UPGRADE_FAILED);
      return;
    }
    _startFWUpgrade();
  }

  Future<bool> _loadFWUpgradeFileFromWatchPATDir() async {
    final File upgradeFile = await sl<FileSystemService>().watchpatDirFWFile;
    if (!upgradeFile.existsSync()) {
      Log.shout(TAG, "FW upgrade file not found");
      return false;
    }
    _upgradeData = upgradeFile.readAsBytesSync();
    return true;
  }

  void _startFWUpgrade() {
    sl<SystemStateManager>().setFirmwareState(FirmwareUpgradeState.UPGRADING);
    Log.info(TAG, "starting firmware upgrade (upgrade file size: ${_upgradeData.length})");
    _upgradeDataOffset = 0;
    _upgradeDataChunkSize = FW_UPGRADE_FIRST_DATA_CHUNK;
    _isUpgradeDone = false;

    _startTimer();
    _firmwareUpgrade();
  }

  @override
  void dispose() {
    _updateProgress.close();
  }
}

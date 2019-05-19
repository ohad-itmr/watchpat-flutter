import 'dart:async';

import 'package:async/async.dart';
import 'package:my_pat/domain_model/device_commands.dart';
import 'package:my_pat/service_locator.dart';

import 'log/log.dart';

class FirmwareUpgrader {
  static const String TAG = "FirmwareUpgrader";

  // FW version offsets
  static const int OFST_FILE_FW_VERSION_MAJOR = 12; // 1 bytes
  static const int OFST_FILE_FW_VERSION_MINOR = 13; // 1 bytes
  static const int OFST_FILE_FW_COMPILATION_NUMBER = 14; // 2 bytes

  static const int FW_UPGRADE_LOAD_DATA_CHUNK = 1024;
  static const int FW_UPGRADE_FIRST_DATA_CHUNK = 512;
  static const int FW_UPGRADE_DATA_CHUNK = 2048;

  List<int> _upgradeData;
  int _upgradeDataOffset;
  int _upgradeDataChunkSize;
  int _retransmissionRetries;
  bool _isUpgradeDone;


  RestartableTimer _timeoutTimer;

  FirmwareUpgrader() {
//    _timeoutTimer = Timer(Duration(seconds: 6), () {
//      if (_retransmissionRetries > 0) {
//        _retransmissionRetries--;
//        _timeoutTimer.reset();
//        _firmwareUpgrade();
//      } else {
//        sl<SystemStateManager>()
//            .setFirmwareState(FirmwareUpgradeStates.UPDATE_FAILED);
//      }
//      _retransmissionRetries = 3;
//    });
  }

  _firmwareUpgrade() {
    try {
      List<int> dataChunkToSend = _upgradeData
          .getRange(
              _upgradeDataOffset, _upgradeDataOffset + _upgradeDataChunkSize)
          .toList();
      sl<CommandTaskerManager>().sendDirectCommand(
          DeviceCommands.getFWUpgradeRequestCmd(
              _upgradeDataOffset, _upgradeDataChunkSize, dataChunkToSend));
      Log.info(TAG, "Firmware upgrade finished");
      sl<SystemStateManager>()
          .setFirmwareState(FirmwareUpgradeStates.UPDATE_FAILED);
    } catch (e) {
      Log.shout(TAG, "Firmware upgrade failed: " + e.toString());
    }
  }

  void responseReceived() {
    if (!_isUpgradeDone) {
      _timeoutTimer.reset();
        _upgradeDataOffset += _upgradeDataChunkSize;

        Log.info(TAG, "responseReceived. reporting offset: $_upgradeDataOffset");
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
      Log.info(TAG, "Device firmware upgrade finished, resetting main device");
      _timeoutTimer.cancel();
      sl<SystemStateManager>().setFirmwareState(FirmwareUpgradeStates.UP_TO_DATE);
      sl<CommandTaskerManager>().addCommandWithNoCb(DeviceCommands.getResetDeviceCmd(ServiceScreenManager.RESET_TYPE_SHUT_AND_RESET));
      PrefsProvider.initDeviceName();
    }
  }

  void _reportProgress(final int progress) {
//    Intent intent = new Intent(ACTION_FIRMWARE_UPGRADE_PROGRESS);
//    intent.putExtra(watchPATApp.EXTRA_FW_UPDATE_TOTAL, _upgradeData.length)
//        .putExtra(watchPATApp.EXTRA_FW_UPDATE_VALUE, progress);
//
//    _appContext.sendBroadcast(intent);
  }
}

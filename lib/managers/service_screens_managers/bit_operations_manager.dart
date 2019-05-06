import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_pat/domain_model/device_commands.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/log/log.dart';
import 'package:rxdart/rxdart.dart';

class BitOperationsManager extends ManagerBase {
  static const String TAG = "BitOperationsManager";

  PublishSubject<String> _toasts = PublishSubject<String>();

  Observable<String> get toasts => _toasts.stream;

  PublishSubject<bool> loader = PublishSubject<bool>();

  Observable<bool> get loading => loader.stream;

  final List<BitOption> bitOptions = [
    BitOption(title: "All tests", mask: DeviceCommands.BIT_MASK_ALL_TESTS),
    BitOption(title: "AFE LEDs", mask: DeviceCommands.BIT_MASK_AFE_LEDS),
    BitOption(
        title: "AFE Photo-diode", mask: DeviceCommands.BIT_MASK_AFE_PHOTODIODE),
    BitOption(title: "DC-DC", mask: DeviceCommands.BIT_MASK_DC_DC),
    BitOption(title: "Battery", mask: DeviceCommands.BIT_MASK_BATTERY),
    BitOption(title: "Flash", mask: DeviceCommands.BIT_MASK_FLASH),
    BitOption(title: "Actigraph", mask: DeviceCommands.BIT_MASK_ACTIGRAPH),
    BitOption(title: "SBP Exists", mask: DeviceCommands.BIT_MASK_SBP_EXIST),
    BitOption(title: "UPAT EEPROM", mask: DeviceCommands.BIT_MASK_UPAT_EEPROM),
    BitOption(title: "Bracelet", mask: DeviceCommands.BIT_MASK_BRACELET),
    BitOption(title: "Finger", mask: DeviceCommands.BIT_MASK_FINGER),
  ];

  int _bitBITRequest = 0;
  void performBitOperation(List<BitOption> selectedOptions) {
    if (sl<SystemStateManager>().deviceCommState == DeviceStates.DISCONNECTED) {
      _showToast("Main device disconnected");
      return;
    }

    loader.sink.add(true);
    _showToast("Performing BIT operation");

    final bool checkAll = selectedOptions.contains(bitOptions[0]);
    bitOptions.forEach((BitOption option) {
      if (checkAll || selectedOptions.contains(option)) {
        _bitBITRequest |= option.mask;
      }
    });

    Log.info(TAG, "Requesting BIT: $_bitBITRequest");

    final BitOperationsAckCallback callback = BitOperationsAckCallback();

    sl<CommandTaskerManager>().addCommandWithCb(
        DeviceCommands.getBitRequestCmd(_bitBITRequest),
        listener: callback);
    final Timer timer =
        Timer(Duration(milliseconds: DeviceCommands.TECH_CMD_TIMEOUT), () {
      if (!callback.ackBit) {
        _bitBITRequest = 0;
        _showToast("Bit operation time out");
        loader.sink.add(false);
      }
    });
  }

  String getBitResponseMessage(final int response) {
    Map<int, String> responses = {
      DeviceCommands.BIT_MASK_AFE_LEDS: "AFE LEDs",
      DeviceCommands.BIT_MASK_AFE_PHOTODIODE: "AFE Photo-diode",
      DeviceCommands.BIT_MASK_DC_DC: "DC-DC",
      DeviceCommands.BIT_MASK_BATTERY: "Battery",
      DeviceCommands.BIT_MASK_FLASH: "Flash",
      DeviceCommands.BIT_MASK_ACTIGRAPH: "Actigraph",
      DeviceCommands.BIT_MASK_SBP_EXIST: "SPB Exists",
      DeviceCommands.BIT_MASK_UPAT_EEPROM: "UPAT EEPROM",
      DeviceCommands.BIT_MASK_BRACELET: "Bracelet",
      DeviceCommands.BIT_MASK_FINGER: "Finger"
    };
    var responseMsg = StringBuffer();

    responses.forEach((int mask, String title) {
      if ((mask & _bitBITRequest) != 0) {
        if ((mask & response) != 0) {
          responseMsg.write("+ $title: Test succeeded\n");
        } else {
          responseMsg.write("- $title: Test failed\n");
        }
      }
    });
    _bitBITRequest = 0;
    return responseMsg.toString();
  }

  _showToast(String msg) {
    _toasts.sink.add(msg);
  }

  @override
  void dispose() {
    _toasts.close();
    loader.close();
  }
}

class BitOperationsAckCallback extends OnAckListener {
  bool ackBit = false;

  BitOperationsAckCallback();

  @override
  void onAckReceived() {
    ackBit = true;
  }
}

class BitOption {
  final String title;
  final int mask;

  BitOption({@required this.title, @required this.mask});
}

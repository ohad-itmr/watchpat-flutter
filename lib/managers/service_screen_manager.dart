import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_pat/domain_model/device_commands.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/log/log.dart';
import 'package:rxdart/rxdart.dart';

enum ServiceMode { customer, technician }

class ServiceScreenManager extends ManagerBase {
  static const String TAG = "ServiceScreenManager";

  Stopwatch _clickTimer = Stopwatch();
  int _clickCounter = 1;
  Timer _countDown;

  PublishSubject<String> _counter = PublishSubject<String>();

  Observable<String> get counter => _counter.stream;

  BehaviorSubject<ServiceMode> _serviceMode = BehaviorSubject<ServiceMode>();

  Observable<ServiceMode> get serviceModesStream => _serviceMode.stream;

  static PublishSubject<String> _tapEvents = PublishSubject<String>();

  // BIT opeartions
  bool _ackBIT;
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

  void performBitOperation(List<BitOption> selectedOptions) {
    int bit = 0;
    final bool checkAll = selectedOptions.contains(bitOptions[0]);
    bitOptions.forEach((BitOption option) {
      if (checkAll || selectedOptions.contains(option)) {
        bit |= option.mask;
      }
    });
    Log.info(TAG, "Requesting BIT: $bit");
    sl<CommandTaskerManager>()
        .addCommandWithCb(DeviceCommands.getBitRequestCmd(bit), listener: null);
  }

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
    return "123.5.234.asshole";
  }

  retrieveAndUploadStoredData() {
    print("RETIREVEING AND STUFF");
  }

  @override
  void dispose() {
    _serviceMode.close();
    _counter.close();
    _tapEvents.close();
  }
}

class ServiceOption {
  final String title;
  final VoidCallback action;

  ServiceOption({this.title, this.action});
}

class BitOption {
  final String title;
  final int mask;

  BitOption({@required this.title, @required this.mask});
}

class ServiceDialog {
  final Widget title;
  final Widget content;
  final List<Widget> actions;

  ServiceDialog(
      {@required this.title, @required this.content, @required this.actions});
}

class AckCallback extends OnAckListener {
  @override
  void onAckReceived() {
    // TODO: implement onAckReceived
  }
}

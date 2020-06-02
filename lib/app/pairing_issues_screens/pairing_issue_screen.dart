import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_pat/managers/managers.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/widgets/buttons_block.dart';
import 'package:my_pat/widgets/main_template/block_template.dart';
import 'package:my_pat/widgets/main_template/body_template.dart';
import 'package:my_pat/widgets/main_template/main_template.dart';
import '../screens.dart';
import 'package:my_pat/generated/l10n.dart';

class PairingIssueScreen extends StatefulWidget {
  static const String TAG = 'PairingIssueScreen';
  static const String PATH = '/pairingIssue';

  @override
  _PairingIssueScreenState createState() => _PairingIssueScreenState();
}

class _PairingIssueScreenState extends State<PairingIssueScreen> {
  final BleManager bleManager = sl<BleManager>();
  final S loc = sl<S>();
  final SystemStateManager systemStateManager = sl<SystemStateManager>();

  StreamSubscription _deviceConnectionSub;
  bool _deviceConnected = false;

  @override
  void initState() {
    super.initState();
    _deviceConnectionSub = sl<SystemStateManager>()
        .deviceCommStateStream
        .listen((DeviceStates state) {
      if (state == DeviceStates.CONNECTED) {
        setState(() => _deviceConnected = true);
      }
    });
  }

  @override
  void deactivate() {
    _deviceConnectionSub.cancel();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return MainTemplate(
      showBack: false,
      showMenu: false,
      body: BodyTemplate(
        topBlock: BlockTemplate(
          type: BlockType.image,
          imageName: 'insert_battery.png',
        ),
        bottomBlock: StreamBuilder(
            stream: systemStateManager.bleScanResultStream,
            builder: (BuildContext context,
                AsyncSnapshot<ScanResultStates> snapshot) {
              return BlockTemplate(
                type: BlockType.text,
                title: "houston we have a problem".toUpperCase(),
                content: !snapshot.hasData ||
                        snapshot.data == ScanResultStates.NOT_LOCATED
                    ? [loc.batteryContent_1, loc.batteryContent_2]
                    : [
                        loc.batteryContent_many_2
                      ],
              );
            }),
        buttons: ButtonsBlock(
          nextActionButton: ButtonModel(
            action: () {
              if (_deviceConnected) {
                Navigator.pushNamed(context, PreparationScreen.PATH);
              } else {
                _showClosingDialog();
              }
            },
          ),
          moreActionButton: ButtonModel(
            action: () => Navigator.of(context)
                .pushNamed("${CarouselScreen.PATH}/${BatteryScreen.TAG}"),
          ),
        ),
        showSteps: true,
        current: 1,
        total: 6,
      ),
    );
  }

  _showClosingDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            title: Text(loc.fatal_error),
            content: Text(loc.device_connection_failed),
            actions: <Widget>[
              FlatButton(
                onPressed: () => exit(0),
                child: Text(loc.ok),
              )
            ],
          );
        });
  }
}

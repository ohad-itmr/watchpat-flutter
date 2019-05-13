import 'dart:async';

import 'package:my_pat/app/pairing_issues_screens/pairing_issue_screen.dart';
import 'package:my_pat/app/screens.dart';
import 'package:my_pat/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:my_pat/widgets/widgets.dart';

class BatteryScreen extends StatefulWidget {
  static const String TAG = 'BatteryScreen';
  static const String PATH = '/battery';

  @override
  _BatteryScreenState createState() => _BatteryScreenState();
}

class _BatteryScreenState extends State<BatteryScreen> {
  final BleManager bleManager = sl<BleManager>();
  final S loc = sl<S>();
  final SystemStateManager systemStateManager = sl<SystemStateManager>();

  StreamSubscription _deviceConnectionSub;
  bool _deviceConnected = false;

  @override
  void initState() {
    systemStateManager.setScanCycleEnabled = true;
    bleManager.startScan(
        time: GlobalSettings.btScanTimeout, connectToFirstDevice: false);
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
    print("DEAKTEVEITAAAAAAAAA");
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
                title: loc.batteryTitle,
                content: !snapshot.hasData ||
                        snapshot.data == ScanResultStates.NOT_LOCATED
                    ? [
                        loc.batteryContent_1,
                        loc.batteryContent_2,
                      ]
                    : [
                        loc.batteryContent_many_1(
                            '${bleManager.scanResultsLength}'),
                        loc.batteryContent_many_2,
                      ],
              );
            }),
        buttons: ButtonsBlock(
          nextActionButton: ButtonModel(
            action: () {
              Navigator.pushNamed(context, _deviceConnected ? RemoveJewelryScreen.PATH : PairingIssueScreen.PATH);
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
}

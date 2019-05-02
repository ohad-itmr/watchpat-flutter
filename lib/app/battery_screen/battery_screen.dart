import 'package:my_pat/app/screens.dart';
import 'package:my_pat/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:my_pat/widgets/widgets.dart';

class BatteryScreen extends StatelessWidget {
  static const String TAG = 'BatteryScreen';
  static const String PATH = '/battery';
  final S loc = sl<S>();
  final BleManager bleManager = sl<BleManager>();
  final SystemStateManager systemStateManager = sl<SystemStateManager>();

  BatteryScreen({Key key}) : super(key: key) {
    systemStateManager.scanCycleEnabled = true;
    bleManager.startScan(
        time: GlobalSettings.btScanTimeout, connectToFirstDevice: false);
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
              Navigator.pushNamed(context, RemoveJewelryScreen.PATH);
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

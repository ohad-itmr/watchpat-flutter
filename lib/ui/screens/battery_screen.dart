import '../../generated/i18n.dart';
import 'package:flutter/material.dart';

import '../widgets/main_template/main_template.dart';
import '../widgets/main_template/body_template.dart';
import '../widgets/main_template/block_template.dart';
import '../widgets/buttons_block.dart';

class BatteryScreen extends StatelessWidget {
  static const String PATH = '/battery';

  BatteryScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final S loc = S.of(context);
    return MainTemplate(
      showBack: true,
      showMenu: false,
      body: BodyTemplate(
        topBlock: BlockTemplate(
          type: BlockType.image,
          imageName: 'insert_battery.png',
        ),
        bottomBlock: BlockTemplate(
          type: BlockType.text,
          title: loc.batteryTitle,
          content: [
            loc.batteryContent_1,
            loc.batteryContent_2,
          ],
        ),
        buttons: ButtonsBlock(
          nextActionButton: ButtonModel(
            action: () {
              Navigator.pushNamed(context, '/pin');
              },
          ),
          moreActionButton: ButtonModel(
            action: () {},
          ),
        ),
        showSteps: true,
        current: 1,
        total: 6,
      ),
    );
  }
}

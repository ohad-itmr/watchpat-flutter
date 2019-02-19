import '../helpers/localizations.dart';
import 'package:flutter/material.dart';
import '../widgets/main_template/main_template.dart';
import '../widgets/main_template/body_template.dart';
import '../widgets/main_template/block_template.dart';
import '../widgets/buttons_block.dart';

class BatteryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MainTemplate(
      showBack: true,
      showMenu: false,
      body: BodyTemplate(
        topBlock: BlockTemplate(
          block: BlockModel(
            type: BlockType.image,
            imageName: 'insert_battery.png',
          ),
        ),
        bottomBlock: BlockTemplate(
          block: BlockModel(
            type: BlockType.text,
            title: AppLocalizations.of(context).batteryTitle,
            content: [
              AppLocalizations.of(context).batteryContent_1,
              AppLocalizations.of(context).batteryContent_2,
            ],
          ),
        ),
        buttons: ButtonsBlock(
          nextActionButton: ButtonModel(
            action: () {},
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

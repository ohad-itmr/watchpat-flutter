import '../helpers/localizations.dart';
import 'package:flutter/material.dart';
import '../widgets/main_template/main_template.dart';
import '../widgets/main_template/body_template.dart';
import '../widgets/main_template/block_template.dart';
import '../widgets/buttons_block.dart';

class ChestSensorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc=AppLocalizations.of(context);

    return MainTemplate(
      showBack: true,
      showMenu: false,
      body: BodyTemplate(
        topBlock: BlockTemplate(
          type: BlockType.image,
          imageName: 'chest.png',
        ),
        bottomBlock: BlockTemplate(
          type: BlockType.text,
          title: loc.chestSensorTitle,
          content: [
            loc.chestSensorContent,
          ],
        ),
        buttons: ButtonsBlock(
          nextActionButton: ButtonModel(
            action: () {
              Navigator.pushNamed(context, '/prepare4');
            },
          ),
          moreActionButton: ButtonModel(
            action: () {},
          ),
        ),
        showSteps: true,
        current: 4,
        total: 6,
      ),
    );
  }
}

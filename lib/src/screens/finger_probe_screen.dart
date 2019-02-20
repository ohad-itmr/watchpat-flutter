import '../helpers/localizations.dart';
import 'package:flutter/material.dart';
import '../widgets/main_template/main_template.dart';
import '../widgets/main_template/body_template.dart';
import '../widgets/main_template/block_template.dart';
import '../widgets/buttons_block.dart';

class FingerProbeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc=AppLocalizations.of(context);

    return MainTemplate(
      showBack: true,
      showMenu: false,
      body: BodyTemplate(
        topBlock: BlockTemplate(
          type: BlockType.image,
          imageName: 'finger.png',
        ),
        bottomBlock: BlockTemplate(
          type: BlockType.text,
          title: loc.fingerProbeTitle,
          content: [
            loc.fingerProbeContent,
          ],
        ),
        buttons: ButtonsBlock(
          nextActionButton: ButtonModel(
            action: () {
              Navigator.pushNamed(context, '/start');
            },
          ),
          moreActionButton: ButtonModel(
            action: () {},
          ),
        ),
        showSteps: true,
        current: 5,
        total: 6,
      ),
    );
  }
}

import '../helpers/localizations.dart';
import 'package:flutter/material.dart';
import '../widgets/main_template/main_template.dart';
import '../widgets/main_template/body_template.dart';
import '../widgets/main_template/block_template.dart';
import '../widgets/buttons_block.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MainTemplate(
      showBack: false,
      showMenu: true,
      body: BodyTemplate(
        topBlock: BlockTemplate(
          block: BlockModel(
            type: BlockType.image,
            imageName: 'welcome.png',
          ),
        ),
        bottomBlock: BlockTemplate(
          block: BlockModel(
            type: BlockType.text,
            title: AppLocalizations.of(context).welcomeTitle,
            content: [
              AppLocalizations.of(context).welcomeContent,
            ],
          ),
        ),
        buttons: ButtonsBlock(
          nextActionButton: ButtonModel(
            action: () {
              print('click');
              Navigator.pushNamed(context, '/battery');
            },
          ),
          moreActionButton: ButtonModel(
            action: () {},
          ),
        ),
        showSteps: false,
      ),
    );
  }
}

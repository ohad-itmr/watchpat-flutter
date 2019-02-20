import '../helpers/localizations.dart';
import 'package:flutter/material.dart';
import '../widgets/main_template/main_template.dart';
import '../widgets/main_template/body_template.dart';
import '../widgets/main_template/block_template.dart';
import '../widgets/buttons_block.dart';

class EndScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);

    return MainTemplate(
      showBack: false,
      showMenu: false,
      body: BodyTemplate(
       topBlock: BlockTemplate(
          type: BlockType.text,
          title: loc.thankYouTitle,
          content: [
            loc.thankYouContent
          ],
        ),
        buttons: ButtonsBlock(
          nextActionButton: ButtonModel(
            action: () {
            },
            text: loc.btnCloseApp,
          ),
          moreActionButton: null,
        ),
        showSteps: false,
      ),
    );
  }
}

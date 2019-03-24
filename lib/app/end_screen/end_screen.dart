import 'package:flutter/material.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/widgets/widgets.dart';


class EndScreen extends StatelessWidget {
  static const String PATH = '/end';
  final S loc = sl<S>();

  EndScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainTemplate(
      showBack: false,
      showMenu: false,
      body: BodyTemplate(
        topBlock: BlockTemplate(
          type: BlockType.text,
          title: loc.thankYouTitle,
          content: [loc.thankYouContent],
        ),
        buttons: ButtonsBlock(
          nextActionButton: ButtonModel(
            action: () {},
            text: loc.btnCloseApp,
          ),
          moreActionButton: null,
        ),
        showSteps: false,
      ),
    );
  }
}

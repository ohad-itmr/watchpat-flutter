import 'package:flutter/material.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/widgets/widgets.dart';


class RemoveJewelryScreen extends StatelessWidget {
  static const String PATH = '/prepare1';
  final S loc = sl<S>();

  RemoveJewelryScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          title: loc.removeJewelryTitle,
          content: [
            loc.removeJewelryContent,
          ],
        ),
        buttons: ButtonsBlock(
          nextActionButton: ButtonModel(
            action: () {
              Navigator.pushNamed(context, '/prepare2');
            },
          ),
          moreActionButton: ButtonModel(
            action: () {},
          ),
        ),
        showSteps: true,
        current: 2,
        total: 6,
      ),
    );
  }
}

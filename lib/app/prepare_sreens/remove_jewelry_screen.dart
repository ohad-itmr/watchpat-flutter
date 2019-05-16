import 'package:flutter/material.dart';
import 'package:my_pat/app/screens.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/widgets/widgets.dart';

class RemoveJewelryScreen extends StatelessWidget {
  static const String PATH = '/prepare';
  final S loc = sl<S>();
  static const String TAG = 'RemoveJewelryScreen';

  RemoveJewelryScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainTemplate(
      showBack: false,
      showMenu: false,
      body: BodyTemplate(
        topBlock: BlockTemplate(
          type: BlockType.image,
          imageName: 'prepare.png',
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
              Navigator.pushNamed(context, PinScreen.PATH);
            },
          ),
          moreActionButton: ButtonModel(
            action: () => Navigator.of(context)
                .pushNamed("${CarouselScreen.PATH}/${RemoveJewelryScreen.TAG}"),
          ),
        ),
        showSteps: true,
        current: 2,
        total: 6,
      ),
    );
  }
}

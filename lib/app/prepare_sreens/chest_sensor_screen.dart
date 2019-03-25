import 'package:my_pat/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:my_pat/widgets/widgets.dart';

class ChestSensorScreen extends StatelessWidget {
  static const String PATH = '/prepare3';
  static const String TAG = 'ChestSensorScreen';

  ChestSensorScreen({Key key}) : super(key: key);
  final S loc = sl<S>();

  @override
  Widget build(BuildContext context) {
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

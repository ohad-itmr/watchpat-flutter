import 'package:flutter/material.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/widgets/widgets.dart';


class StrapWristScreen extends StatelessWidget {
  static const String PATH = '/prepare2';
  final S loc = sl<S>();
  static const String TAG = 'StrapWristScreen';

  StrapWristScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainTemplate(
      showBack: true,
      showMenu: false,
      body: BodyTemplate(
        topBlock: BlockTemplate(
          type: BlockType.image,
          imageName: 'strap_wrist.png',
        ),
        bottomBlock: BlockTemplate(
          type: BlockType.text,
          title: loc.strapWristTitle,
          content: [
            loc.strapWristContent,
          ],
        ),
        buttons: ButtonsBlock(
          nextActionButton: ButtonModel(
            action: () {
              Navigator.pushNamed(context, '/prepare3');
            },
          ),
          moreActionButton: ButtonModel(
            action: () {},
          ),
        ),
        showSteps: true,
        current: 3,
        total: 6,
      ),
    );
  }
}

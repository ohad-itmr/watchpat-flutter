import 'package:flutter/material.dart';
import 'package:my_pat/app/screens.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/widgets/widgets.dart';

class StrapWristScreen extends StatelessWidget {
  static const String PATH = '/device_set_up_1';
  static const String TAG = 'StrapWristScreen';

  @override
  Widget build(BuildContext context) {
    return MainTemplate(
      showBack: false,
      showMenu: false,
      body: BodyTemplate(
        topBlock: BlockTemplate(
          type: BlockType.image,
          imageName: 'strap_wrist.png',
        ),
        bottomBlock: BlockTemplate(
          type: BlockType.text,
          title: S.of(context).strapWristTitle,
          content: [S.of(context).strapWristContent],
        ),
        buttons: ButtonsBlock(
          nextActionButton: ButtonModel(
            action: () {
              Navigator.pushNamed(context, ChestSensorScreen.PATH);
            },
          ),
          moreActionButton: ButtonModel(
            action: () => Navigator.of(context)
                .pushNamed("${CarouselScreen.PATH}/${StrapWristScreen.TAG}"),
          ),
        ),
        showSteps: true,
        current: 3,
        total: 6,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:my_pat/app/screens.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/widgets/widgets.dart';


class FingerProbeScreen extends StatelessWidget {
  static const String PATH = '/device_set_up_3';
  final S loc = sl<S>();
  static const String TAG = 'FingerProbeScreen';

  FingerProbeScreen({Key key}) : super(key: key);

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
          title: loc.fingerProbeTitle,
          content: [
            loc.fingerProbeContent,
          ],
        ),
        buttons: ButtonsBlock(
          nextActionButton: ButtonModel(
            action: () {
              Navigator.pushNamed(context, StartRecordingScreen.PATH);
            },
          ),
          moreActionButton: ButtonModel(
            action: () => Navigator.of(context)
                .pushNamed("${CarouselScreen.PATH}/${FingerProbeScreen.TAG}"),
          ),
        ),
        showSteps: true,
        current: 5,
        total: 6,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:my_pat/app/screens.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/widgets/widgets.dart';


class StartRecordingScreen extends StatelessWidget {
  static const String PATH = '/start';
  static const String TAG = 'StartRecordingScreen';

  StartRecordingScreen({Key key}) : super(key: key);
  final S loc = sl<S>();

  @override
  Widget build(BuildContext context) {
    return MainTemplate(
      showBack: true,
      showMenu: false,
      body: BodyTemplate(
        topBlock: BlockTemplate(
          type: BlockType.image,
          imageName: 'welcome.png',
        ),
        bottomBlock: BlockTemplate(
          type: BlockType.text,
          title: loc.startRecordingTitle,
          content: [
            loc.startRecordingContent,
          ],
        ),
        buttons: ButtonsBlock(
          nextActionButton: ButtonModel(
            action: () {
              Navigator.pushNamed(context, RecordingScreen.PATH);
            },
            text: loc.btnStartRecording,
          ),
          moreActionButton: null,
        ),
        showSteps: true,
        current: 6,
        total: 6,
      ),
    );
  }
}

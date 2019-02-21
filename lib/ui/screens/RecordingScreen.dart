import '../../generated/i18n.dart';
import 'package:flutter/material.dart';
import '../widgets/main_template/main_template.dart';
import '../widgets/main_template/body_template.dart';
import '../widgets/main_template/block_template.dart';
import '../widgets/buttons_block.dart';

class RecordingScreen extends StatelessWidget {
  static const String PATH = '/recording';
  RecordingScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final S loc = S.of(context);

    return MainTemplate(
      showBack: false,
      showMenu: false,
      body: BodyTemplate(
        topBlock: BlockTemplate(
          type: BlockType.image,
          imageName: 'recording.png',
        ),
        bottomBlock: BlockTemplate(
          type: BlockType.text,
          title: loc.recordingTitle,
          content: null,
        ),
        buttons: ButtonsBlock(
          nextActionButton: ButtonModel(
            action: () {
              Navigator.pushNamed(context, '/uploading');
            },
            text: loc.btnStartRecording,
          ),
          moreActionButton: null,
        ),
        showSteps: false,
      ),
    );
  }
}

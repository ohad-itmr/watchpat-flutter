import 'package:flutter/material.dart';
import 'package:my_pat/app/error_screen/error_screen_errors.dart';
import 'package:my_pat/app/screens.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/widgets/widgets.dart';

class StartRecordingScreen extends StatelessWidget {
  static const String PATH = '/start';
  static const String TAG = 'StartRecordingScreen';

  StartRecordingScreen({Key key}) : super(key: key);
  final S loc = sl<S>();
  final _testingManager = sl<TestingManager>();

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
            action: () async {
              final bool canStart = await _testingManager.canStartTesting;
              if (canStart) {
                _testingManager.startTesting();
                Navigator.pushNamed(context, RecordingScreen.PATH);
              } else {
                Navigator.pushNamed(context,
                    "${ErrorScreen.PATH}/${ErrorScreenError.BATTERY_LOW_LEVEL_NOT_CHARGING}");
              }
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

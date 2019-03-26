import 'package:flutter/material.dart';
import 'package:my_pat/app/screens.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/widgets/widgets.dart';

class UploadingScreen extends StatelessWidget {
  static const String PATH = '/uploading';
  static const String TAG = 'UploadingScreen';

  final S loc = sl<S>();

  UploadingScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainTemplate(
      showBack: false,
      showMenu: false,
      body: BodyTemplate(
        topBlock: BlockTemplate(
          type: BlockType.image,
          imageName: 'uploading.png',
        ),
        bottomBlock: BlockTemplate(
          type: BlockType.text,
          title: loc.uploadingTitle,
          content: [loc.uploadingContent],
        ),
        buttons: ButtonsBlock(
          nextActionButton: ButtonModel(
            action: () {
              Navigator.pushNamed(context, EndScreen.PATH);
            },
          ),
          moreActionButton: null,
        ),
        showSteps: false,
      ),
    );
  }
}

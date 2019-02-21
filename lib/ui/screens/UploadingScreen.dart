import 'package:flutter/material.dart';
import '../../generated/i18n.dart';
import '../widgets/main_template/main_template.dart';
import '../widgets/main_template/body_template.dart';
import '../widgets/main_template/block_template.dart';
import '../widgets/buttons_block.dart';

class UploadingScreen extends StatelessWidget {
  static const String PATH = '/uploading';
  UploadingScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final S loc = S.of(context);

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
          content: [
            loc.uploadingContent
          ],
        ),
        buttons: ButtonsBlock(
          nextActionButton: ButtonModel(
            action: () {
              Navigator.pushNamed(context, '/end');
            },
          ),
          moreActionButton: null,
        ),
        showSteps: false,
      ),
    );
  }
}

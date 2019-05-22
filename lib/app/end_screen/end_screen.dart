import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/widgets/widgets.dart';

class EndScreen extends StatelessWidget {
  static const String TAG = 'EndScreen';
  static const String PATH = '/end';

  final String title;
  final String content;

  EndScreen({Key key, @required this.title, @required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return MainTemplate(
      showBack: false,
      showMenu: false,
      body: BodyTemplate(
        topBlock: BlockTemplate(
          type: BlockType.text,
          title: title,
          content: [content],
          textTopPadding: true,
        ),
        bottomBlock: Column(
          children: <Widget>[
            Container(
              width: width / 2,
              child: BlockTemplate(
                type: BlockType.image,
                imageName: 'itamar_full_logo.png',
              ),
            ),
          ],
        ),
        buttons: ButtonsBlock(
          nextActionButton: ButtonModel(
            action: () => exit(0),
            text: S.of(context).btnCloseApp,
          ),
          moreActionButton: null,
        ),
        showSteps: false,
      ),
    );
  }
}

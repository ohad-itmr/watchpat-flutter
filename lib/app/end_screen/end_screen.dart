import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_pat/app/screens.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/widgets/widgets.dart';

class EndScreen extends StatelessWidget {
  static const String TAG = 'EndScreen';
  static const String PATH = '/end';
  final S loc = sl<S>();

  EndScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainTemplate(
      showBack: false,
      showMenu: false,
      body: BodyTemplate(
        topBlock: BlockTemplate(
          type: BlockType.text,
          title: loc.thankYouTitle,
          content: [loc.thankYouContent],
          textTopPadding: true,
        ),
        buttons: ButtonsBlock(
          nextActionButton: ButtonModel(
            action: () => exit(0),
            text: loc.btnCloseApp,
          ),
          moreActionButton: null,
        ),
        showSteps: false,
      ),
    );
  }
}

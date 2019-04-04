import 'package:flutter/material.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/widgets/widgets.dart';


class ErrorScreen extends StatelessWidget {
  static const String TAG = 'ErrorScreen';
  static const String PATH = '/error';
  final S loc = sl<S>();

  @override
  Widget build(BuildContext context) {
    return MainTemplate(
      showBack: false,
      showMenu: false,
      backgroundColor: Colors.black,
      body: BodyTemplate(
        topBlock: BlockTemplate(
          type: BlockType.text,
          title: "ERROR",
          content: ["Oh shit! We're all going to die. Eventually."],
          textColor: Colors.white.withOpacity(0.9),
          textTopPadding: true,
        ),
        buttons: ButtonsBlock(
          nextActionButton: ButtonModel(
            action: () => Navigator.pop(context),
            text: "Return to app".toUpperCase(),
          ),
          moreActionButton: null,
        ),
        showSteps: false,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/widgets/widgets.dart';


class ErrorScreen extends StatelessWidget {
  static const String TAG = 'ErrorScreen';
  static const String PATH = '/error';

  final String error;
  final S loc = sl<S>();

  ErrorScreen({Key key, this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainTemplate(
      showBack: false,
      showMenu: false,
      backgroundColor: Colors.black,
      body: BodyTemplate(
        topBlock: BlockTemplate(
          type: BlockType.text,
          title: loc.error_state,
          content: [error],
          textColor: Colors.white.withOpacity(0.9),
          textTopPadding: true,
        ),
        buttons: ButtonsBlock(
          nextActionButton: ButtonModel(
            action: () => Navigator.pop(context),
            text: loc.btnReturnToApp.toUpperCase(),
          ),
          moreActionButton: null,
        ),
        showSteps: false,
      ),
    );
  }
}

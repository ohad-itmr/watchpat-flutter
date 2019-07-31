import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
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
      body: Container(
        constraints: BoxConstraints.expand(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(S.of(context).error.toUpperCase(),
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 24.0)),
            Text(
              '$error',
              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 18.0),
            ),
            Container(height: MediaQuery.of(context).size.width / 2),
            ButtonsBlock(
              nextActionButton: ButtonModel(
                  action: () => Navigator.pop(context), text: loc.btnReturnToApp.toUpperCase()),
              moreActionButton: null,
            )
          ],
        ),
      ),
    );
  }
}

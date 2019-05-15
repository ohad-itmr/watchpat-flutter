import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:my_pat/app/recording_screens/recording_control.dart';
import 'package:my_pat/widgets/connection_indicators_hor.dart';
import 'package:my_pat/widgets/widgets.dart';

class RecordingScreen extends StatelessWidget {
  static const String PATH = '/recording';
  static const String TAG = 'RecordingScreen';

  RecordingScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainTemplate(
        showBack: false,
        showMenu: false,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Flexible(
              flex: 7,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  image: DecorationImage(
                    image: AssetImage('assets/sleepgif.gif'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black
                ),
                child: RecordingControl(),
              ),
            )
          ],
        ));
  }
}

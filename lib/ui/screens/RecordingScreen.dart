import 'package:flutter/material.dart';
import '../widgets/main_template/main_template.dart';
import '../widgets/recording_control.dart';

class RecordingScreen extends StatelessWidget {
  static const String PATH = '/recording';

  RecordingScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return MainTemplate(
        showBack: false,
        showMenu: false,
        body: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                image: DecorationImage(
                  image: AssetImage('assets/stars_bg.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              child: Column(
                children: <Widget>[
                  Flexible(
                    flex: 7,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/sleeping_gif_nobg.gif'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  RecordingControl(),
                ],
              ),
            )
          ],
        ));
  }
}

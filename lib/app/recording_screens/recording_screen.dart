import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:my_pat/app/recording_screens/recording_control.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/widgets/connection_indicators_hor.dart';
import 'package:my_pat/widgets/widgets.dart';

class RecordingScreen extends StatelessWidget {
  static const String PATH = '/recording';
  static const String TAG = 'RecordingScreen';

  RecordingScreen({Key key}) : super(key: key) {
    if (sl<SystemStateManager>().testState == TestStates.INTERRUPTED) {
      sl<BleManager>().startScan(
          time: GlobalSettings.btScanTimeout, connectToFirstDevice: false);
    }
  }

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
                  color: Color.fromARGB(255, 35, 35, 35),
                  image: DecorationImage(
                    image: AssetImage('assets/animation_recording.gif'),
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(color: Color.fromARGB(255, 35, 35, 35)),
                child: RecordingControl(),
              ),
            )
          ],
        ));
  }
}

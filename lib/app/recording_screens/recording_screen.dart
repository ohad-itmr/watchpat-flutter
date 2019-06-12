import 'package:flutter/material.dart';
import 'package:my_pat/app/recording_screens/recording_control.dart';
import 'package:my_pat/app/screens.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/widgets/widgets.dart';

class RecordingScreen extends StatefulWidget {
  static const String PATH = '/recording';
  static const String TAG = 'RecordingScreen';

  @override
  _RecordingScreenState createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  @override
  void initState() {
    if (sl<SystemStateManager>().testState == TestStates.INTERRUPTED) {
      sl<SystemStateManager>().setScanCycleEnabled = true;
      sl<BleManager>().startScan(
          time: GlobalSettings.btScanTimeout, connectToFirstDevice: false);
    }
    _subscribeToTestState();
    internetWarningSub.cancel();
    super.initState();
  }

  _subscribeToTestState() {
    sl<SystemStateManager>()
        .testStateStream
        .firstWhere((TestStates st) =>
            st == TestStates.STOPPED || st == TestStates.ENDED)
        .then((TestStates state) {
      if (state == TestStates.STOPPED) {
        Navigator.pushNamed(context, UploadingScreen.PATH);
      } else if (state == TestStates.ENDED) {
        Navigator.pushNamed(context, EndScreen.PATH);
      }
    });
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
                decoration:
                    BoxDecoration(color: Color.fromARGB(255, 35, 35, 35)),
                child: RecordingControl(),
              ),
            )
          ],
        ));
  }
}

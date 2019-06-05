import 'package:flutter/material.dart';
import 'package:my_pat/app/screens.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/time_utils.dart';
import 'package:my_pat/widgets/widgets.dart';

class RecordingControl extends StatelessWidget with WidgetsBindingObserver {

  RecordingControl() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if ((sl<SystemStateManager>().testState == TestStates.STARTED ||
            sl<SystemStateManager>().testState == TestStates.RESUMED) &&
        state == AppLifecycleState.paused) {
      sl<NotificationsService>().showLocalNotification("Test in progress");
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Spacer(),
        Container(
          margin: EdgeInsets.only(bottom: 10.0),
          child: Text(
            S.of(context).recordingTitle,
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.title.fontSize,
              color: Colors.white,
            ),
          ),
        ),
        Container(
            margin: EdgeInsets.only(bottom: 10.0),
            child: StreamBuilder(
              stream: sl<TestingManager>().elapsedTimeStream,
              initialData: 0,
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    '${S.of(context).elapsed_time}: ${TimeUtils.convertSecondsToHMmSs(snapshot.data)}',
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.title.fontSize,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  );
                }
              },
            )),
        Spacer(),
        StreamBuilder(
          stream: sl<SystemStateManager>().testStateStream,
          builder: (BuildContext context, AsyncSnapshot<TestStates> snapshot) {
            return ButtonsBlock(
              moreActionButton: null,
              nextActionButton: ButtonModel(
                action: snapshot.data == TestStates.MINIMUM_PASSED
                    ? () {
                        sl<TestingManager>().stopTesting();
                        Navigator.pushNamed(context, UploadingScreen.PATH);
                      }
                    : null,
                text: S.of(context).btnEndRecording,
              ),
            );
          },
        ),
        Spacer(flex: 2)
      ],
    );
  }
}

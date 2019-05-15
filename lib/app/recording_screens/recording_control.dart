import 'package:flutter/material.dart';
import 'package:my_pat/app/screens.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/time_utils.dart';
import 'package:my_pat/widgets/widgets.dart';

class RecordingControl extends StatelessWidget with WidgetsBindingObserver {
  void _checkTestState(BuildContext context) {
    if (sl<TestingManager>().stopTesting()) {
      Navigator.pushNamed(context, UploadingScreen.PATH);
    } else {
      _showTestIncompleteDialog(context);
    }
  }

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

  void _showTestIncompleteDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(S.of(context).not_enough_test_data),
                StreamBuilder(
                  stream: sl<TestingManager>().dataTimerStream,
                  initialData: GlobalSettings.minTestLengthSeconds,
                  builder: (context, AsyncSnapshot<int> snapshot) {
                    if (snapshot.hasData && snapshot.data == 0) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.of(context).pop();
                      });
                      return Container(height: 0, width: 0);
                    } else {
                      return Container(
                        padding: EdgeInsets.all(10.0),
                        child: Center(
                          child: Text(
                            '${TimeUtils.convertSecondsToHMmSs(snapshot.data)}',
                            style: Theme.of(context).textTheme.title,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(S.of(context).ok.toUpperCase()),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
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
                    '${TimeUtils.convertSecondsToHMmSs(snapshot.data)}',
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.title.fontSize,
                      color: Colors.white,
                    ),
                  );
                }
              },
            )),
        ButtonsBlock(
          moreActionButton: null,
          nextActionButton: ButtonModel(
            action: () => _checkTestState(context),
            text: S.of(context).btnEndRecording,
          ),
        )
      ],
    );
  }
}

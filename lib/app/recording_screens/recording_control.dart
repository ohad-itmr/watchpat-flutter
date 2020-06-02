import 'package:flutter/material.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/time_utils.dart';
import 'package:my_pat/widgets/widgets.dart';
import 'package:my_pat/generated/l10n.dart';

class RecordingControl extends StatelessWidget {
  _confirmEndTest(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text(S.of(context).stop_test),
              content: Text(S.of(context).confirm_stop_test),
              actions: <Widget>[
                FlatButton(
                  child: Text(S.of(context).cancel.toUpperCase()),
                  onPressed: () => Navigator.pop(context),
                ),
                FlatButton(
                  child: Text(S.of(context).ok),
                  onPressed: () {
                    sl<TestingManager>().stopButtonPressed();
//                    Navigator.pushNamed(context, UploadingScreen.PATH);
                  },
                )
              ],
            ));
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
                } else {
                  return Text("");
                }
              },
            )),
        Spacer(),
        ButtonsBlock(
          moreActionButton: null,
          nextActionButton: ButtonModel(
            action: () {
              if (sl<SystemStateManager>().testDataAmountState == TestDataAmountState.MINIMUM_PASSED) {
                _confirmEndTest(context);
              } else {
                _showTestTimerDialog(context);
              }
            },
            text: S.of(context).btnEndRecording,
          ),
        ),
        Spacer(flex: 2)
      ],
    );
  }

  void _showTestTimerDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              content: StreamBuilder(
                  stream: sl<TestingManager>().elapsedTimeStream,
                  initialData: 0,
                  builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                    int secToEnabled = GlobalSettings.minTestLengthSeconds - snapshot.data;
                    secToEnabled = secToEnabled > 0 ? secToEnabled : 0;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(S.of(context).you_can_end_recording + "\n"),
                        Text("${TimeUtils.convertSecondsToHMmSs(secToEnabled)}",
                            style: TextStyle(fontSize: Theme.of(context).textTheme.title.fontSize))
                      ],
                    );
                  }),
              actions: <Widget>[
                FlatButton(
                  child: Text(S.of(context).ok),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ));
  }
}

import 'package:flutter/material.dart';
import 'package:my_pat/app/screens.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/log/log.dart';
import 'package:my_pat/utils/time_utils.dart';
import 'package:my_pat/widgets/widgets.dart';

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
        StreamBuilder(
          stream: sl<SystemStateManager>().testDataAmountState,
          builder: (BuildContext context, AsyncSnapshot<TestDataAmountState> snapshot) {
            return ButtonsBlock(
              moreActionButton: null,
              nextActionButton: ButtonModel(
                action: snapshot.data == TestDataAmountState.MINIMUM_PASSED ? () => _confirmEndTest(context) : null,
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

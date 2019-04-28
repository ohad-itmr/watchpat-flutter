import 'package:flutter/material.dart';
import 'package:my_pat/app/screens.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/time_utils.dart';
import 'package:my_pat/widgets/widgets.dart';

class RecordingControl extends StatelessWidget {
  void _checkTestState(BuildContext context) {
    if (sl<TestingManager>().stopTesting()) {
      Navigator.pushNamed(context, UploadingScreen.PATH);
    } else {
      _showTestIncompleteDialog(context);
    }
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
                Text(
                    "Application didn't collect enough test data. You can stop test in:"),
                StreamBuilder(
                  stream: sl<TestingManager>().timer,
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
              child: Text("OK"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final S loc = sl<S>();

    return Flexible(
      flex: 2,
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 20.0),
            child: Text(
              loc.recordingTitle,
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.title.fontSize,
                color: Colors.white,
              ),
            ),
          ),
          ButtonsBlock(
            moreActionButton: null,
            nextActionButton: ButtonModel(
              action: () => _checkTestState(context),
              text: loc.btnEndRecording,
            ),
          )
        ],
      ),
    );
  }
}

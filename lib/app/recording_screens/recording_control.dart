import 'package:flutter/material.dart';
import 'package:my_pat/app/screens.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/widgets/widgets.dart';

class RecordingControl extends StatelessWidget {
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
              action: () {
                Navigator.pushNamed(context, UploadingScreen.PATH);
              },
              text: loc.btnEndRecording,
            ),
          )
        ],
      ),
    );
  }
}

import 'package:my_pat/generated/i18n.dart';
import 'package:flutter/material.dart';
import 'buttons_block.dart';


class RecordingControl extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final S loc = S.of(context);

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
                Navigator.pushNamed(context, '/uploading');
              },
              text: loc.btnEndRecording,
            ),
          )
        ],
      ),
    );
  }
}

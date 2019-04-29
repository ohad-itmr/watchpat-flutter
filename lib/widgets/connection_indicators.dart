import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_pat/service_locator.dart';

class ConnectionIndicators extends StatelessWidget {
  static final _manager = sl<ConnectionIndicatorManager>();

  Widget _buildLed(String image) {
    return Stack(
      children: <Widget>[
        Image(image: AssetImage('assets/indicator/${image}_frame.png')),
        StreamBuilder(
          stream: _streams[image],
          initialData: false,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return snapshot.data
                  ? Image(image: AssetImage('assets/indicator/$image.png'))
                  : Container(width: 0.0, height: 0.0);
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20.0,
      width: 45.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _buildLed(_BT_IMG),
          _buildLed(_SFTP_IMG),
        ],
      ),
    );
  }

  static const String _BT_IMG = "ind_bt";
  static const String _SFTP_IMG = "ind_sftp";
  final Map<String, Stream> _streams = {
    _BT_IMG: _manager.btLitStream,
    _SFTP_IMG: _manager.sftpLitStream
  };
}

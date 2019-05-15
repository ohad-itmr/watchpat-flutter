import 'package:flutter/material.dart';

import '../service_locator.dart';

class AppbarConnectionIndicators extends StatefulWidget {
  @override
  _AppbarConnectionIndicatorsState createState() =>
      _AppbarConnectionIndicatorsState();
}

class _AppbarConnectionIndicatorsState
    extends State<AppbarConnectionIndicators> {
  static final _manager = sl<ConnectionIndicatorManager>();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(height: 2.0),
          _buildLed(color: Theme.of(context).accentColor, indicator: _BT),
          _buildLed(color: Theme.of(context).primaryColor, indicator: _SFTP),
          Container(height: 2.0),
        ],
      ),
    );
  }

  _buildLed({Color color, String indicator}) {
    return StreamBuilder(
      stream: _streams[indicator],
      initialData: false,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        return CustomPaint(
          size: Size(6, 6),
          painter: IndicatorPainter(color: color, isLit: snapshot.data),
        );
      },
    );
  }

  static const String _BT = "ind_bt";
  static const String _SFTP = "ind_sftp";
  final Map<String, Stream> _streams = {
    _BT: _manager.btLitStream,
    _SFTP: _manager.sftpLitStream
  };
}

class IndicatorPainter extends CustomPainter {
  final Color color;
  final bool isLit;

  IndicatorPainter({this.color, this.isLit});

  @override
  void paint(Canvas canvas, Size size) {
    // white background
    canvas.drawCircle(
        Offset(3.0, 3.0),
        6.0,
        Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.white);

    // inner circle
    canvas.drawCircle(
        Offset(3.0, 3.0),
        5.0,
        Paint()
          ..style = PaintingStyle.fill
          ..color = isLit ? color : color.withOpacity(0.4));
  }

  @override
  bool shouldRepaint(IndicatorPainter oldDelegate) {
    return oldDelegate.isLit != isLit;
  }
}

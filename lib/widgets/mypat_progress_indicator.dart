import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_pat/services/services.dart';

import '../service_locator.dart';

class MyPatProgressIndicator extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: sl<TestingManager>().remainingDataProgressStream,
      initialData: 0.0,
      builder: (context, AsyncSnapshot<double> snapshot) {
        return CustomPaint(
          size: Size(120, 16),
          painter: ProgressPainter(progress: snapshot.data, color: Theme.of(context).accentColor),
        );
      },
    );
  }
}

class ProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  int _barsCount;

  ProgressPainter({@required this.progress, @required this.color}) {
    final int count = progress * 10 ~/ 1.6666;
    _barsCount = count < 7 ? count : 6;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double cornerRadius = size.height / 2;

    // outline
    canvas.drawRRect(
        RRect.fromLTRBR(
            size.width, size.height, 0.0, 0.0, Radius.circular(cornerRadius)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..color = color);

    // segments
    final double _barLength = size.height * 1.075;
    final double _gap = size.height / 8;
    double _offset = size.height / 5;

    for (var i = 0; i < _barsCount; i++) {
      canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(
                _offset, size.height / 5, _barLength, size.height * 0.6),
            topLeft: i == 0 ? Radius.circular(cornerRadius) : Radius.zero,
            bottomLeft: i == 0 ? Radius.circular(cornerRadius) : Radius.zero,
            topRight: i == 5 ? Radius.circular(cornerRadius) : Radius.zero,
            bottomRight: i == 5 ? Radius.circular(cornerRadius) : Radius.zero,
          ),
          Paint()..color = color);
      _offset += _barLength + _gap;
    }
  }

  @override
  bool shouldRepaint(ProgressPainter oldDelegate) {
    return oldDelegate._barsCount != _barsCount;
  }
}

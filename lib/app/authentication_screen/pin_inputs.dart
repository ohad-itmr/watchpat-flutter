import 'package:flutter/material.dart';
import 'package:my_pat/service_locator.dart';

class PinInputs extends StatelessWidget {
  static const String TAG = 'PinInputs';

  final AuthenticationManager pinManager = sl<AuthenticationManager>();

  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: size / 7),
      child: StreamBuilder(
        stream: pinManager.pinStream,
        builder: (_, AsyncSnapshot<List<int>> snapshot) {
          if (snapshot.hasData) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _generateDots(context, snapshot.data),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  List<Widget> _generateDots(BuildContext context, List<int> number) {
    List<Widget> dots = [];
    for (int i = 0; i < 4; i++) {
      dots.add(_buildDot(context, number[i]));
    }
    return dots;
  }

  Widget _buildDot(BuildContext context, int value) {
    final double size = MediaQuery.of(context).size.width;
    return Container(
      height: size / 7,
      width: size / 10,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color: Theme.of(context).accentColor.withOpacity(0.3),
            width: 2.0,
            style: BorderStyle.solid),
      ),
      child: Center(
        child: Text("${value ?? ''}",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: Theme.of(context).textTheme.title.fontSize)),
      ),
    );
  }
}

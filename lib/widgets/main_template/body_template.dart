import 'package:flutter/material.dart';
import '../steps.dart';

class BodyTemplate extends StatelessWidget {
  final Widget topBlock;
  final Widget bottomBlock;
  final Widget buttons;
  final bool showSteps;
  final int current;
  final int total;

  BodyTemplate({
    this.topBlock,
    this.bottomBlock,
    this.buttons,
    this.current,
    this.total,
    this.showSteps = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 30.0, right: 30.0),
      child: Column(
        children: <Widget>[
          Flexible(
            flex: 14,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  flex: 4,
                  child: topBlock,
                ),
                Flexible(
                  flex: 4,
                  child: bottomBlock,
                ),
              ],
            ),
          ),
          Flexible(
            flex: 2,
            child: Column(
              children: <Widget>[
                buttons,
                Steps(
                  current: current,
                  total: total,
                  showSteps: showSteps,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

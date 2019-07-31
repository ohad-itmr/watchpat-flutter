import 'package:flutter/material.dart';
import '../steps.dart';

class BodyTemplate extends StatelessWidget {
  final Widget topBlock;
  final Widget bottomBlock;
  final Widget buttons;
  final bool showSteps;
  final bool showCarousel;
  final int current;
  final int total;

  BodyTemplate(
      {this.topBlock,
      this.bottomBlock,
      this.buttons,
      this.current,
      this.total,
      this.showSteps = true,
      this.showCarousel = false});

  @override
  Widget build(BuildContext context) {
    final sidePadding = MediaQuery.of(context).size.width / 14;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: sidePadding),
      child: Column(
        children: <Widget>[
          Flexible(
            flex: 18,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  flex: 4,
                  child: topBlock ?? Container(height: 0.0, width: 0.0),
                ),
                Flexible(
                  flex: 4,
                  child: bottomBlock ?? Container(height: 0.0, width: 0.0),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 3,
            child: Column(
              children: <Widget>[
                buttons ?? Container(),
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

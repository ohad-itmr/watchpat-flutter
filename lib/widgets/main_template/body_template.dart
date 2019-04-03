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
            flex: 3,
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

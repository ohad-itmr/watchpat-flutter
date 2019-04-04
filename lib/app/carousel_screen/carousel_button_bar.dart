import 'package:flutter/material.dart';

class CarouselBar extends StatelessWidget {
  final CarouselBarPosition position;
  final Widget content;

  const CarouselBar({Key key, this.position, this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment:
      position == CarouselBarPosition.top ? Alignment.centerRight : null,
      decoration: BoxDecoration(
        borderRadius: position == CarouselBarPosition.top
            ? BorderRadius.vertical(top: Radius.circular(5.0))
            : BorderRadius.vertical(bottom: Radius.circular(5.0)),
        color: Theme.of(context).accentColor,
      ),
      height: 45.0,
      child: content,
    );
  }
}

enum CarouselBarPosition { top, bottom }
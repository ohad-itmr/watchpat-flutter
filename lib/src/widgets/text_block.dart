import 'package:flutter/material.dart';

class TextBlock extends StatelessWidget {
  final String title;
  final List<String> content;
  final TextAlign contentTextAlign;

  TextBlock({this.title, this.content, this.contentTextAlign = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      Text(
        title,
        textAlign: TextAlign.center,
        softWrap: true,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: Theme.of(context).textTheme.title.fontSize,
            color: Theme.of(context).textTheme.title.color),
      ),
      Container(
        height: 30.0,
      ),
    ];

    if (content != null) {
      content.forEach((str) {
        children.add(
          Text(
            str,
            textAlign: contentTextAlign,
            style: TextStyle(height: 1.3),
          ),
        );
        children.add(Text(''));
      });
    }

    return Column(
      children: children,
    );
  }
}

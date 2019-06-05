import 'package:flutter/material.dart';

class TextBlock extends StatelessWidget {
  final String title;
  final List<String> content;
  final TextAlign contentTextAlign;
  final Color textColor;
  final bool topPadding;
  final Widget additionalContent;

  TextBlock(
      {this.title,
      this.content,
      this.contentTextAlign = TextAlign.left,
      this.textColor,
      this.topPadding = false,
      this.additionalContent});

  @override
  Widget build(BuildContext context) {
    final double padding = MediaQuery.of(context).size.width / 16;
    final children = <Widget>[
      SizedBox(
        height: topPadding ? padding * 2 : 0.0,
      ),
      Text(
        title,
        textAlign: TextAlign.center,
        softWrap: true,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: Theme.of(context).textTheme.title.fontSize,
            color: textColor ?? Theme.of(context).textTheme.title.color),
      ),
      Container(
        height: padding,
      ),
    ];

    if (content != null) {
      content.forEach((str) {
        children.add(
          Text(
            str,
            textAlign: contentTextAlign,
            style: TextStyle(
              height: 1.3,
              color: textColor,
            ),
          ),
        );
        children.add(Text(''));
      });
    }

    if (additionalContent != null) children.add(additionalContent);

    return Column(
      children: children,
    );
  }
}

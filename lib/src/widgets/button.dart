import 'package:flutter/material.dart';

enum ButtonType { nextBtn, moreBtn }

class Button extends StatelessWidget {
  final String text;
  final Function action;
  final ButtonType type;

  Button({this.text, this.action, this.type});

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: action,
      child: Text(text),
      textColor: Colors.white,
      color: type == ButtonType.moreBtn
          ? Theme.of(context).accentColor
          : Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
    );
  }
}

import 'package:flutter/material.dart';

enum ButtonType { nextBtn, moreBtn }

class Button extends StatelessWidget {
  final String text;
  final Function action;
  final ButtonType type;
  final bool disabled;

  Button({this.text, this.action, this.type, this.disabled});

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: !disabled ? action : null,
      disabledColor: Colors.grey[300],
      child: Text(text),
      textColor: Colors.white,
      color: type == ButtonType.moreBtn
          ? Theme.of(context).accentColor
          : Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
    );
  }
}

import 'package:flutter/material.dart';

class CarouselButtonBlock extends StatelessWidget {
  final Function leftBtnCallback;
  final Function rightBtnCallback;

  const CarouselButtonBlock(
      {Key key, this.leftBtnCallback, this.rightBtnCallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: CarouselButton(
            title: 'PREVIOUS',
            onPressed: leftBtnCallback,
          ),
        ),
        Expanded(
          child: CarouselButton(
            title: 'NEXT',
            onPressed: rightBtnCallback,
          ),
        ),
      ],
    );
  }
}

class CarouselButton extends StatelessWidget {
  final String title;
  final Function onPressed;

  const CarouselButton({Key key, this.title, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text(
        title,
        style: TextStyle(
          color: onPressed != null ? Colors.white : Colors.grey[600],
        ),
      ),
      onPressed: onPressed,
    );
  }
}

import 'package:flutter/material.dart';

class ImageBlock extends StatelessWidget {
  final String imageName;

  ImageBlock({this.imageName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 50.0, bottom: 30.0),
      child: Image.asset('assets/$imageName'),
    );
  }
}

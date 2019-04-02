import 'package:flutter/material.dart';

class ImageBlock extends StatelessWidget {
  final String imageName;

  ImageBlock({this.imageName});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.only(top: screenWidth / 8, bottom: screenWidth / 12),

      child: Image.asset('assets/$imageName'),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:my_pat/app/carousel_screen/carousel_button_bar.dart';
import 'package:my_pat/app/carousel_screen/carousel_buttons.dart';

class CarouselDialog extends StatelessWidget {
  final String image;
  final String text;
  final Function leftBtnCallback;
  final Function rightBtnCallback;

  const CarouselDialog(
      {Key key,
        @required this.image,
        @required this.text,
        this.leftBtnCallback,
        this.rightBtnCallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth / 20, vertical: screenWidth / 8),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0), color: Colors.white),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              CarouselBar(
                position: CarouselBarPosition.top,
                content: IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context)),
              ),
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints.expand(),
                  child: Image(
                    image: AssetImage(image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, top: 16.0),
                      child: Text(text),
                    )
                  ],
                ),
              ),
              CarouselBar(
                position: CarouselBarPosition.bottom,
                content: CarouselButtonBlock(
                  leftBtnCallback: leftBtnCallback,
                  rightBtnCallback: rightBtnCallback,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:my_pat/app/carousel_screen/carousel_button_bar.dart';
import 'package:my_pat/app/carousel_screen/carousel_buttons.dart';

class CarouselDialogContainer extends StatelessWidget {
  final String image;
  final String text;
  final Function leftBtnCallback;
  final Function rightBtnCallback;

  const CarouselDialogContainer(
      {Key key,
        @required this.image,
        @required this.text,
        this.leftBtnCallback,
        this.rightBtnCallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Padding(
        padding: MediaQuery.of(context).viewInsets +
            const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0), color: Colors.white),
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

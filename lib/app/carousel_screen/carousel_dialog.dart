import 'package:flutter/material.dart';
import 'package:my_pat/app/carousel_screen/carousel_button_bar.dart';
import 'package:my_pat/app/carousel_screen/carousel_buttons.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../service_locator.dart';

class CarouselDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CarouselSnapshot>(
      stream: sl<CarouselManager>().carouselSnapshot,
      builder: (BuildContext ctx, AsyncSnapshot<CarouselSnapshot> snapshot) {
        if (snapshot.hasData && !snapshot.hasError) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              CarouselBar(
                position: CarouselBarPosition.top,
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
              ),
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints.expand(),
                  child: FadeInImage(
                    placeholder: MemoryImage(kTransparentImage),
                    image: AssetImage(snapshot.data.content.image),
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
                      child: Text(snapshot.data.content.text),
                    )
                  ],
                ),
              ),
              CarouselBar(
                position: CarouselBarPosition.bottom,
                content: CarouselButtonBlock(
                  leftBtnCallback: snapshot.data.actionPrev,
                  rightBtnCallback: snapshot.data.actionNext,
                ),
              )
            ],
          );
        } else {
          return Container(height: 0.0, width: 0.0);
        }
      },
    );
  }
}

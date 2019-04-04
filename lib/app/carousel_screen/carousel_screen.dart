import 'package:flutter/material.dart';
import 'package:my_pat/app/carousel_screen/carousel_dialog.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/widgets/widgets.dart';

class CarouselScreen extends StatelessWidget {
  static const String TAG = 'CarouselScreen';
  static const String PATH = '/carousel';

  final S loc = sl<S>();
  final CarouselManager carouselManager = sl<CarouselManager>();

  CarouselScreen(String tag) {
    carouselManager.loadCarouselData(tag);
  }

  @override
  Widget build(BuildContext context) {
    return MainTemplate(
      showBack: true,
      showMenu: false,
      body: _buildScreen(context),
    );
  }

  Widget _buildScreen(BuildContext ctx) {
    return StreamBuilder<CarouselSnapshot>(
      stream: carouselManager.carouselSnapshot,
      builder: (BuildContext ctx, AsyncSnapshot<CarouselSnapshot> snapshot) {
        if (snapshot.hasData && !snapshot.hasError) {
          return CarouselDialog(
            image: snapshot.data.content.image,
            text: snapshot.data.content.text,
            rightBtnCallback: snapshot.data.nextBtnCallback,
            leftBtnCallback: snapshot.data.prevBtnCallback,
          );
        } else {
          return Container(height: 0.0, width: 0.0);
        }
      },
    );
  }
}

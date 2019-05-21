import 'package:flutter/material.dart';
import 'package:my_pat/app/carousel_screen/carousel_dialog.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/widgets/widgets.dart';

class CarouselScreen extends StatelessWidget {
  static const String TAG = 'CarouselScreen';
  static const String PATH = '/carousel';

  final CarouselManager carouselManager = sl<CarouselManager>();

  CarouselScreen(String tag) {
    carouselManager.loadCarouselData(tag);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return MainTemplate(
      showBack: true,
      showMenu: false,
      body: Container(
        color: Colors.black.withOpacity(0.75),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth / 20, vertical: screenWidth / 8),
          child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: Colors.white),
              child: CarouselDialog()),
        ),
      ),
    );
  }
}

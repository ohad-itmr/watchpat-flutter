import 'package:flutter/material.dart';
import 'package:my_pat/app/carousel_screen/carousel_dialog.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/widgets/widgets.dart';

class CarouselScreen extends StatelessWidget {
  static const String TAG = 'CarouselScreen';
  static const String PATH = '/carousel';

  final S loc = sl<S>();
  final CarouselManager carouselManager = sl<CarouselManager>();

  @override
  Widget build(BuildContext context) {
    return MainTemplate(
      showBack: true,
      showMenu: false,
      body: _buildScreen(context),
    );
  }

  Widget _buildScreen(BuildContext ctx) {
    return StreamBuilder<CarouselData>(
      stream: carouselManager.carouselData,
      builder: (BuildContext ctx, AsyncSnapshot<CarouselData> snapshot) {
        if (snapshot.hasData && !snapshot.hasError) {
          return CarouselDialogContainer(
            image: snapshot.data.image,
            text: snapshot.data.text,
            leftBtnCallback: () => carouselManager.previousSlide(snapshot.data),
            rightBtnCallback: () => carouselManager.nextSlide(snapshot.data),
          );
        } else {
          return Container(height: 0.0, width: 0.0);
        }
      },
    );
  }
}

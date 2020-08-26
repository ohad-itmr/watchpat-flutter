import 'package:flutter/material.dart';
import 'package:my_pat/app/carousel_screen/carousel_button_bar.dart';
import 'package:my_pat/app/carousel_screen/carousel_buttons.dart';
import 'package:my_pat/generated/l10n.dart';
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
                  child: Image(
                    image: AssetImage(snapshot.data.content.image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                      child: Text(_getSlideText(snapshot.data.content.text, context)),
                    )
                  ],
                ),
              ),
              CarouselBar(
                position: CarouselBarPosition.bottom,
                content: CarouselButtonBlock(
                  leftBtnCallback: snapshot.data.actionPrev,
                  rightBtnCallback: snapshot.data.actionNext,
                  lastSlide: snapshot.data.lastSlide,
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

  String _getSlideText(String key, BuildContext context) {
    switch (key) {
      case "carousel_welcome":
        return S.of(context).carousel_welcome;
      case "carousel_battery_1":
        return S.of(context).carousel_battery_1;
      case "carousel_battery_2":
        return S.of(context).carousel_battery_2;
      case "carousel_prepare_1":
        return S.of(context).carousel_prepare_1;
      case "carousel_prepare_2":
        return S.of(context).carousel_prepare_2;
      case "carousel_identfy":
        return S.of(context).carousel_identfy;
      case "carousel_strap_1":
        return S.of(context).carousel_strap_1;
      case "carousel_strap_2":
        return S.of(context).carousel_strap_2;
      case "carousel_strap_3":
        return S.of(context).carousel_strap_3;
      case "carousel_chest_1":
        return S.of(context).carousel_chest_1;
      case "carousel_chest_2":
        return S.of(context).carousel_chest_2;
      case "carousel_chest_3":
        return S.of(context).carousel_chest_3;
      case "carousel_chest_4":
        return S.of(context).carousel_chest_4;
      case "carousel_chest_5":
        return S.of(context).carousel_chest_5;
      case "carousel_finger_1":
        return S.of(context).carousel_finger_1;
      case "carousel_finger_2":
        return S.of(context).carousel_finger_2;
      case "carousel_finger_3":
        return S.of(context).carousel_finger_3;
      case "carousel_finger_4":
        return S.of(context).carousel_finger_4;
      case "carousel_finger_5":
        return S.of(context).carousel_finger_5;
      case "carousel_finger_6":
        return S.of(context).carousel_finger_6;
      case "carousel_finger_7":
        return S.of(context).carousel_finger_7;
      case "carousel_sleep":
        return S.of(context).carousel_sleep;
      case "carousel_end_1_chest":
        return S.of(context).carousel_end_1_chest;
      case "carousel_end_2":
        return S.of(context).carousel_end_2;
      case "carousel_end_3":
        return S.of(context).carousel_end_3;
      case "carousel_end_4":
        return S.of(context).carousel_end_4;
      case "carousel_welcome":
        return S.of(context).carousel_welcome;
      case "carousel_end_5":
        return S.of(context).carousel_end_5;
      default:
        return "";
    }
  }
}

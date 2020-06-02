import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:my_pat/app/screens.dart';
import 'package:my_pat/managers/managers.dart';
import 'package:my_pat/service_locator.dart';
import 'package:rxdart/rxdart.dart';

class CarouselManager extends ManagerBase {
  static const String TAG = 'CarouselManager';
  static LinkedHashMap<String, List<CarouselData>> _scopedSlides;
  static List<CarouselData> _allSlides = [];

  final BehaviorSubject<CarouselSnapshot> _carouselDataState = BehaviorSubject<CarouselSnapshot>();

  Observable<CarouselSnapshot> get carouselSnapshot => _carouselDataState.stream;

  CarouselManager() {
    _prepareCarouselContent();
  }

  loadCarouselData(String screenTAG) {
    _checkWCPLessMode();
    final bool hasNext = screenTAG == WelcomeScreen.TAG || _scopedSlides[screenTAG].length != 1;
    final CarouselSnapshot s = CarouselSnapshot(
        content: _scopedSlides[screenTAG][0],
        actionPrev: null,
        actionNext: screenTAG == WelcomeScreen.TAG
            ? (_) => switchUnlimitedSlide(1)
            : hasNext ? (_) => switchLimitedSlide(screenTAG, 1) : (ctx) => Navigator.pop(ctx),
        lastSlide: !hasNext);
    _carouselDataState.sink.add(s);
  }

  switchLimitedSlide(String screenTAG, int currentIndex) {
    final bool hasNext = _scopedSlides[screenTAG].length != currentIndex + 1;
    final bool hasPrev = currentIndex != 0;
    final CarouselSnapshot s = CarouselSnapshot(
        content: _scopedSlides[screenTAG][currentIndex],
        actionPrev: hasPrev ? () => switchLimitedSlide(screenTAG, currentIndex - 1) : null,
        actionNext: hasNext ? (_) => switchLimitedSlide(screenTAG, currentIndex + 1) : (ctx) => Navigator.pop(ctx),
        lastSlide: !hasNext);
    _carouselDataState.sink.add(s);
  }

  switchUnlimitedSlide(int currentIndex) {
    final bool hasNext = _allSlides.length != currentIndex + 1;
    final bool hasPrev = currentIndex != 0;
    final CarouselSnapshot s = CarouselSnapshot(
        content: _allSlides[currentIndex],
        actionPrev: hasPrev ? () => switchUnlimitedSlide(currentIndex - 1) : null,
        actionNext: hasNext ? (_) => switchUnlimitedSlide(currentIndex + 1) : (ctx) => Navigator.pop(ctx),
        lastSlide: !hasNext);
    _carouselDataState.sink.add(s);
  }

  void _checkWCPLessMode() {
    if (GlobalSettings.wcpLessMode) {
      _scopedSlides.remove(ChestSensorScreen.TAG);
      _scopedSlides["END"].removeAt(0);

      _allSlides.removeWhere((CarouselData data) => data.image.contains("chest"));
    }
  }

  @override
  void dispose() {
    _carouselDataState.close();
  }

  _prepareCarouselContent() {
    _scopedSlides = LinkedHashMap.from({
      WelcomeScreen.TAG: [
        CarouselData(text: "carousel_welcome", image: "assets/carousel/carousel_welcome.jpg"),
      ],
      BatteryScreen.TAG: [
        CarouselData(text: "carousel_battery_1", image: "assets/carousel/carousel_battery_1.jpg"),
        CarouselData(text: "carousel_battery_2", image: "assets/carousel/carousel_battery_2.jpg"),
      ],
      PreparationScreen.TAG: [
        CarouselData(text: "carousel_prepare_1", image: "assets/carousel/carousel_prepare_1.jpg"),
        CarouselData(text: "carousel_prepare_2", image: "assets/carousel/carousel_prepare_2.jpg"),
      ],
      "IDENTITY": [
        CarouselData(text: "carousel_identfy", image: "assets/carousel/carousel_identfy.jpg"),
      ],
      StrapWristScreen.TAG: [
        CarouselData(text: "carousel_strap_1", image: "assets/carousel/carousel_strap_1.jpg"),
        CarouselData(text: "carousel_strap_2", image: "assets/carousel/carousel_strap_2.jpg"),
        CarouselData(text: "carousel_strap_3", image: "assets/carousel/carousel_strap_3.jpg"),
      ],
      ChestSensorScreen.TAG: [
        CarouselData(text: "carousel_chest_1", image: "assets/carousel/carousel_chest_1.jpg"),
        CarouselData(text: "carousel_chest_2", image: "assets/carousel/carousel_chest_2.jpg"),
        CarouselData(text: "carousel_chest_3", image: "assets/carousel/carousel_chest_3.jpg"),
        CarouselData(text: "carousel_chest_4", image: "assets/carousel/carousel_chest_4.jpg"),
        CarouselData(text: "carousel_chest_5", image: "assets/carousel/carousel_chest_5.jpg"),
      ],
      FingerProbeScreen.TAG: [
        CarouselData(text: "carousel_finger_1", image: "assets/carousel/carousel_finger_1.jpg"),
        CarouselData(text: "carousel_finger_2", image: "assets/carousel/carousel_finger_2.jpg"),
        CarouselData(text: "carousel_finger_3", image: "assets/carousel/carousel_finger_3.jpg"),
        CarouselData(text: "carousel_finger_4", image: "assets/carousel/carousel_finger_4.jpg"),
        CarouselData(text: "carousel_finger_5", image: "assets/carousel/carousel_finger_5.jpg"),
        CarouselData(text: "carousel_finger_6", image: "assets/carousel/carousel_finger_6.jpg"),
        CarouselData(text: "carousel_finger_7", image: "assets/carousel/carousel_finger_7.jpg"),
      ],
      StartRecordingScreen.TAG: [
        CarouselData(text: "carousel_sleep", image: "assets/carousel/carousel_sleep.jpg"),
      ],
      "END": [
        CarouselData(text: "carousel_end_1_chest", image: "assets/carousel/carousel_end_1_chest.jpg"),
        CarouselData(text: "carousel_end_2", image: "assets/carousel/carousel_end_2.jpg"),
        CarouselData(text: "carousel_end_3", image: "assets/carousel/carousel_end_3.jpg"),
        CarouselData(text: "carousel_end_4", image: "assets/carousel/carousel_end_4.jpg"),
        CarouselData(text: "carousel_end_5", image: "assets/carousel/carousel_end_5.jpg"),
      ]
    });
    _scopedSlides.values.forEach((list) => _allSlides.addAll(list));
  }
}

class CarouselSnapshot {
  final CarouselData content;
  final Function actionPrev;
  final Function(BuildContext context) actionNext;
  final bool lastSlide;

  CarouselSnapshot({this.content, this.actionPrev, this.actionNext, this.lastSlide});
}

class CarouselData {
  final String text;
  final String image;

  CarouselData({this.text, this.image});
}

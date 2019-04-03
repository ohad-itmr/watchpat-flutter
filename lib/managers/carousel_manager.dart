import 'dart:collection';

import 'package:my_pat/app/screens.dart';
import 'package:my_pat/managers/managers.dart';
import 'package:rxdart/rxdart.dart';

class CarouselManager extends ManagerBase {
  static const String TAG = 'CarouselManager';

  final BehaviorSubject<bool> _showCarouselState = BehaviorSubject<bool>();
  final BehaviorSubject<CarouselData> _carouselDataState =
      BehaviorSubject<CarouselData>.seeded(_carouselContent[WelcomeScreen.TAG]);

  Observable<bool> get showCarousel => _showCarouselState.stream;

  Observable<CarouselData> get carouselData => _carouselDataState.stream;

  presentCarousel(String screenTAG) {
    _showCarouselState.sink.add(true);
    _loadCarouselData(screenTAG);
  }

  nextSlide(CarouselData currentSlide) {
    final CarouselData nextSlide = _getNearbySlide(
        currentSlide: currentSlide, direction: SlideDirection.next);
    _carouselDataState.sink.add(nextSlide);
  }

  previousSlide(CarouselData currentSlide) {
    if (_carouselContent.values.toList().indexOf(currentSlide) == 0) return;
    final CarouselData nextSlide = _getNearbySlide(
        currentSlide: currentSlide, direction: SlideDirection.previous);
    _carouselDataState.sink.add(nextSlide);
  }

  CarouselData _getNearbySlide({CarouselData currentSlide, int direction}) {
    final int currentKeyIndex =
        _carouselContent.values.toList().indexOf(currentSlide);
    final String nextKey =
        _carouselContent.keys.toList()[currentKeyIndex + direction];
    return _carouselContent[nextKey];
  }

  dismissCarousel() {
    _showCarouselState.sink.add(false);
  }

  _loadCarouselData(String screenTAG) {
    _carouselDataState.sink.add(_carouselContent[screenTAG]);
  }

  @override
  void dispose() {
    _showCarouselState.close();
    _carouselDataState.close();
  }

  static final LinkedHashMap<String, CarouselData> _carouselContent =
      LinkedHashMap.from({
    WelcomeScreen.TAG: CarouselData(
        text:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
        image: "assets/carousel/test.jpg"),
    BatteryScreen.TAG: CarouselData(
        text: "This is Batteryu", image: "assets/carousel/test.jpg"),
    RemoveJewelryScreen.TAG: CarouselData(
        text: "Remove your jwrly", image: "assets/carousel/test.jpg"),
    PinScreen.TAG:
        CarouselData(text: "Ping screeen", image: "assets/carousel/test.jpg"),
    StrapWristScreen.TAG: CarouselData(
        text: "Strap Swap Wrist Something", image: "assets/carousel/test.jpg"),
    ChestSensorScreen.TAG:
        CarouselData(text: "", image: "assets/carousel/test.jpg"),
    FingerProbeScreen.TAG:
        CarouselData(text: "", image: "assets/carousel/test.jpg"),
    StartRecordingScreen.TAG:
        CarouselData(text: "", image: "assets/carousel/test.jpg")
  });
}

class CarouselData {
  final String text;
  final String image;

  CarouselData({this.text, this.image});
}

class SlideDirection {
  static const int previous = -1;
  static const int next = 1;
}

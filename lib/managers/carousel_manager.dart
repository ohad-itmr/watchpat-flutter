import 'dart:collection';
import 'package:my_pat/app/screens.dart';
import 'package:my_pat/managers/managers.dart';
import 'package:rxdart/rxdart.dart';

class CarouselManager extends ManagerBase {
  static const String TAG = 'CarouselManager';
  static LinkedHashMap<String, List<CarouselData>> _scopedSlides;
  static List<CarouselData> _allSlides = [];

  final BehaviorSubject<CarouselSnapshot> _carouselDataState =
      BehaviorSubject<CarouselSnapshot>.seeded(null);

  Observable<CarouselSnapshot> get carouselSnapshot =>
      _carouselDataState.stream;

  CarouselManager() {
    _prepareCarouselContent();
  }

  loadCarouselData(String screenTAG) {
    final CarouselSnapshot s = CarouselSnapshot(
        content: _scopedSlides[screenTAG][0],
        prevBtnCallback: null,
        nextBtnCallback: screenTAG == WelcomeScreen.TAG
            ? () => switchUnlimitedSlide(1)
            : () => switchLimitedSlide(screenTAG, 1));
    _carouselDataState.sink.add(s);
  }

  switchLimitedSlide(String screenTAG, int currentIndex) {
    final bool hasNext = _scopedSlides[screenTAG].length != currentIndex + 1;
    final bool hasPrev = currentIndex != 0;
    final CarouselSnapshot s = CarouselSnapshot(
        content: _scopedSlides[screenTAG][currentIndex],
        prevBtnCallback: hasPrev
            ? () => switchLimitedSlide(screenTAG, currentIndex - 1)
            : null,
        nextBtnCallback: hasNext
            ? () => switchLimitedSlide(screenTAG, currentIndex + 1)
            : null);
    _carouselDataState.sink.add(s);
  }

  switchUnlimitedSlide(int currentIndex) {
    final bool hasNext = _allSlides.length != currentIndex + 1;
    final bool hasPrev = currentIndex != 0;
    final CarouselSnapshot s = CarouselSnapshot(
        content: _allSlides[currentIndex],
        prevBtnCallback:
            hasPrev ? () => switchUnlimitedSlide(currentIndex - 1) : null,
        nextBtnCallback:
            hasNext ? () => switchUnlimitedSlide(currentIndex + 1) : null);
    _carouselDataState.sink.add(s);
  }

  @override
  void dispose() {
    _carouselDataState.close();
  }

  _prepareCarouselContent() {
    _scopedSlides = LinkedHashMap.from({
      WelcomeScreen.TAG: [
        CarouselData(
            text: "Welcome Screen Slide 1", image: "assets/carousel/test.png"),
        CarouselData(
            text: "Welcome Screen Slide 2", image: "assets/carousel/test.png"),
        CarouselData(
            text: "Welcome Screen Slide 3", image: "assets/carousel/test.png")
      ],
      BatteryScreen.TAG: [
        CarouselData(
            text: "Battery Screen Slide 1", image: "assets/carousel/test.png"),
        CarouselData(
            text: "Battery Screen Slide 2", image: "assets/carousel/test.png"),
        CarouselData(
            text: "Battery Screen Slide 3", image: "assets/carousel/test.png")
      ],
      RemoveJewelryScreen.TAG: [
        CarouselData(
            text: "RemoveJewelryScreen Slide 1",
            image: "assets/carousel/test.png"),
        CarouselData(
            text: "RemoveJewelryScreen Slide 2",
            image: "assets/carousel/test.png"),
        CarouselData(
            text: "RemoveJewelryScreen Slide 3",
            image: "assets/carousel/test.png")
      ],
      StrapWristScreen.TAG: [
        CarouselData(
            text: "StrapWristScreen Slide 1",
            image: "assets/carousel/test.png"),
        CarouselData(
            text: "StrapWristScreen Slide 2",
            image: "assets/carousel/test.png"),
        CarouselData(
            text: "StrapWristScreen Slide 3",
            image: "assets/carousel/test.png")
      ],
      ChestSensorScreen.TAG: [
        CarouselData(
            text: "ChestSensorScreen Slide 1",
            image: "assets/carousel/test.png"),
        CarouselData(
            text: "ChestSensorScreen Slide 2",
            image: "assets/carousel/test.png"),
        CarouselData(
            text: "ChestSensorScreen Slide 3",
            image: "assets/carousel/test.png")
      ],
      FingerProbeScreen.TAG: [
        CarouselData(
            text: "FingerProbeScreen Slide 1",
            image: "assets/carousel/test.png"),
        CarouselData(
            text: "FingerProbeScreen Slide 2",
            image: "assets/carousel/test.png"),
        CarouselData(
            text: "FingerProbeScreen Slide 3",
            image: "assets/carousel/test.png")
      ],
    });
    _scopedSlides.values.forEach((list) => _allSlides.addAll(list));
  }
}

class CarouselSnapshot {
  final CarouselData content;
  final Function prevBtnCallback;
  final Function nextBtnCallback;

  CarouselSnapshot({this.content, this.prevBtnCallback, this.nextBtnCallback});
}

class CarouselData {
  final String text;
  final String image;

  CarouselData({this.text, this.image});
}

import 'dart:collection';
import 'package:my_pat/app/screens.dart';
import 'package:my_pat/managers/managers.dart';
import 'package:rxdart/rxdart.dart';

class CarouselManager extends ManagerBase {
  static const String TAG = 'CarouselManager';

  final BehaviorSubject<CarouselSnapshot> _carouselDataState =
      BehaviorSubject<CarouselSnapshot>.seeded(null);

  Observable<CarouselSnapshot> get carouselSnapshot =>
      _carouselDataState.stream;

  loadCarouselData(String screenTAG) {
    final CarouselSnapshot s = CarouselSnapshot(
      content: _carouselContent[screenTAG][0],
      prevBtnCallback: null,
      nextBtnCallback: () => switchSlide(screenTAG, 1)
    );
    _carouselDataState.sink.add(s);
  }

  switchSlide(String screenTAG, int currentIndex) {
    final bool hasNext = _carouselContent[screenTAG].length != currentIndex + 1;
    final bool hasPrev = currentIndex != 0;
    final CarouselSnapshot s = CarouselSnapshot(
        content: _carouselContent[screenTAG][currentIndex],
        prevBtnCallback: hasPrev ? () => switchSlide(screenTAG, currentIndex - 1) : null,
        nextBtnCallback: hasNext ? () => switchSlide(screenTAG, currentIndex + 1) : null
    );
    _carouselDataState.sink.add(s);
  }

  @override
  void dispose() {
    _carouselDataState.close();
  }

  static final LinkedHashMap<String, List<CarouselData>>
      _carouselContent = LinkedHashMap.from({
    WelcomeScreen.TAG: [
      CarouselData(
          text: "Welcome Screen Slide 1",
          image: "assets/carousel/test.jpg",
          tag: WelcomeScreen.TAG),
      CarouselData(
          text: "Welcome Screen Slide 2",
          image: "assets/carousel/test.jpg",
          tag: WelcomeScreen.TAG),
      CarouselData(
          text: "Welcome Screen Slide 3",
          image: "assets/carousel/test.jpg",
          tag: WelcomeScreen.TAG)
    ],
    BatteryScreen.TAG: [
      CarouselData(
          text: "Battery Screen Slide 1",
          image: "assets/carousel/test.jpg",
          tag: BatteryScreen.TAG),
      CarouselData(
          text: "Battery Screen Slide 2",
          image: "assets/carousel/test.jpg",
          tag: BatteryScreen.TAG),
      CarouselData(
          text: "Battery Screen Slide 3",
          image: "assets/carousel/test.jpg",
          tag: BatteryScreen.TAG)
    ],
    RemoveJewelryScreen.TAG: [
      CarouselData(
          text: "RemoveJewelryScreen Slide 1",
          image: "assets/carousel/test.jpg",
          tag: RemoveJewelryScreen.TAG),
      CarouselData(
          text: "RemoveJewelryScreen Slide 2",
          image: "assets/carousel/test.jpg",
          tag: RemoveJewelryScreen.TAG),
      CarouselData(
          text: "RemoveJewelryScreen Slide 3",
          image: "assets/carousel/test.jpg",
          tag: RemoveJewelryScreen.TAG)
    ],
  });
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
  final String tag;

  CarouselData({this.text, this.image, this.tag});
}
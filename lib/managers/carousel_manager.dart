import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:my_pat/app/screens.dart';
import 'package:my_pat/managers/managers.dart';
import 'package:rxdart/rxdart.dart';

class CarouselManager extends ManagerBase {
  static const String TAG = 'CarouselManager';
  static LinkedHashMap<String, List<CarouselData>> _scopedSlides;
  static List<CarouselData> _allSlides = [];

  final BehaviorSubject<CarouselSnapshot> _carouselDataState =
      BehaviorSubject<CarouselSnapshot>();

  Observable<CarouselSnapshot> get carouselSnapshot =>
      _carouselDataState.stream;

  CarouselManager() {
    _prepareCarouselContent();
  }

  loadCarouselData(String screenTAG) {
    final CarouselSnapshot s = CarouselSnapshot(
        content: _scopedSlides[screenTAG][0],
        actionPrev: null,
        actionNext: screenTAG == WelcomeScreen.TAG
            ? (_) => switchUnlimitedSlide(1)
            : (_) => switchLimitedSlide(screenTAG, 1),
        lastSlide: false);
    _carouselDataState.sink.add(s);
  }

  switchLimitedSlide(String screenTAG, int currentIndex) {
    final bool hasNext = _scopedSlides[screenTAG].length != currentIndex + 1;
    final bool hasPrev = currentIndex != 0;
    final CarouselSnapshot s = CarouselSnapshot(
        content: _scopedSlides[screenTAG][currentIndex],
        actionPrev: hasPrev
            ? () => switchLimitedSlide(screenTAG, currentIndex - 1)
            : null,
        actionNext: hasNext
            ? (_) => switchLimitedSlide(screenTAG, currentIndex + 1)
            : (ctx) => Navigator.pop(ctx),
        lastSlide: !hasNext);
    _carouselDataState.sink.add(s);
  }

  switchUnlimitedSlide(int currentIndex) {
    final bool hasNext = _allSlides.length != currentIndex + 1;
    final bool hasPrev = currentIndex != 0;
    final CarouselSnapshot s = CarouselSnapshot(
        content: _allSlides[currentIndex],
        actionPrev:
            hasPrev ? () => switchUnlimitedSlide(currentIndex - 1) : null,
        actionNext: hasNext
            ? (_) => switchUnlimitedSlide(currentIndex + 1)
            : (ctx) => Navigator.pop(ctx),
        lastSlide: !hasNext);
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
            text:
                "Open the package, making sure you have a AAA battery along with the device and its sensors",
            image: "assets/carousel/carousel_welcome.jpg"),
      ],
      BatteryScreen.TAG: [
        CarouselData(
            text: "Insert the battery into the device",
            image: "assets/carousel/carousel_battery_1.jpg"),
        CarouselData(
            text:
                "Make sure you follow the + and - marking, and with flat side against the spring",
            image: "assets/carousel/carousel_battery_2.jpg"),
      ],
      RemoveJewelryScreen.TAG: [
        CarouselData(
            text:
                "Remove all jewelry and hand cream. Make sure the fingernails are trimmed.",
            image: "assets/carousel/carousel_prepare_1.jpg"),
        CarouselData(
            text: "Take off the watch. Do not apply any hand cream.",
            image: "assets/carousel/carousel_prepare_2.jpg"),
      ],
      "IDENTITY": [
        CarouselData(
            text:
                "Enter your assigned four digits PIN (personal identification number).",
            image: "assets/carousel/carousel_identfy.jpg"),
      ],
      StrapWristScreen.TAG: [
        CarouselData(
            text: "You will be putting the WatchPAT on your non-dominant hand.",
            image: "assets/carousel/carousel_strap_1.jpg"),
        CarouselData(
            text: "Place the WatchPAT on a flat surface.",
            image: "assets/carousel/carousel_strap_2.jpg"),
        CarouselData(
            text:
                "Insert your hand and close the strap, making sure it's snug but not too tight.",
            image: "assets/carousel/carousel_strap_3.jpg"),
      ],
      ChestSensorScreen.TAG: [
        CarouselData(
            text: "Thread the sensor through your sleeve …",
            image: "assets/carousel/carousel_chest_1.jpg"),
        CarouselData(
            text: "… up to the neck opening.",
            image: "assets/carousel/carousel_chest_2.jpg"),
        CarouselData(
            text: "Peel the sticker off the back end of the sensor.",
            image: "assets/carousel/carousel_chest_3.jpg"),
        CarouselData(
            text:
                "Attach the sensor just below the sternum notch. Trim or shave here if needed.",
            image: "assets/carousel/carousel_chest_4.jpg"),
        CarouselData(
            text: "You may also secure the sensor with a medical tape.",
            image: "assets/carousel/carousel_chest_5.jpg"),
      ],
      FingerProbeScreen.TAG: [
        CarouselData(
            text:
                "Place the finger probe on your index finger. Once placed, the probe can not be removed and put on another finger.",
            image: "assets/carousel/carousel_finger_1.jpg"),
        CarouselData(
            text:
                "If your index finger is too large for the probe, choose another finger that fits better.",
            image: "assets/carousel/carousel_finger_2.jpg"),
        CarouselData(
            text: "Insert your index finger all the way into the probe.",
            image: "assets/carousel/carousel_finger_3.jpg"),
        CarouselData(
            text:
                "The tab on top of the probe should be situated on the top side of your finger.",
            image: "assets/carousel/carousel_finger_4.jpg"),
        CarouselData(
            text: "While pushing against the surface …",
            image: "assets/carousel/carousel_finger_5.jpg"),
        CarouselData(
            text:
                "Gently but firmly remove the tab by pulling upward its tip …",
            image: "assets/carousel/carousel_finger_6.jpg"),
        CarouselData(
            text: "… until fully removed.",
            image: "assets/carousel/carousel_finger_7.jpg"),
      ],
      "SLEEP": [
        CarouselData(
            text: "WatchPAT is working properly and it is time to go to sleep.",
            image: "assets/carousel/carousel_sleep.jpg"),
      ],
      "END": [
        CarouselData(
            text: "In the morning remove the probe from your finger.",
            image: "assets/carousel/carousel_end_1.jpg"),
        CarouselData(
            text: "Remove the device from your hand.",
            image: "assets/carousel/carousel_end_2.jpg"),
        CarouselData(
            text: "Remove the Chest sensor.",
            image: "assets/carousel/carousel_end_3.jpg"),
        CarouselData(
            text: "Remove the battery from device and keep for other uses.",
            image: "assets/carousel/carousel_end_4.jpg"),
        CarouselData(
            text:
                "Follow the local recycling instructions regarding disposal or recycling of the device and device components.",
            image: "assets/carousel/carousel_end_5.jpg"),
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

  CarouselSnapshot(
      {this.content, this.actionPrev, this.actionNext, this.lastSlide});
}

class CarouselData {
  final String text;
  final String image;

  CarouselData({this.text, this.image});
}

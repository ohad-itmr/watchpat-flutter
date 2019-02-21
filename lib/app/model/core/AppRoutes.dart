import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:MyPAT/bloc/pin_bloc_provider.dart';
import 'package:MyPAT/ui/screens/BatteryScreen.dart';
import 'package:MyPAT/ui/screens/ChestSensorScreen.dart';
import 'package:MyPAT/ui/screens/EndScreen.dart';
import 'package:MyPAT/ui/screens/FingerProbeScreen.dart';
import 'package:MyPAT/ui/screens/PinScreen.dart';
import 'package:MyPAT/ui/screens/RecordingScreen.dart';
import 'package:MyPAT/ui/screens/RemoveJewelryScreen.dart';
import 'package:MyPAT/ui/screens/StartRecordingScreen.dart';
import 'package:MyPAT/ui/screens/StrapWristScreen.dart';
import 'package:MyPAT/ui/screens/UploadingScreen.dart';
import 'package:MyPAT/ui/screens/WelcomeScreen.dart';

var rootHandler =
    Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return WelcomeScreen();
});

var batteryRouteHandler =
    Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return BatteryScreen();
});

var chestSensorRouteHandler =
    Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return ChestSensorScreen();
});

var endRouteHandler =
    Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return EndScreen();
});

var fingerProbeRouteHandler =
    Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return FingerProbeScreen();
});

var pinRouteHandler =
    Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  final PinBloc pinBloc = PinBlocProvider.of(context);
  pinBloc.resetPin();
  return PinScreen();
});

var recordingRouteHandler =
    Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return RecordingScreen();
});

var removeJewelryRouteHandler =
    Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return RemoveJewelryScreen();
});

var startRouteHandler =
    Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return StartRecordingScreen();
});

var strapWristRouteHandler =
    Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return StrapWristScreen();
});

var uploadingRouteHandler =
    Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return UploadingScreen();
});

class AppRoutes {
  static void configureRoutes(Router router) {
    router.notFoundHandler =
        Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      print('ROUTE WAS NOT FOUND !!!');
    });

    router.define(WelcomeScreen.PATH,
        handler: rootHandler, transitionType: TransitionType.native);
    router.define(BatteryScreen.PATH,
        handler: batteryRouteHandler, transitionType: TransitionType.native);
    router.define(ChestSensorScreen.PATH,
        handler: chestSensorRouteHandler, transitionType: TransitionType.native);
    router.define(EndScreen.PATH,
        handler: endRouteHandler, transitionType: TransitionType.native);
    router.define(FingerProbeScreen.PATH,
        handler: fingerProbeRouteHandler, transitionType: TransitionType.native);
    router.define(PinScreen.PATH,
        handler: pinRouteHandler, transitionType: TransitionType.native);
    router.define(RecordingScreen.PATH, handler: recordingRouteHandler);
    router.define(RemoveJewelryScreen.PATH,
        handler: removeJewelryRouteHandler, transitionType: TransitionType.native);
    router.define(StartRecordingScreen.PATH,
        handler: startRouteHandler, transitionType: TransitionType.native);
    router.define(StrapWristScreen.PATH,
        handler: strapWristRouteHandler, transitionType: TransitionType.native);
    router.define(UploadingScreen.PATH,
        handler: uploadingRouteHandler, transitionType: TransitionType.native);
  }
}

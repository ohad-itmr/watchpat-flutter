import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:my_pat/bloc/bloc_provider.dart';
import 'package:my_pat/ui/screens/battery_screen.dart';
import 'package:my_pat/ui/screens/chest_sensor_screen.dart';
import 'package:my_pat/ui/screens/end_screen.dart';
import 'package:my_pat/ui/screens/finger_probe_screen.dart';
import 'package:my_pat/ui/screens/pin_screen.dart';
import 'package:my_pat/ui/screens/recording_screen.dart';
import 'package:my_pat/ui/screens/remove_jewelry_screen.dart';
import 'package:my_pat/ui/screens/start_recording_screen.dart';
import 'package:my_pat/ui/screens/strap_wrist_screen.dart';
import 'package:my_pat/ui/screens/uploading_screen.dart';
import 'package:my_pat/ui/screens/welcome_screen.dart';
import 'package:my_pat/ui/screens/splash_screen.dart';

var rootHandler =
    Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return SplashScreen();
});

var welcomeHandler =
    Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  final BleBloc bleBloc = BlocProvider.of<BleBloc>(context);
  final WelcomeActivityBloc welcomeBloc = BlocProvider.of<WelcomeActivityBloc>(context);
  welcomeBloc.init();
  bleBloc.startScan(time: 3, connectToFirstDevice: false);
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
  final PinBloc pinBloc = BlocProvider.of<PinBloc>(context);
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

    router.define(SplashScreen.PATH,
        handler: rootHandler, transitionType: TransitionType.native);

    router.define(WelcomeScreen.PATH,
        handler: welcomeHandler, transitionType: TransitionType.native);
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

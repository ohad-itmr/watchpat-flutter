import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:date_format/date_format.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:my_pat/app/screens.dart';
import 'package:my_pat/app/service_screen/service_password_prompt.dart';
import 'package:my_pat/app/service_screen/service_screen.dart';
import 'package:my_pat/service_locator.dart';
import 'package:rxdart/rxdart.dart';

class SplashScreen extends StatefulWidget {
  static const String PATH = '/';
  static const String TAG = 'SplashScreen';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final S loc = sl<S>();

  static const _BT_MAP_KEY = "bt";
  static const _TEST_MAP_KEY = "test";

  // dialogs states
  bool _btWarningShow = false;

  StreamSubscription _navigationSub;

  final BleManager bleManager = sl<BleManager>();
  final ServiceScreenManager _serviceManager = sl<ServiceScreenManager>();
  final SystemStateManager _systemStateManager = sl<SystemStateManager>();

  @override
  void initState() {
//    _systemStateManager.inetConnectionStateStream
//        .where((_) => this.mounted)
//        .listen((ConnectivityResult state) {
//      if (state == ConnectivityResult.none) {
//        _showNoInternetWarning(context);
//      }
//    });

    _serviceManager.serviceModesStream.listen((mode) {
      if (mode == ServiceMode.customer) {
        sl<SystemStateManager>().setAppMode(AppModes.CS);
        sl<SystemStateManager>()
            .changeState
            .add(StateChangeActions.APP_MODE_CHANGED);
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ServiceScreen(mode: mode)));
      } else if (mode == ServiceMode.technician) {
        _showServicePasswordPrompt();
      }
    });

    _navigationSub = Observable.combineLatest2(
            _systemStateManager.btStateStream,
            _systemStateManager.testStateStream,
            (BtStates btState, TestStates testState) =>
                {_BT_MAP_KEY: btState, _TEST_MAP_KEY: testState})
        .where((Map<String, dynamic> data) =>
            this.mounted && data[_BT_MAP_KEY] == BtStates.ENABLED)
        .listen((Map<String, dynamic> data) {
      if (data[_TEST_MAP_KEY] == TestStates.INTERRUPTED) {
        sl<WelcomeActivityManager>().initConnectivityListener();
        Navigator.of(context).pushNamed(RecordingScreen.PATH);
        _navigationSub.cancel();
      } else {
        Navigator.of(context).pushNamed(WelcomeScreen.PATH);
        _navigationSub.cancel();
      }
    });

    _systemStateManager.btStateStream.listen((BtStates state) {
      if (state == BtStates.NOT_AVAILABLE && !_btWarningShow) {
        _showBTWarning();
        _btWarningShow = true;
      } else if (state == BtStates.ENABLED && _btWarningShow) {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        _btWarningShow = false;
      }
    });

    super.initState();
  }

  void _showServicePasswordPrompt() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => ServicePasswordPrompt());
  }

  void _showBTWarning() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S.of(context).bt_initiation_error),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(S.of(context).bt_must_be_enabled),
                Container(
                    padding: EdgeInsets.all(20.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            child: Padding(
      padding: EdgeInsets.all(55.0),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/splash.png'),
            fit: BoxFit.contain,
          ),
        ),
      ),
    )));
  }
}

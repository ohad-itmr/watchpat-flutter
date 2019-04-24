import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_pat/app/screens.dart';
import 'package:my_pat/service_locator.dart';
import 'package:rxdart/rxdart.dart';

class SplashScreen extends StatelessWidget {
  static const String PATH = '/';
  final S loc = sl<S>();
  static const String TAG = 'SplashScreen';

  static const _BT_MAP_KEY = "bt";
  static const _TEST_MAP_KEY = "test";

  final BleManager bleManager = sl<BleManager>();
  final SystemStateManager systemStateManager = sl<SystemStateManager>();

  Future<void> _showBTWarning(
    BuildContext context,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(loc.bt_initiation_error),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(loc.bt_must_be_enabled),
                StreamBuilder(
                  stream: systemStateManager.btStateStream,
                  builder: (context, AsyncSnapshot<BtStates> snapshot) {
                    if (snapshot.hasData && snapshot.data == BtStates.ENABLED) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.of(context).pop();
                        Navigator.of(context)
                            .pushReplacementNamed(WelcomeScreen.PATH);
                      });
                    }
                    return Container(
                      padding: EdgeInsets.all(10.0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
//    print(appBloc.initialChecksComplete.listen((onData) => print('onData $onData')));

    return Scaffold(
      body: Container(
        child: StreamBuilder(
//          stream: systemStateManager.btStateStream,
          stream: Observable.combineLatest2(
              systemStateManager.btStateStream,
              systemStateManager.testStateStream,
              (BtStates btState, TestStates testState) => {
                    _BT_MAP_KEY: btState,
                    _TEST_MAP_KEY: testState
                  }).asBroadcastStream(),
          builder: (context, AsyncSnapshot<Map> bleSnapshot) {
            if (bleSnapshot.hasData) {
              if (bleSnapshot.data[_BT_MAP_KEY] != BtStates.ENABLED) {
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _showBTWarning(context));
              } else {
                if (bleSnapshot.data[_TEST_MAP_KEY] == TestStates.INTERRUPTED) {
                  sl<BleManager>().startScan(time: 3000, connectToFirstDevice: false);
                  sl<WelcomeActivityManager>().initConnectivityListener();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.of(context)
                        .pushReplacementNamed(RecordingScreen.PATH);
                  });
                } else {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.of(context)
                        .pushReplacementNamed(WelcomeScreen.PATH);
                  });
                }
              }
            }

            return Padding(
              padding: EdgeInsets.all(55.0),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/splash.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

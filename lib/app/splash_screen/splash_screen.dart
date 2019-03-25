import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_pat/service_locator.dart';

class SplashScreen extends StatelessWidget {
  static const String PATH = '/';
  final S loc = sl<S>();
  static const String TAG = 'SplashScreen';

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
                        Navigator.of(context).pushReplacementNamed('/welcome');
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
          stream: systemStateManager.btStateStream,
          builder: (context, AsyncSnapshot<BtStates> bleSnapshot) {
            if (bleSnapshot.hasData) {
              if (bleSnapshot.data != BtStates.ENABLED) {
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _showBTWarning(context));
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pushReplacementNamed('/welcome');
                });
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

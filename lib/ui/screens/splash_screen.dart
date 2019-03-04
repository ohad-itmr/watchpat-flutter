import 'dart:async';
import 'package:flutter_blue/flutter_blue.dart';
import '../../generated/i18n.dart';
import 'package:flutter/material.dart';
import 'package:my_pat/bloc/bloc_provider.dart';

class SplashScreen extends StatelessWidget {
  static const String PATH = '/';

  Future<void> _showBTWarning(
    BuildContext context,
    S loc,
    BleBloc bloc,
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
                  stream: bloc.bleState,
                  initialData: BluetoothState.off,
                  builder: (context, AsyncSnapshot<BluetoothState> snapshot) {
                    if (snapshot.hasData && snapshot.data == BluetoothState.on) {
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
    final BleBloc bloc = BlocProvider.of<BleBloc>(context);
//    print(appBloc.initialChecksComplete.listen((onData) => print('onData $onData')));
    final S loc = S.of(context);




    return Scaffold(
      body: Container(
        child: StreamBuilder(
          stream: bloc.bleState,
          builder: (context, AsyncSnapshot<BluetoothState> bleSnapshot) {
            if (bleSnapshot.hasData) {
              if (bleSnapshot.data != BluetoothState.on) {
                WidgetsBinding.instance.addPostFrameCallback((_) => _showBTWarning(context,loc,bloc));
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

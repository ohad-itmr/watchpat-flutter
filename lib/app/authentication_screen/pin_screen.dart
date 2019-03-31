import 'package:flutter/material.dart';
import 'package:my_pat/app/authentication_screen/pin_inputs.dart';
import 'package:my_pat/app/authentication_screen/pin_keyboard.dart';
import 'package:my_pat/app/screens.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/widgets/widgets.dart';

class PinScreen extends StatelessWidget {
  static const String TAG = 'PinScreen';
  static const String PATH = '/pin';
  final S loc = sl<S>();
  final PinManager pinManager = sl<PinManager>();
  final GlobalKey _ctxKey = GlobalKey(); // For navigator context

  PinScreen({Key key}) : super(key: key);

  _checkPin() {
    print('PIN is ${pinManager.pin}');
    pinManager.authStateStream.listen((state) {
      print('authStateStream.listen((state) $state');
      switch (state) {
        case PatientAuthState.Authenticated:
          Navigator.of(_ctxKey.currentContext)
              .pushReplacementNamed(StrapWristScreen.PATH);
          break;
        case PatientAuthState.FailedTryAgain:
          print('PatientAuthState.FailedTryAgain');
          break;
        case PatientAuthState.FailedClose:
          print('PatientAuthState.FailedClose');
          break;
        default:
          break;
      }
    });
    pinManager.authenticatePatient();
  }

  @override
  Widget build(BuildContext context) {
    return MainTemplate(
      showBack: true,
      showMenu: false,
      body: Column(
        key: _ctxKey,
        children: <Widget>[
          Flexible(
            flex: 8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: PinInputs(),
                ),
                TextBlock(
                  title: loc.pinTitle,
                  contentTextAlign: TextAlign.center,
                  content: [loc.pinContent],
                ),
                StreamBuilder(
                  stream: pinManager.authStateStream,
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<PatientAuthState> snapshot,
                  ) {
                    if (snapshot.hasData &&
                        snapshot.data == PatientAuthState.InProgress) {
                      return Container(
                        padding: EdgeInsets.only(bottom: 20.0),
                        child: CircularProgressIndicator(),
                      );
                    }
                    return Container(
                      padding: EdgeInsets.only(bottom: 20.0),
                      child: StreamBuilder(
                        stream: pinManager.pinIsValid,
                        initialData: false,
                        builder: (
                          BuildContext context,
                          AsyncSnapshot<bool> snapshot,
                        ) {
                          return ButtonsBlock(
                            nextActionButton: ButtonModel(
                              disabled: !snapshot.data,
                              action: _checkPin,
                              text: loc.btnEnter,
                            ),
                            moreActionButton: null,
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Flexible(
            flex: 5,
            child: PinKeyboard(),
          )
        ],
      ),
    );
  }
}

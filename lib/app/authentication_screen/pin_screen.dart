import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:flutter/services.dart';
import 'package:my_pat/app/authentication_screen/pin_inputs.dart';
import 'package:my_pat/app/authentication_screen/pin_keyboard.dart';
import 'package:my_pat/app/screens.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/widgets/widgets.dart';

class PinScreen extends StatelessWidget {
  static const String TAG = 'PinScreen';
  static const String PATH = '/pin';
  final S loc = sl<S>();
  final AuthenticationManager pinManager = sl<AuthenticationManager>();
  final GlobalKey _ctxKey = GlobalKey(); // For navigator context

  PinScreen({Key key}) : super(key: key);

  final Map<String, String Function(BuildContext context)>
      _localizedPinDefinitions = {
    "PN": (BuildContext context) => S.of(context).pin_type_pn,
    "SS": (BuildContext context) => S.of(context).pin_type_ss,
    "CC": (BuildContext context) => S.of(context).pin_type_cc,
    "MN": (BuildContext context) => S.of(context).pin_type_mn,
    "HIC": (BuildContext context) => S.of(context).pin_type_hic,
    "PLAIN": (BuildContext context) => S.of(context).pin_type_plain,
  };

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

  _authStateErrorsBuilder(
    BuildContext context,
    AsyncSnapshot<PatientAuthState> snapshot,
  ) {
    if (snapshot.hasData) {
      switch (snapshot.data) {
        case PatientAuthState.FailedTryAgain:
          return Container(
            padding: EdgeInsets.all(10),
            child: Text(
              S.of(context).incorrect_pin,
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        case PatientAuthState.FailedClose:
          return Container(
            padding: EdgeInsets.all(10),
            child: Text(
              S.of(context).auth_fail,
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        case PatientAuthState.FailedNoInternet:
          return Container(
            padding: EdgeInsets.all(10),
            child: Text(
              S.of(context).inet_unavailable,
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        default:
          return Container();
      }
    }

    return Container();
  }

  _enterBtnBuilder(
      BuildContext context, AsyncSnapshot<PatientAuthState> snapshot) {
    if (snapshot.hasData && snapshot.data == PatientAuthState.InProgress) {
      final double size = prefix0.MediaQuery.of(context).size.width;
      return Container(
        padding: EdgeInsets.only(bottom: size / 15),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (snapshot.hasData && snapshot.data == PatientAuthState.FailedClose) {
      final double size = prefix0.MediaQuery.of(context).size.width;
      return Container(
        padding: EdgeInsets.only(bottom: size / 15),
        child: ButtonsBlock(
          nextActionButton: ButtonModel(
            action: () => exit(0),
            text: loc.close_app.toUpperCase(),
          ),
          moreActionButton: null,
        ),
      );
    }

    return StreamBuilder(
      stream: pinManager.pinIsValid,
      initialData: false,
      builder: (
        BuildContext context,
        AsyncSnapshot<bool> pinSnapshot,
      ) {
        final double size = prefix0.MediaQuery.of(context).size.width;
        return Container(
          padding: EdgeInsets.only(bottom: size / 15),
          child: ButtonsBlock(
            nextActionButton: ButtonModel(
              disabled: !pinSnapshot.data,
              action: _checkPin,
              text: loc.btnEnter,
            ),
            moreActionButton: null,
          ),
        );
      },
    );
  }

  _showPinHint(BuildContext context) {
    String pinType = sl<UserAuthenticationService>().pinType.toUpperCase();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text(S.of(context).pin_number_assigned_to_you(
                _localizedPinDefinitions[pinType](context))),
            actions: <Widget>[
              FlatButton(
                child: Text(S.of(context).ok.toUpperCase()),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    return MainTemplate(
      showBack: true,
      showMenu: false,
      body: Column(
        key: _ctxKey,
        children: <Widget>[
          Flexible(
            flex: 8,
            child: StreamBuilder(
              stream: pinManager.authStateStream,
              builder: (
                BuildContext context,
                AsyncSnapshot<PatientAuthState> snapshot,
              ) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: _authStateErrorsBuilder(context, snapshot),
                    ),
                    Expanded(
                      flex: 2,
                      child: PinInputs(),
                    ),
                    Expanded(
                      flex: 2,
                      child: Stack(
                        children: <Widget>[
                          TextBlock(
                            title: loc.pinTitle,
                            contentTextAlign: TextAlign.center,
                            content: [loc.pinContent],
                          ),
                          Positioned(
                            right: size / 3.7,
                            top: -size / 35,
                            child: IconButton(
                              icon: Icon(Icons.help_outline,
                                  color: Theme.of(context).accentColor),
                              onPressed: () => _showPinHint(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: _enterBtnBuilder(context, snapshot),
                    )
                  ],
                );
              },
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

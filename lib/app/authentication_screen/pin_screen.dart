import 'package:flutter/material.dart';
import 'package:my_pat/app/authentication_screen/pin_inputs.dart';
import 'package:my_pat/app/authentication_screen/pin_keyboard.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/widgets/widgets.dart';

class PinScreen extends StatelessWidget {
  static const String TAG = 'PinScreen';
  static const String PATH = '/pin';
  final S loc = sl<S>();
  final PinManager pinManager = sl<PinManager>();

  PinScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainTemplate(
      showBack: true,
      showMenu: false,
      body: Column(
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
                Container(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: StreamBuilder(
                    stream: pinManager.pinIsValid,
                    initialData: false,
                    builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                      return ButtonsBlock(
                        nextActionButton: ButtonModel(
                          disabled: !snapshot.data,
                          action: () {
                            Navigator.pushNamed(context, '/prepare1');
                          },
                          text: loc.btnEnter,
                        ),
                        moreActionButton: null,
                      );
                    },
                  ),
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

import '../helpers/localizations.dart';
import 'package:flutter/material.dart';
import '../blocs/pin_bloc_provider.dart';
import '../widgets/main_template/main_template.dart';
import '../widgets/text_block.dart';
import '../widgets/buttons_block.dart';
import '../widgets/pin_keyboard.dart';
import '../widgets/pin_inputs.dart';

class PinScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);
    final PinBloc pinBloc = PinBlocProvider.of(context);
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
                    stream: pinBloc.pin,
                    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                      return ButtonsBlock(
                        nextActionButton: ButtonModel(
                            disabled: !snapshot.hasData || snapshot.data.length < 4,
                            action: () {
                              Navigator.pushNamed(context, '/prepare1');
                            },
                            text: loc.btnEnter),
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

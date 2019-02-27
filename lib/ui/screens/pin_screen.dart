import 'package:my_pat/bloc/helpers/bloc_provider.dart';
import 'package:my_pat/generated/i18n.dart';
import 'package:flutter/material.dart';
import '../widgets/main_template/main_template.dart';
import '../widgets/text_block.dart';
import '../widgets/buttons_block.dart';
import 'package:my_pat/ui/widgets/pin_screen_components/pin_keyboard.dart';
import 'package:my_pat/ui/widgets/pin_screen_components/pin_inputs.dart';

class PinScreen extends StatelessWidget {
  static const String PATH = '/pin';

  PinScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final S loc = S.of(context);
    final PinBloc pinBloc = BlocProvider.of<PinBloc>(context);
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
                    stream: pinBloc.pinIsValid,
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

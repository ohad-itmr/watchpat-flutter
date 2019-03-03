import 'dart:async';

import 'package:flutter_blue/flutter_blue.dart';
import '../../generated/i18n.dart';
import 'package:flutter/material.dart';
import '../widgets/main_template/main_template.dart';
import '../widgets/main_template/body_template.dart';
import '../widgets/main_template/block_template.dart';
import '../widgets/buttons_block.dart';
import 'package:my_pat/bloc/bloc_provider.dart';

class WelcomeScreen extends StatelessWidget {
  static const String PATH = '/';

  WelcomeScreen({Key key}) : super(key: key);

  void _handleNext(bool checksComplete, List<String> errors) {
    print('checksComplete $checksComplete');

    print('Errors $errors');
  }

  @override
  Widget build(BuildContext context) {
    final WelcomeActivityBloc bloc = BlocProvider.of<WelcomeActivityBloc>(context);
//    print(appBloc.initialChecksComplete.listen((onData) => print('onData $onData')));
    final S loc = S.of(context);

    Future<void> _showBTWarning() async {
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
                    builder: (context, AsyncSnapshot<BluetoothState> snapshot) {
                      if (!snapshot.hasData || snapshot.data != BluetoothState.on){
                        return Container(
                          padding: EdgeInsets.all(10.0),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      Navigator.of(context).pop();
                      return Container();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return MainTemplate(
      showBack: false,
      showMenu: true,
      body: BodyTemplate(
        topBlock: BlockTemplate(
          type: BlockType.image,
          imageName: 'welcome.png',
        ),
        bottomBlock: BlockTemplate(
          type: BlockType.text,
          title: loc.welcomeTitle,
          content: [
            loc.welcomeContent,
          ],
        ),
        buttons: StreamBuilder(
          stream: bloc.bleState,
          builder: (context, AsyncSnapshot<BluetoothState> bleSnapshot) {
            if (bleSnapshot.hasData) {
              if (bleSnapshot.data != BluetoothState.on) {
                WidgetsBinding.instance.addPostFrameCallback((_) => _showBTWarning());
              }
            }
            return StreamBuilder(
              stream: bloc.initialChecksComplete,
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                if (snapshot.data == true) {
                  return StreamBuilder(
                    stream: bloc.initErrors,
                    builder: (context, AsyncSnapshot<dynamic> errorsSnapshot) {
                      return ButtonsBlock(
                        nextActionButton: ButtonModel(
                          action: () => _handleNext(snapshot.data, errorsSnapshot.data),
                        ),
                        moreActionButton: ButtonModel(
                          action: () {},
                        ),
                      );
                    },
                  );
                }
                return Container();
              },
            );
          },
        ),
        showSteps: false,
      ),
    );
  }
}

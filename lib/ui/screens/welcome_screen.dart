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
  static const String PATH = '/welcome';

  WelcomeScreen({Key key}) : super(key: key);

  void _handleNext(WelcomeActivityBloc bloc) {
    print('checksComplete ');
  }

  _showNoInternetWarning(
    BuildContext context,
    S loc,
    WelcomeActivityBloc bloc,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(loc.no_inet_connection),
                StreamBuilder(
                  stream: bloc.internetExists,
                  initialData: false,
                  builder: (context, AsyncSnapshot<bool> snapshot) {
                    print('snapshot.data ${snapshot.data}');
                    if (snapshot.hasData && snapshot.data) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.of(context).pop();
                      });
                      _handleNext(bloc);
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
    final WelcomeActivityBloc bloc = BlocProvider.of<WelcomeActivityBloc>(context);
//    print(appBloc.initialChecksComplete.listen((onData) => print('onData $onData')));
    final S loc = S.of(context);

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
          stream: bloc.initialChecksComplete,
          builder: (context, AsyncSnapshot<dynamic> snapshot) {
            return ButtonsBlock(
              nextActionButton: ButtonModel(
                action: () {
                  bool internetExists = bloc.getInternetConnectionState();
                  if (!internetExists) {
                    WidgetsBinding.instance.addPostFrameCallback(
                        (_) => _showNoInternetWarning(context, loc, bloc));
                  } else {
                    _handleNext(bloc);
                  }
                },
              ),
              moreActionButton: ButtonModel(
                action: () {},
              ),
            );
          },
        ),
        showSteps: false,
      ),
    );
  }
}

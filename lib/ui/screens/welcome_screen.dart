import '../../generated/i18n.dart';
import 'package:flutter/material.dart';
import '../widgets/main_template/main_template.dart';
import '../widgets/main_template/body_template.dart';
import '../widgets/main_template/block_template.dart';
import '../widgets/buttons_block.dart';
import 'package:my_pat/bloc/bloc_provider.dart';

class WelcomeScreen extends StatefulWidget {
  static const String PATH = '/welcome';

  WelcomeScreen({Key key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool nextIsPressed = false;

  void _handleNext(
      BuildContext context, WelcomeActivityBloc welcomeBloc, BleBloc bleBloc) {
    bleBloc.scanResultState.listen((ScanResultSate state) {
      if (state != ScanResultSate.FOUND_SINGLE) {
        Navigator.of(context).pushReplacementNamed('/battery');
      } else if(welcomeBloc.getInitialErrors().length>0){
        // TODO show errors list
        print('HAVE ERRORS');
      } else {
        Navigator.of(context).pushReplacementNamed('/prepare1');
      }
    });
    print('checksComplete ${welcomeBloc.initialChecksComplete}');
  }

  _showNoInternetWarning(BuildContext context, S loc, WelcomeActivityBloc welcomeBloc,
      BleBloc bleBloc) async {
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
                  stream: welcomeBloc.internetExists,
                  initialData: false,
                  builder: (context, AsyncSnapshot<bool> snapshot) {
                    if (snapshot.hasData && snapshot.data) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.of(context).pop();
                      });
                      _handleNext(context, welcomeBloc, bleBloc);
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
    final WelcomeActivityBloc welcomeBloc = BlocProvider.of<WelcomeActivityBloc>(context);
    final BleBloc bleBloc = BlocProvider.of<BleBloc>(context);
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
          stream: welcomeBloc.initialChecksComplete,
          builder: (context, AsyncSnapshot<bool> snapshot) {
            print('snapshot.data ${snapshot.data}');
            if (nextIsPressed) {
              if (snapshot.hasData && snapshot.data) {
                WidgetsBinding.instance.addPostFrameCallback(
                    (_) => _handleNext(context, welcomeBloc, bleBloc));
              }
              return CircularProgressIndicator();
            }
            return buildButtonsBloc(welcomeBloc, bleBloc, snapshot, loc);
          },
        ),
        showSteps: false,
      ),
    );
  }

  Widget buildButtonsBloc(
    WelcomeActivityBloc welcomeBloc,
    BleBloc bleBloc,
    AsyncSnapshot<bool> snapshot,
    S loc,
  ) {
    return ButtonsBlock(
      nextActionButton: ButtonModel(
        action: () {
          bool internetExists = welcomeBloc.getInternetConnectionState();
          if (!internetExists) {
            WidgetsBinding.instance.addPostFrameCallback(
                (_) => _showNoInternetWarning(context, loc, welcomeBloc, bleBloc));
          } else {
            if (snapshot.hasData && snapshot.data) {
              _handleNext(context, welcomeBloc, bleBloc);
            } else {
              setState(() {
                nextIsPressed = true;
              });
            }
          }
        },
      ),
      moreActionButton: ButtonModel(
        action: () {},
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:my_pat/app/screens.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/widgets/connection_indicators.dart';
import 'package:my_pat/widgets/widgets.dart';

class WelcomeScreen extends StatefulWidget {
  static const String TAG = 'WelcomeScreen';

  static const String PATH = '/welcome';

  WelcomeScreen({Key key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool nextIsPressed = false;
  final S loc = sl<S>();
  final WelcomeActivityManager welcomeManager = sl<WelcomeActivityManager>();
  final SystemStateManager systemStateManager = sl<SystemStateManager>();

  void _handleNext(BuildContext context) {
    systemStateManager.bleScanResultStream.listen((ScanResultStates state) {
      if (welcomeManager.getInitialErrors().length > 0) {
        // TODO show errors list
        print('HAVE ERRORS');
      } else if (state == ScanResultStates.NOT_LOCATED) {
        Navigator.of(context).pushNamed(BatteryScreen.PATH);
      } else {
        Navigator.of(context).pushNamed(RemoveJewelryScreen.PATH);
      }
    });
    print('checksComplete ${welcomeManager.initialChecksComplete}');
  }

  _showNoInternetWarning(BuildContext context) async {
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
                  stream: welcomeManager.internetExists,
                  initialData: false,
                  builder: (context, AsyncSnapshot<bool> snapshot) {
                    if (snapshot.hasData && snapshot.data) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.of(context).pop();
                      });
                      _handleNext(context);
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
          stream: welcomeManager.initialChecksComplete,
          builder: (context, AsyncSnapshot<bool> snapshot) {
            if (nextIsPressed) {
              print('snapshot ${snapshot.data}');
              if (snapshot.hasData && snapshot.data) {
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _handleNext(context));
              }
              return CircularProgressIndicator();
            }
            return buildButtonsBloc(snapshot);
          },
        ),
        showSteps: false,
      ),
    );
  }

  Widget buildButtonsBloc(AsyncSnapshot<bool> snapshot) {
    return ButtonsBlock(
      nextActionButton: ButtonModel(
        action: () {
          bool internetExists = welcomeManager.getInternetConnectionState();
          if (!internetExists) {
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _showNoInternetWarning(context));
          } else {
            if (snapshot.hasData && snapshot.data) {
              _handleNext(context);
            } else {
              setState(() {
                nextIsPressed = true;
              });
            }
          }
        },
      ),
      moreActionButton: ButtonModel(
          action: () => Navigator.of(context)
              .pushNamed("${CarouselScreen.PATH}/${WelcomeScreen.TAG}")),
    );
  }
}

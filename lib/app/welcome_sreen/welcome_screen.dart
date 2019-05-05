import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:my_pat/app/screens.dart';
import 'package:my_pat/app/service_screen/service_screen.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/widgets/widgets.dart';

class WelcomeScreen extends StatefulWidget {
  static const String TAG = 'WelcomeScreen';

  static const String PATH = '/welcome';

  WelcomeScreen({Key key}) : super(key: key);



  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _nextIsPressed = false;
  final S loc = sl<S>();
  final WelcomeActivityManager welcomeManager = sl<WelcomeActivityManager>();
  final SystemStateManager _systemStateManager = sl<SystemStateManager>();
  final ServiceScreenManager _serviceManager = sl<ServiceScreenManager>();

  // service mode password prompt
  final _formKey = GlobalKey<FormState>();
  bool _showPasswordSelected = false;

  @override
  void initState() {
    super.initState();

    _systemStateManager.inetConnectionStateStream
        .listen((ConnectivityResult state) {
      if (state == ConnectivityResult.none) {
        _showNoInternetWarning(context);
      }
    });

    _serviceManager.serviceModesStream.listen((mode) {
      if (mode == ServiceMode.customer) {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ServiceScreen(mode: mode)));
      } else if (mode == ServiceMode.technician) {
        _showServicePasswordPrompt();
      }
    });
  }

  void _handleNext() async {
    await welcomeManager.initialChecksComplete
        .firstWhere((bool isComplete) => isComplete);
    final ScanResultStates state =
        await _systemStateManager.bleScanResultStream.first;
    if (welcomeManager.getInitialErrors().length > 0) {
      // TODO show errors list
      print('HAVE ERRORS');
    } else if (state == ScanResultStates.NOT_LOCATED) {
      Navigator.of(context).pushNamed(BatteryScreen.PATH);
    } else {
      Navigator.of(context).pushNamed(RemoveJewelryScreen.PATH);
    }
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

  void _showServicePasswordPrompt() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text("Enter service password"),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        obscureText: !_showPasswordSelected,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != "12345678") {
                            _formKey.currentState.reset();
                            return 'Password invalid';
                          }
                        },
                      ),
                    ),
                    CheckboxListTile(
                      title: Text("Show password"),
                      controlAffinity: ListTileControlAffinity.leading,
                      value: _showPasswordSelected,
                      onChanged: (bool val) {
                        setState(() {
                          _showPasswordSelected = val;
                        });
                      },
                    )
                  ],
                ),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) =>
                                ServiceScreen(mode: ServiceMode.technician)));
                      }
                    },
                    child: Text("OK"),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("CANCEL"),
                  )
                ],
              );
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
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
        buttons: _buildButtonsBlock(),
        showSteps: false,
      ),
    );
  }

  Widget _buildButtonsBlock() {
    if (_nextIsPressed) {
      return CircularProgressIndicator();
    } else {
      return ButtonsBlock(
        nextActionButton: ButtonModel(
          action: () {
            setState(() => _nextIsPressed = true);
            _handleNext();
          },
        ),
        moreActionButton: ButtonModel(
            action: () => Navigator.of(context)
                .pushNamed("${CarouselScreen.PATH}/${WelcomeScreen.TAG}")),
      );
    }
  }
}

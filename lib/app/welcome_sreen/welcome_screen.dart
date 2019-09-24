import 'package:battery/battery.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:my_pat/app/screens.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/log/log.dart';
import 'package:my_pat/widgets/popup_menu_button.dart';
import 'package:my_pat/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

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

  @override
  void initState() {
    super.initState();
  }

  void _handleNext() async {
    await welcomeManager.initialChecksComplete.firstWhere((bool isComplete) => isComplete);
    final ScanResultStates state = await _systemStateManager.bleScanResultStream.first;
    final bool deviceHasErrors = await sl<SystemStateManager>().deviceHasErrors;
    final bool sessionHasErrors = await sl<SystemStateManager>().sessionHasErrors;

    setState(() => _nextIsPressed = false);

    if (welcomeManager.getInitialErrors().length > 0) {
      _showErrorDialog(welcomeManager.initialErrorsAsString);
    } else if (sessionHasErrors) {
      _showErrorDialog(sl<SystemStateManager>().sessionErrors);
    } else if (sl<SystemStateManager>().deviceErrorState == DeviceErrorStates.CHANGE_BATTERY) {
      Navigator.of(context).pushNamed(BatteryScreen.PATH);
    } else if (deviceHasErrors && !PrefsProvider.getIgnoreDeviceErrors()) {
      _showErrorDialog(sl<SystemStateManager>().deviceErrors);
    } else if (state == ScanResultStates.NOT_LOCATED ||
        state == ScanResultStates.LOCATED_MULTIPLE) {
      Navigator.of(context).pushNamed(BatteryScreen.PATH);
    } else {
      Navigator.of(context).pushNamed(PreparationScreen.PATH);
    }
  }

  _showErrorDialog(String msg) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(S.of(context).error.toUpperCase()),
            content: Text(msg),
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
          title: S.of(context).welcomeTitle,
          content: [loc.welcomeContent],
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
          text: S.of(context).ready.toUpperCase(),
          action: () {
            setState(() => _nextIsPressed = true);
            _handleNext();
          },
        ),
        moreActionButton: ButtonModel(
            text: S.of(context).btnPreview.toUpperCase(),
            action: () {
//              sl<EmailSenderService>().sendAllLogFiles();
              Navigator.of(context).pushNamed("${CarouselScreen.PATH}/${WelcomeScreen.TAG}");
            }),
      );
    }
  }
}

class TestMFException implements Exception {}

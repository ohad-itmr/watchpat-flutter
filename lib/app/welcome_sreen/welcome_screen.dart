import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_pat/app/screens.dart';
import 'package:my_pat/managers/managers.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/widgets/mypat_toast.dart';
import 'package:my_pat/widgets/widgets.dart';
import 'package:my_pat/generated/l10n.dart';

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
  StreamSubscription _toastSub;

  @override
  void initState() {
    welcomeManager.checkForOutdatedSession();
    _subscribeToToasts();
    super.initState();
  }

  @override
  void dispose() {
    _toastSub.cancel();
    super.dispose();
  }

  _subscribeToToasts() {
    _toastSub = _systemStateManager.toastMessagesStream.listen((msg) => MyPatToast.show(msg, context));
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
      _showErrorDialog(sl<SystemStateManager>().deviceErrors, callback: sl<BleManager>().restartSession);
    } else if (state == ScanResultStates.NOT_LOCATED || state == ScanResultStates.LOCATED_MULTIPLE) {
      Navigator.of(context).pushNamed(BatteryScreen.PATH);
    } else {
      Navigator.of(context).pushNamed(PreparationScreen.PATH);
    }
  }

  _showErrorDialog(String msg, {Function callback}) {
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
                onPressed: () {
                  if (callback != null) {
                    callback();
                  }
                  Navigator.pop(context);
                },
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
          content: [S.of(context).welcomeContent],
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
              Navigator.of(context).pushNamed("${CarouselScreen.PATH}/${WelcomeScreen.TAG}");
            }),
      );
    }
  }
}

class TestMFException implements Exception {}

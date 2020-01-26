import 'package:battery/battery.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:my_pat/app/screens.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/widgets/widgets.dart';

class StartRecordingScreen extends StatelessWidget {
  static const String PATH = '/start';
  static const String TAG = 'StartRecordingScreen';

  StartRecordingScreen({Key key}) : super(key: key);
  final S loc = sl<S>();
  final _testingManager = sl<TestingManager>();

  _showErrorDialog(String msg, BuildContext context) {
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
      showBack: true,
      showMenu: false,
      body: BodyTemplate(
        topBlock: BlockTemplate(
          type: BlockType.image,
          imageName: 'welcome.png',
        ),
        bottomBlock: BlockTemplate(
          type: BlockType.text,
          title: loc.startRecordingTitle,
          content: [
            loc.startRecordingContent,
          ],
        ),
        buttons: ButtonsBlock(
          nextActionButton: ButtonModel(
            action: () async {
              final BatteryState bState = await sl<BatteryManager>().getBatteryState();
              final iState = sl<SystemStateManager>().inetConnectionState;
              final dState = sl<SystemStateManager>().deviceCommState;
              if (dState != DeviceStates.CONNECTED) {
                _showErrorDialog(S.of(context).device_disconnected, context);
              } else if (bState == BatteryState.discharging) {
                _showErrorDialog(S.of(context).battery_level_error, context);
              } else if (iState == ConnectivityResult.none) {
                _showErrorDialog(S.of(context).no_inet_connection, context);
              } else {
                _testingManager.startTesting();
                Navigator.pushNamed(context, RecordingScreen.PATH);
              }
            },
            text: S.of(context).btnStartRecording,
          ),
          moreActionButton: ButtonModel(
              action: () => Navigator.of(context).pushNamed("${CarouselScreen.PATH}/${StartRecordingScreen.TAG}"),
              text: S.of(context).btnMore),
        ),
        showSteps: true,
        current: 6,
        total: 6,
      ),
    );
  }
}

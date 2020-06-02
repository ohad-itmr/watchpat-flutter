import 'package:battery/battery.dart';
import 'package:flutter/material.dart';
import 'package:my_pat/app/screens.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/widgets/widgets.dart';
import 'package:my_pat/generated/l10n.dart';

class FingerProbeScreen extends StatelessWidget {
  static const String PATH = '/device_set_up_3';
  final S loc = sl<S>();
  static const String TAG = 'FingerProbeScreen';

  FingerProbeScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainTemplate(
      showBack: true,
      showMenu: false,
      body: BodyTemplate(
        topBlock: BlockTemplate(
          type: BlockType.image,
          imageName: 'finger.png',
        ),
        bottomBlock: BlockTemplate(
          type: BlockType.text,
          title: loc.fingerProbeTitle,
          content: [
            loc.fingerProbeContent,
          ],
        ),
        buttons: ButtonsBlock(
          nextActionButton: ButtonModel(
            action: () {
              Navigator.pushNamed(context, StartRecordingScreen.PATH);
              _showDialogIfNotCharging(context);
            },
          ),
          moreActionButton: ButtonModel(
            action: () => Navigator.of(context)
                .pushNamed("${CarouselScreen.PATH}/${FingerProbeScreen.TAG}"),
          ),
        ),
        showSteps: true,
        current: 5,
        total: 6,
      ),
    );
  }

  void _showDialogIfNotCharging(BuildContext context) async {
    final BatteryState state = await sl<BatteryManager>().getBatteryState();
    if (state == BatteryState.charging) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(S.of(context).patient_msg1),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(S.of(context).ok.toUpperCase()),
            )
          ],
        );
      },
    );
  }
}

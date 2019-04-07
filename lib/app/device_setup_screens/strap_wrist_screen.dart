import 'package:battery/battery.dart';
import 'package:flutter/material.dart';
import 'package:my_pat/app/screens.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/widgets/widgets.dart';

class StrapWristScreen extends StatefulWidget {
  static const String PATH = '/device_set_up_1';
  final S loc = sl<S>();
  static const String TAG = 'StrapWristScreen';

  @override
  _StrapWristScreenState createState() => _StrapWristScreenState();
}

class _StrapWristScreenState extends State<StrapWristScreen> {
  void _showDialogIfNotCharging(BuildContext context) async {
    final BatteryState state = await sl<BatteryManager>().getBatteryState();
    if (state != BatteryState.charging) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(widget.loc.patient_msg1),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("OK"),
            )
          ],
        );
      },
    );
  }

  @override
  void initState() {
    _showDialogIfNotCharging(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MainTemplate(
      showBack: false,
      showMenu: false,
      body: BodyTemplate(
        topBlock: BlockTemplate(
          type: BlockType.image,
          imageName: 'strap_wrist.png',
        ),
        bottomBlock: BlockTemplate(
          type: BlockType.text,
          title: widget.loc.strapWristTitle,
          content: [
            widget.loc.strapWristContent,
          ],
        ),
        buttons: ButtonsBlock(
          nextActionButton: ButtonModel(
            action: () {
              Navigator.pushNamed(context, ChestSensorScreen.PATH);
            },
          ),
          moreActionButton: ButtonModel(
            action: () => Navigator.of(context)
                .pushNamed("${CarouselScreen.PATH}/${StrapWristScreen.TAG}"),
          ),
        ),
        showSteps: true,
        current: 3,
        total: 6,
      ),
    );
  }
}
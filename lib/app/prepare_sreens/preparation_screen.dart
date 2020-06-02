import 'package:battery/battery.dart';
import 'package:flutter/material.dart';
import 'package:my_pat/app/screens.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/widgets/widgets.dart';
import 'package:my_pat/generated/l10n.dart';

class PreparationScreen extends StatefulWidget {
  static const String PATH = '/prepare';
  static const String TAG = 'PreparationScreen';

  PreparationScreen({Key key}) : super(key: key);

  @override
  _PreparationScreenState createState() => _PreparationScreenState();
}

class _PreparationScreenState extends State<PreparationScreen> {
  final S loc = sl<S>();
  bool _nextIsPressed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!await _chargerConnected()) {
        _showDisconnectedWarning(context, null, S.of(context).patient_msg1);
      }
    });
  }

  Future<bool> _chargerConnected() async {
    final BatteryState state = await sl<BatteryManager>().getBatteryState();
    return state != BatteryState.discharging;
  }

  _handleNext() async {
    await sl<SystemStateManager>().bleScanStateStream.firstWhere((ScanStates state) => state == ScanStates.COMPLETE);

    final deviceConnected = sl<SystemStateManager>().deviceCommState == DeviceStates.CONNECTED;
    final chargerConnected = await _chargerConnected();

    if (!deviceConnected) {
      _showDisconnectedWarning(context, S.of(context).device_not_found, S.of(context).device_not_located);
      setState(() => _nextIsPressed = false);
    } else if (!chargerConnected) {
      _showDisconnectedWarning(context, null, S.of(context).patient_msg1);
      setState(() => _nextIsPressed = false);
    } else {
      await sl<SystemStateManager>().startSessionStateStream.firstWhere((StartSessionState st) => st == StartSessionState.CONFIRMED);
      _nextIsPressed = false;
      Navigator.pushNamed(context, PinScreen.PATH);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainTemplate(
      showBack: false,
      showMenu: false,
      body: BodyTemplate(
        topBlock: BlockTemplate(
          type: BlockType.image,
          imageName: 'prepare.png',
        ),
        bottomBlock: BlockTemplate(
          type: BlockType.text,
          title: loc.removeJewelryTitle,
          content: [
            loc.removeJewelryContent,
          ],
        ),
        buttons: _nextIsPressed
            ? CircularProgressIndicator()
            : ButtonsBlock(
                nextActionButton: ButtonModel(
                  action: () {
                    setState(() => _nextIsPressed = true);
                    _handleNext();
                  },
                ),
                moreActionButton: ButtonModel(
                  action: () => Navigator.of(context).pushNamed("${CarouselScreen.PATH}/${PreparationScreen.TAG}"),
                ),
              ),
        showSteps: true,
        current: 2,
        total: 6,
      ),
    );
  }

  _showDisconnectedWarning(BuildContext context, String title, String content) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: title != null ? Text(title) : null,
            content: Text(content),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text(S.of(context).ok),
              ),
            ],
          );
        });
  }
}

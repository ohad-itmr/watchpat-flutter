import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:my_pat/app/screens.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/widgets/widgets.dart';

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

  _handleNext() async {
    await sl<SystemStateManager>()
        .bleScanStateStream
        .firstWhere((ScanStates state) => state == ScanStates.COMPLETE);
    if (sl<SystemStateManager>().deviceCommState == DeviceStates.CONNECTED) {
      await sl<SystemStateManager>()
          .startSessionStateStream
          .firstWhere((StartSessionState st) => st == StartSessionState.CONFIRMED);
      _nextIsPressed = false;
      Navigator.pushNamed(context, PinScreen.PATH);
    } else {
      _showDisconnectedWarning(context);
      setState(() {
        _nextIsPressed = false;
      });
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
                  action: () => Navigator.of(context)
                      .pushNamed("${CarouselScreen.PATH}/${PreparationScreen.TAG}"),
                ),
              ),
        showSteps: true,
        current: 2,
        total: 6,
      ),
    );
  }

  _showDisconnectedWarning(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(S.of(context).device_not_found),
            content: Text(S.of(context).device_not_located),
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

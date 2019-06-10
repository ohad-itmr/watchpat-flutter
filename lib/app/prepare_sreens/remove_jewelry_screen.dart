import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:my_pat/app/screens.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/widgets/widgets.dart';

class RemoveJewelryScreen extends StatelessWidget {
  static const String PATH = '/prepare';
  final S loc = sl<S>();
  static const String TAG = 'RemoveJewelryScreen';

  RemoveJewelryScreen({Key key}) : super(key: key);

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
        buttons: ButtonsBlock(
          nextActionButton: ButtonModel(
            action: () {
              if (sl<SystemStateManager>().deviceCommState ==
                      DeviceStates.CONNECTED &&
                  sl<SystemStateManager>().startSessionState ==
                      StartSessionState.CONFIRMED) {
                Navigator.pushNamed(context, PinScreen.PATH);
              } else {
                _showDisconnectedWarning(context);
              }
            },
          ),
          moreActionButton: ButtonModel(
            action: () => Navigator.of(context)
                .pushNamed("${CarouselScreen.PATH}/${RemoveJewelryScreen.TAG}"),
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

import 'package:flutter/material.dart';
import 'package:my_pat/app/screens.dart';
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

  @override
  void initState() {
    super.initState();
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
      _nextIsPressed = false;
    } else {
      Navigator.of(context).pushNamed(RemoveJewelryScreen.PATH);
      _nextIsPressed = false;
    }
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


//            Navigator.of(context).pushNamed(PinScreen.PATH);
          },
        ),
        moreActionButton: ButtonModel(
            action: () => Navigator.of(context)
                .pushNamed("${CarouselScreen.PATH}/${WelcomeScreen.TAG}")),
      );
    }
  }
}

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
    final bool hasErrors = await sl<SystemStateManager>().deviceHasErrors;
    _nextIsPressed = false;
    if (welcomeManager.getInitialErrors().length > 0) {
      Navigator.of(context).pushNamed(
          "${ErrorScreen.PATH}/${welcomeManager.getInitialErrors()}");
    } else if (hasErrors) {
      Navigator.of(context).pushNamed(
          "${ErrorScreen.PATH}/${sl<SystemStateManager>().deviceErrors}");
    } else if (state == ScanResultStates.NOT_LOCATED) {
      Navigator.of(context).pushNamed(BatteryScreen.PATH);
    } else {
      Navigator.of(context).pushNamed(RemoveJewelryScreen.PATH);
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
          text: S.of(context).ready.toUpperCase(),
          action: () {
            setState(() => _nextIsPressed = true);
            _handleNext();

//            Navigator.of(context)
//                .pushNamed(UploadingScreen.PATH);

//            Navigator.of(context).push(MaterialPageRoute(
//                builder: (context) => EndScreen(
//                  title: S.of(context).thankYouTitle,
//                  content: S.of(context).test_is_complete,
//                )));
          },
        ),
        moreActionButton: ButtonModel(
          text: S.of(context).btnPreview.toUpperCase(),
            action: () => Navigator.of(context)
                .pushNamed("${CarouselScreen.PATH}/${WelcomeScreen.TAG}")),
      );
    }
  }
}

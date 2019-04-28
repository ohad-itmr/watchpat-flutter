import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:flutter/rendering.dart';
import 'package:my_pat/app/screens.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/widgets/widgets.dart';
import 'package:rxdart/rxdart.dart';

class UploadingScreen extends StatefulWidget {
  static const String PATH = '/uploading';
  static const String TAG = 'UploadingScreen';

  @override
  _UploadingScreenState createState() => _UploadingScreenState();
}

class _UploadingScreenState extends State<UploadingScreen> {
  final _systemState = sl<SystemStateManager>();

  final S loc = sl<S>();

  @override
  void initState() {
    super.initState();
    Observable.combineLatest2(
        _systemState.testStateStream, _systemState.dataTransferStateStream,
        (TestStates testState, DataTransferStates dataState) {
      if (testState == TestStates.ENDED &&
          dataState == DataTransferStates.ALL_TRANSFERRED) {
        Navigator.of(context).pushNamed(EndScreen.PATH);
      }
    }).listen(null);
  }

  @override
  Widget build(BuildContext context) {
    return MainTemplate(
      showBack: false,
      showMenu: false,
      body: BodyTemplate(
        topBlock: BlockTemplate(
          type: BlockType.image,
          imageName: 'uploading.png',
        ),
        bottomBlock: BlockTemplate(
          type: BlockType.text,
          title: loc.uploadingTitle,
          content: [loc.uploadingContent],
        ),
        buttons: ButtonsBlock(
          spinner: Center(child: CircularProgressIndicator()),
        ),
        showSteps: false,
      ),
    );
  }
}

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_pat/app/screens.dart';
import 'package:my_pat/managers/managers.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/widgets/mypat_toast.dart';
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
      _showErrorDialog(sl<SystemStateManager>().deviceErrors);
    } else if (state == ScanResultStates.NOT_LOCATED || state == ScanResultStates.LOCATED_MULTIPLE) {
      Navigator.of(context).pushNamed(BatteryScreen.PATH);
    } else {
      Navigator.of(context).pushNamed(PreparationScreen.PATH);
    }
  }

  _showErrorDialog(String msg) {
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
          content: [loc.welcomeContent],
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
//              Navigator.of(context).pushNamed(EndScreen.PATH);

//              _testSftpUploading();
            }),
      );
    }
  }

  _testSftpUploading() async {
    sl<SystemStateManager>().setDataTransferState(DataTransferState.ENDED);
    final File localFile = await sl<FileSystemService>().localDataFile;
    PrefsProvider.saveTestDataRecordingOffset(await localFile.length());

    PrefsProvider.saveSftpHost('test1.watchpat-one.com');
    PrefsProvider.saveSftpPort(22);
    PrefsProvider.saveSftpPassword('qNIw9VWh3APR');
    PrefsProvider.saveSftpUsername('sftp');
    PrefsProvider.saveSftpPath('sftp/123456782/20191002_0758');

    sl<SftpService>().initService();
  }
}

class TestMFException implements Exception {}

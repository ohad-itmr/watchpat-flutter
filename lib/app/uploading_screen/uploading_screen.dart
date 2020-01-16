import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:flutter/rendering.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/time_utils.dart';
import 'package:my_pat/widgets/mypat_progress_indicator.dart';
import 'package:my_pat/widgets/widgets.dart';

import '../screens.dart';

class UploadingScreen extends StatefulWidget with WidgetsBindingObserver {
  static const String PATH = '/uploading';
  static const String TAG = 'UploadingScreen';

  UploadingScreen() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused && sl<SystemStateManager>().inetConnectionState != ConnectivityResult.none) {
      TransactionManager.platformChannel.invokeMethod("startBackgroundSftpUploading");
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  _UploadingScreenState createState() => _UploadingScreenState();
}

class _UploadingScreenState extends State<UploadingScreen> {
  final _systemState = sl<SystemStateManager>();
  bool _deviceConnected = true;

  @override
  void initState() {
    _systemState.testStateStream.firstWhere((TestStates s) => s == TestStates.ENDED).then((_) async {
      await Future.delayed(Duration(seconds: 3));
      Navigator.of(context).pushNamed(EndScreen.PATH);
    });
    _subscribeToDeviceConnectionState();
    super.initState();
  }

  @override
  void deactivate() {
    WidgetsBinding.instance.removeObserver(widget);
    super.deactivate();
  }

  _subscribeToDeviceConnectionState() {
    _systemState.deviceCommStateStream.listen((state) => setState(() => _deviceConnected = state == DeviceStates.CONNECTED));
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return MainTemplate(
      showBack: false,
      showMenu: false,
      body: BodyTemplate(
        topBlock: BlockTemplate(
          type: BlockType.image,
          imageName: 'uploading.png',
        ),
        bottomBlock: Column(
          children: <Widget>[
            BlockTemplate(
              type: BlockType.text,
              title: _deviceConnected ? S.of(context).uploadingTitle : S.of(context).attention,
              content: _deviceConnected ? [S.of(context).uploadingContent] : [S.of(context).uploadingDeviceDisconnected],
            ),
            Padding(
              padding: EdgeInsets.only(left: width / 6, right: width / 6, top: width / 10),
              child: _deviceConnected ? MyPatProgressIndicator() : Container(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: _deviceConnected ? Text("Please wait") : Container(),
            ),
          ],
        ),
        buttons: Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: _deviceConnected
              ? StreamBuilder(
                  stream: sl<TestingManager>().remainingDataSecondsStream,
                  initialData: 0,
                  builder: (_, AsyncSnapshot<int> snapshot) {
                    return Text(
                      '${TimeUtils.convertSecondsToHMmSs(snapshot.data)}',
                      style: Theme.of(context).textTheme.title,
                    );
                  },
                )
              : Container(),
        ),
        showSteps: false,
      ),
    );
  }
}

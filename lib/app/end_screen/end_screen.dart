import 'dart:io';

import 'package:background_fetch/background_fetch.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/log/log.dart';
import 'package:my_pat/widgets/widgets.dart';
import 'package:rxdart/rxdart.dart';

class EndScreen extends StatelessWidget with WidgetsBindingObserver {
  static const String TAG = 'EndScreen';
  static const String PATH = '/end';

  EndScreen() {
    sl<SystemStateManager>().setScanCycleEnabled = false;
    sl<SystemStateManager>().setDeviceCommState(DeviceStates.DISCONNECTED);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      if (sl<SystemStateManager>().globalProcedureState != GlobalProcedureState.COMPLETE) {
        Log.info(TAG, "Data was not fully uploaded to sftp server, starting background uploading");
        TransactionManager.platformChannel.invokeMethod("startBackgroundSftpUploading");
      } else if (sl<SystemStateManager>().globalProcedureState == GlobalProcedureState.COMPLETE) {
        await BackgroundFetch.stop();
        await Future.delayed(Duration(seconds: 2));
        exit(0);
      }
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return MainTemplate(
      showBack: false,
      showMenu: false,
      body: BodyTemplate(
        topBlock: BlockTemplate(
            type: BlockType.text,
            title: S.of(context).thankYouTitle,
            content: [S.of(context).thankYouContent],
            textTopPadding: true),
        bottomBlock: Column(
          children: <Widget>[
            Container(
              width: width / 2,
              child: BlockTemplate(
                type: BlockType.image,
                imageName: 'itamar_full_logo.png',
              ),
            ),
          ],
        ),
        showSteps: false,
      ),
    );
  }
}

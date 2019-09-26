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
      if (sl<SystemStateManager>().globalProcedureState != GlobalProcedureState.COMPLETE &&
          sl<SystemStateManager>().inetConnectionState != ConnectivityResult.none) {
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

  Widget _buildTextBlock() {
    return StreamBuilder<GlobalProcedureState>(
      stream: sl<SystemStateManager>().globalProcedureStateStream,
      initialData: GlobalProcedureState.INCOMPLETE,
      builder: (BuildContext context, AsyncSnapshot<GlobalProcedureState> snapshot) {
        final String msg = snapshot.data == GlobalProcedureState.COMPLETE
            ? S.of(context).thankYouContent
            : S.of(context).thankYouStillUploading;
        return BlockTemplate(
            type: BlockType.text,
            title: S.of(context).thankYouTitle,
            content: [msg],
            textTopPadding: true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return MainTemplate(
      showBack: false,
      showMenu: false,
      body: BodyTemplate(
        topBlock: _buildTextBlock(),
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

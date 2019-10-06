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
    sl<SystemStateManager>().setSftpUploadingProgress(0);
    WidgetsBinding.instance.addObserver(this);
  }

  static bool _cycleAlreadyFired = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      if (sl<SystemStateManager>().globalProcedureState != GlobalProcedureState.COMPLETE &&
          sl<SystemStateManager>().inetConnectionState != ConnectivityResult.none &&
          !_cycleAlreadyFired) {
        _cycleAlreadyFired = true;
        Log.info(TAG, "Data was not fully uploaded to sftp server, starting background uploading");
        TransactionManager.platformChannel.invokeMethod("startBackgroundSftpUploading");
        await Future.delayed(Duration(milliseconds: 500));
        _cycleAlreadyFired = false;
      } else if (sl<SystemStateManager>().globalProcedureState == GlobalProcedureState.COMPLETE) {
        await BackgroundFetch.stop();
        await Future.delayed(Duration(seconds: 2));
        exit(0);
      }
    } else if (state == AppLifecycleState.resumed &&
        sl<SystemStateManager>().inetConnectionState != ConnectivityResult.none &&
        sl<SystemStateManager>().globalProcedureState != GlobalProcedureState.COMPLETE) {
      sl<SftpService>().initService();
    }
    super.didChangeAppLifecycleState(state);
  }

  Widget _buildTextBlock() {
    return StreamBuilder<List<dynamic>>(
      stream: Observable.combineLatest2(
          sl<SystemStateManager>().globalProcedureStateStream,
          sl<SystemStateManager>().sftpUploadingProgress,
          (GlobalProcedureState state, int progress) => [state, progress]),
      initialData: [GlobalProcedureState.INCOMPLETE, 0],
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        final String msg = snapshot.data[0] == GlobalProcedureState.COMPLETE
            ? S.of(context).thankYouContent
            : '${S.of(context).thankYouStillUploading} ${snapshot.data[1]}%';
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

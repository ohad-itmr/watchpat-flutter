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

  Widget _generateTextBlock(BuildContext context) {
    return StreamBuilder(
      stream: Observable.combineLatest3(
          sl<SystemStateManager>().globalProcedureStateStream,
          sl<SystemStateManager>().inetConnectionStateStream,
          sl<SftpService>().sftpConnectionStateStream,
          (GlobalProcedureState global, ConnectivityResult inet, SftpConnectionState sftp) =>
              [global, inet, sftp]),
      initialData: [],
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.data.length == 0) return Container();

        final GlobalProcedureState global = snapshot.data[0];
        final ConnectivityResult inet = snapshot.data[1];
        final SftpConnectionState sftp = snapshot.data[2];

        String bodyText;

        if (global == GlobalProcedureState.COMPLETE) {
          bodyText = S.of(context).thankYouContent;
        } else {
          if (inet != ConnectivityResult.none && sftp == SftpConnectionState.CONNECTED) {
            bodyText = S.of(context).thankYouStillUploading;
          } else {
            bodyText = S.of(context).thankYouNoInet;
          }
        }

        return BlockTemplate(
            type: BlockType.text,
            title: S.of(context).thankYouTitle,
            content: [bodyText],
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
        topBlock: _generateTextBlock(context),
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

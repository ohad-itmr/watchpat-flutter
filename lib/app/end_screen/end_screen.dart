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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (sl<SystemStateManager>().globalProcedureState != GlobalProcedureState.COMPLETE &&
          sl<SystemStateManager>().inetConnectionState == ConnectivityResult.none) {
        Log.info(TAG, "Data was not uploaded to sftp server. Registering background fetch task");
        PrefsProvider.setDataUploadingIncomplete();
        BackgroundFetch.registerHeadlessTask(_backgroundFetchTask);
        initPlatformState();
      }
    }
    super.didChangeAppLifecycleState(state);
  }

  Widget _generateTextBlock(BuildContext context) {
    return StreamBuilder(
      stream: Observable.combineLatest2(
          sl<SystemStateManager>().globalProcedureStateStream,
          sl<SystemStateManager>().inetConnectionStateStream,
          (GlobalProcedureState global, ConnectivityResult inet) => [global, inet]),
      initialData: [],
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.data.length == 0) return Container();

        final GlobalProcedureState global = snapshot.data[0];
        final ConnectivityResult inet = snapshot.data[1];

        String bodyText;

        if (global == GlobalProcedureState.COMPLETE) {
          bodyText = S.of(context).thankYouContent;
        } else {
          if (inet != ConnectivityResult.none) {
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

void initPlatformState() async {
  // Configure BackgroundFetch.
  BackgroundFetch.configure(
          BackgroundFetchConfig(
              minimumFetchInterval: 15, stopOnTerminate: false, enableHeadless: true),
          _backgroundFetchTask)
      .then((int status) {
    print('[BackgroundFetch] SUCCESS: $status');
  }).catchError((e) {
    print('[BackgroundFetch] ERROR: $e');
  });
}

// Fetch-event callback.
void _backgroundFetchTask() async {
  final Connectivity _connectivity = Connectivity();
  _connectivity.checkConnectivity().then((ConnectivityResult res) {
    sl<EmailSenderService>().sendTestMail();
    if (res != ConnectivityResult.none) {
      sl<SystemStateManager>().setDataTransferState(DataTransferState.ENDED);
    } else {
      BackgroundFetch.finish();
    }
  });
}

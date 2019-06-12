import 'dart:io';

import 'package:background_fetch/background_fetch.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/log/log.dart';
import 'package:my_pat/widgets/widgets.dart';

class EndScreen extends StatelessWidget {
  static const String TAG = 'EndScreen';
  static const String PATH = '/end';

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
          textTopPadding: true,
        ),
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
        buttons: ButtonsBlock(
          nextActionButton: ButtonModel(
            action: () async {
              if (sl<SystemStateManager>().sftpUploadingState !=
                  SftpUploadingState.ALL_UPLOADED) {
                Log.info(TAG,
                    "Data was not uploaded to sftp server. Registering background fetch task");
                PrefsProvider.setDataUploadingIncomplete();
                BackgroundFetch.registerHeadlessTask(_backgroundFetchTask);
                initPlatformState();
              } else {
                PrefsProvider.clearAll();
              }
              await Future.delayed(Duration(milliseconds: 300));
              exit(0);
            },
            text: S.of(context).btnCloseApp,
          ),
          moreActionButton: null,
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
              minimumFetchInterval: 15,
              stopOnTerminate: false,
              enableHeadless: true),
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
    print("SFTP FOLDER: ${PrefsProvider.loadSftpPath()}");
    if (res != ConnectivityResult.none) {
      sl<SystemStateManager>().setDataTransferState(DataTransferState.ENDED);
      //todo launch sftp uploading while test is already ended
    } else {
      BackgroundFetch.finish();
    }
  });
}

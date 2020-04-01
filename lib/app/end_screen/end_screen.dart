import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/widgets/widgets.dart';
import 'package:rxdart/rxdart.dart';

class EndScreen extends StatelessWidget with WidgetsBindingObserver {
  static const String TAG = 'EndScreen';
  static const String PATH = '/end';

  EndScreen() {
    sl<SystemStateManager>().setScanCycleEnabled = false;
    sl<SystemStateManager>().setTestState(TestStates.ENDED);
    sl<BleManager>().disconnectDevice();
    sl<SystemStateManager>().setSftpUploadingProgress(0);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (sl<SystemStateManager>().globalProcedureState != GlobalProcedureState.COMPLETE) {
      if (state == AppLifecycleState.paused) {
        sl<SftpService>().resetSFTPService();
        sl<NotificationsService>().showLocalNotification("Please open the WatchPAT application to finish uploading data to your doctor.");
      } else if (state == AppLifecycleState.resumed) {
        sl<SftpService>().initializeService();
      }
    }
    super.didChangeAppLifecycleState(state);
  }

  Widget _buildTextBlock() {
    return StreamBuilder<List<dynamic>>(
      stream: Observable.combineLatest3(
          sl<SystemStateManager>().globalProcedureStateStream,
          sl<SystemStateManager>().sftpUploadingProgress,
          sl<SystemStateManager>().inetConnectionStateStream,
          (GlobalProcedureState state, int progress, ConnectivityResult inet) => [state, progress, inet]),
      initialData: [GlobalProcedureState.INCOMPLETE, 0, ConnectivityResult.none],
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        String msg = "";
        if (snapshot.data[0] == GlobalProcedureState.COMPLETE) {
          msg = S.of(context).thankYouContent;
        } else if (snapshot.data[2] == ConnectivityResult.none) {
          msg = S.of(context).thankYouNoInet;
        } else {
          msg = '${S.of(context).thankYouStillUploading} ${snapshot.data[1]}%';
        }
        return BlockTemplate(type: BlockType.text, title: S.of(context).thankYouTitle, content: [msg], textTopPadding: true);
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

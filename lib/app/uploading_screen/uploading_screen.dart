import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/time_utils.dart';
import 'package:my_pat/widgets/mypat_progress_indicator.dart';
import 'package:my_pat/widgets/widgets.dart';

import '../screens.dart';

class UploadingScreen extends StatefulWidget {
  static const String PATH = '/uploading';
  static const String TAG = 'UploadingScreen';

  @override
  _UploadingScreenState createState() => _UploadingScreenState();
}

class _UploadingScreenState extends State<UploadingScreen> {
  final _systemState = sl<SystemStateManager>();

  @override
  void initState() {
    _systemState.testStateStream
        .firstWhere((TestStates s) => s == TestStates.ENDED)
        .then((_) async {
      await Future.delayed(Duration(seconds: 3));
      Navigator.of(context).pushNamed(EndScreen.PATH);
    });

    sl<SystemStateManager>().setScanCycleEnabled = true;
    sl<BleManager>().startScan(
        time: GlobalSettings.btScanTimeout, connectToFirstDevice: false);

    super.initState();
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
              title: S.of(context).uploadingTitle,
              content: [S.of(context).uploadingContent],
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: width / 6, right: width / 6, top: width / 10),
              child: MyPatProgressIndicator(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text("Please wait"),
            ),

          ],
        ),
        buttons:             Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: StreamBuilder(
            stream: sl<TestingManager>().remainingDataSecondsStream,
            initialData: 0,
            builder: (_, AsyncSnapshot<int> snapshot) {
              return Text(
                '${TimeUtils.convertSecondsToHMmSs(snapshot.data)}',
                style: Theme.of(context).textTheme.title,
              );
            },
          ),
        ),
        showSteps: false,
      ),
    );
  }
}

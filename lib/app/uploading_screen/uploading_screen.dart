import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/time_utils.dart';
import 'package:my_pat/widgets/connection_indicators_hor.dart';
import 'package:my_pat/widgets/mypat_progress_indicator.dart';
import 'package:my_pat/widgets/widgets.dart';
import 'package:rxdart/rxdart.dart';

class UploadingScreen extends StatefulWidget {
  static const String PATH = '/uploading';
  static const String TAG = 'UploadingScreen';

  @override
  _UploadingScreenState createState() => _UploadingScreenState();
}

class _UploadingScreenState extends State<UploadingScreen> {
  final _systemState = sl<SystemStateManager>();
  final _dataWritingService = sl<DataWritingService>();

  final S loc = sl<S>();

  @override
  void initState() {
    super.initState();
    Observable.combineLatest2(
        _systemState.testStateStream, _systemState.dataTransferStateStream,
        (TestStates testState, DataTransferStates dataState) {
      if (testState == TestStates.ENDED &&
          dataState == DataTransferStates.ALL_TRANSFERRED) {
//        Navigator.of(context).pushNamed(EndScreen.PATH);
      }
    }).listen(null);
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return MainTemplate(
        showBack: false,
        showMenu: false,
        body: Stack(
          children: <Widget>[
            BodyTemplate(
              topBlock: BlockTemplate(
                type: BlockType.image,
                imageName: 'uploading.png',
              ),
              bottomBlock: Column(
                children: <Widget>[
                  BlockTemplate(
                    type: BlockType.text,
                    title: loc.uploadingTitle,
                    content: [loc.uploadingContent],
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: width / 6, right:  width / 6, top: width / 10),
                    child: MyPatProgressIndicator(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text("Please wait"),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: StreamBuilder(
                      stream: _dataWritingService.remainingDataSecondsStream,
                      initialData: 0,
                      builder: (_, AsyncSnapshot<int> snapshot) {
                        return Text(
                          '${TimeUtils.convertSecondsToHMmSs(snapshot.data)}',
                          style: Theme.of(context).textTheme.title,
                        );
                      },
                    ),
                  )
                ],
              ),
              buttons: Container(),
              showSteps: false,
            ),
            Positioned(
              right: 10.0,
              top: 10.0,
              child: ConnectionIndicators(),
            ),
          ],
        ));
  }
}

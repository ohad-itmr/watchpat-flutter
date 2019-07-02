import 'dart:async';

import 'package:flutter/material.dart' as prefix0;
import 'package:my_pat/app/screens.dart';
import 'package:my_pat/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:my_pat/widgets/widgets.dart';

class BatteryScreen extends StatefulWidget {
  static const String TAG = 'BatteryScreen';
  static const String PATH = '/battery';

  @override
  _BatteryScreenState createState() => _BatteryScreenState();
}

class _BatteryScreenState extends State<BatteryScreen> {
  final BleManager bleManager = sl<BleManager>();
  final S loc = sl<S>();
  final SystemStateManager systemStateManager = sl<SystemStateManager>();

  bool _nextIsPressed = false;

  @override
  void initState() {
    systemStateManager.bleScanResultStream
        .firstWhere((ScanResultStates state) =>
            state == ScanResultStates.LOCATED_MULTIPLE)
        .then((_) => _showMultipleDeviceDialog());

    super.initState();
  }

  _handleNext() async {
    await sl<SystemStateManager>()
        .bleScanStateStream
        .firstWhere((ScanStates s) => s == ScanStates.COMPLETE);
    final bool deviceConnected = await sl<SystemStateManager>()
        .deviceCommStateStream
        .firstWhere((DeviceStates s) => s != DeviceStates.CONNECTING)
        .then((DeviceStates s) => s == DeviceStates.CONNECTED);

    if (deviceConnected) {
      final bool deviceHasErrors =
          await sl<SystemStateManager>().deviceHasErrors;
      final bool sessionHasErrors =
          await sl<SystemStateManager>().sessionHasErrors;
      if (deviceHasErrors) {
        Navigator.of(context).pushNamed(
            "${ErrorScreen.PATH}/${sl<SystemStateManager>().deviceErrors}");
      } else if (sessionHasErrors) {
        Navigator.of(context).pushNamed(
            "${ErrorScreen.PATH}/${sl<SystemStateManager>().sessionErrors}");
      } else {
        Navigator.pushNamed(context, PreparationScreen.PATH);
      }
    } else {
      _showNotFoundDialog();
    }
    setState(() => _nextIsPressed = false);
  }

  Widget _buildButtonsBlock() {
    if (_nextIsPressed) {
      return CircularProgressIndicator();
    } else {
      return ButtonsBlock(
        nextActionButton: ButtonModel(
          action: () async {
            setState(() => _nextIsPressed = true);
            _handleNext();
          },
        ),
        moreActionButton: ButtonModel(
          action: () => Navigator.of(context)
              .pushNamed("${CarouselScreen.PATH}/${BatteryScreen.TAG}"),
        ),
      );
    }
  }

  List<String> _buildText(ScanResultStates state) {
    switch (state) {
      case ScanResultStates.LOCATED_SINGLE:
        return [S.of(context).batteryContent_success];
      case ScanResultStates.LOCATED_MULTIPLE:
        return [S.of(context).batteryContent_many_2];
      default:
        return [
          S.of(context).batteryContent_1,
          S.of(context).batteryContent_2,
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainTemplate(
      showBack: false,
      showMenu: false,
      body: BodyTemplate(
        topBlock: BlockTemplate(
          type: BlockType.image,
          imageName: 'insert_battery.png',
        ),
        bottomBlock: StreamBuilder(
            stream: systemStateManager.bleScanResultStream,
            builder: (BuildContext context,
                AsyncSnapshot<ScanResultStates> snapshot) {
              return BlockTemplate(
                  type: BlockType.text,
                  title: loc.batteryTitle,
                  content: _buildText(snapshot.hasData
                      ? snapshot.data
                      : ScanResultStates.NOT_LOCATED));
            }),
        buttons: _buildButtonsBlock(),
        showSteps: false,
      ),
    );
  }

  _showNotFoundDialog() {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(S.of(context).device_not_found),
            content: Text(S.of(context).device_not_located),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text(S.of(context).ok),
              ),
            ],
          );
        });
  }

  _showMultipleDeviceDialog() {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            content: Text(S.of(context).batteryContent_many_1),
            actions: <Widget>[
              FlatButton(
                child: Text(S.of(context).ok.toUpperCase()),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }
}

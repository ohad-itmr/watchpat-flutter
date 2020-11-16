import 'package:flutter/material.dart' as prefix0;
import 'package:my_pat/app/screens.dart';
import 'package:my_pat/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:my_pat/widgets/widgets.dart';
import 'package:my_pat/generated/l10n.dart';

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
        .firstWhere((ScanResultStates state) => state == ScanResultStates.LOCATED_MULTIPLE)
        .then((_) => _showErrorDialog(S.of(context).batteryContent_many_1));

    systemStateManager.deviceErrorStateStream
        .firstWhere((DeviceErrorStates state) => state == DeviceErrorStates.CHANGE_BATTERY)
        .then((_) => _showErrorDialog(S.of(context).battery_depleted));

    super.initState();
  }

  _handleNext() async {
    sl<BleManager>().startScan(time: GlobalSettings.btScanTimeout, connectToFirstDevice: false);
    await sl<SystemStateManager>().bleScanStateStream.firstWhere((ScanStates s) => s == ScanStates.COMPLETE);
    final bool deviceConnected = await sl<SystemStateManager>()
        .deviceCommStateStream
        .firstWhere((DeviceStates s) => s != DeviceStates.CONNECTING)
        .then((DeviceStates s) => s == DeviceStates.CONNECTED);

    if (deviceConnected) {
      final bool deviceHasErrors = await sl<SystemStateManager>().deviceHasErrors;
      final bool sessionHasErrors = await sl<SystemStateManager>().sessionHasErrors;
      if (sessionHasErrors) {
        _showErrorDialog(sl<SystemStateManager>().sessionErrors);
      } else if (sl<SystemStateManager>().deviceErrorState == DeviceErrorStates.CHANGE_BATTERY) {
        _showErrorDialog(S.of(context).battery_depleted);
      } else if (deviceHasErrors && !PrefsProvider.getIgnoreDeviceErrors()) {
        _showErrorDialog(sl<SystemStateManager>().deviceErrors, callback: sl<BleManager>().restartSession);
      } else {
        Navigator.pushNamed(context, PreparationScreen.PATH);
      }
    } else if (sl<SystemStateManager>().bleScanResult == ScanResultStates.LOCATED_MULTIPLE) {
      _showErrorDialog(S.of(context).batteryContent_many_1);
    } else {
      _showErrorDialog(S.of(context).device_not_located);
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
          action: () => Navigator.of(context).pushNamed("${CarouselScreen.PATH}/${BatteryScreen.TAG}"),
        ),
      );
    }
  }

  List<String> _buildText(ScanResultStates state) {
    switch (state) {
      case ScanResultStates.LOCATED_MULTIPLE:
        return [S.of(context).batteryContent_many_2];
      default:
        return [S.of(context).batteryContent_1];
    }
  }

  String _buildHeaderText(ScanResultStates state) {
    if (state == ScanResultStates.LOCATED_MULTIPLE) {
      return S.of(context).disconnect_all_irr_devices;
    } else {
      return S.of(context).batteryTitle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainTemplate(
      showBack: false,
      showMenu: true,
      body: BodyTemplate(
        topBlock: BlockTemplate(
          type: BlockType.image,
          imageName: 'insert_battery.png',
        ),
        bottomBlock: SingleChildScrollView (
        child: StreamBuilder(
            stream: systemStateManager.bleScanResultStream,
            builder: (BuildContext context, AsyncSnapshot<ScanResultStates> snapshot) {
              return BlockTemplate(
                  type: BlockType.text,
                  title: _buildHeaderText(snapshot.hasData ? snapshot.data : ScanResultStates.NOT_LOCATED),
                  content: _buildText(snapshot.hasData ? snapshot.data : ScanResultStates.NOT_LOCATED));
            }),
        ),
        buttons: _buildButtonsBlock(),
        showSteps: false,
      ),
    );
  }

  _showErrorDialog(String msg, {Function callback}) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text(S.of(context).error.toUpperCase()),
              content: Text(msg),
              actions: <Widget>[
                FlatButton(
                  child: Text(S.of(context).ok.toUpperCase()),
                  onPressed: () {
                    if (callback != null) {
                      callback();
                    }
                    Navigator.pop(context);
                  },
                )
              ],
            ));
  }
}

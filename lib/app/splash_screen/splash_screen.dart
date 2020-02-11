import 'dart:async';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:date_format/date_format.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:my_pat/app/screens.dart';
import 'package:my_pat/app/service_screen/firmware_upgrade_dialog.dart';
import 'package:my_pat/app/service_screen/service_password_prompt.dart';
import 'package:my_pat/app/service_screen/service_screen.dart';
import 'package:my_pat/domain_model/device_commands.dart';
import 'package:my_pat/service_locator.dart';
import 'package:rxdart/rxdart.dart';

class SplashScreen extends StatefulWidget {
  static const String PATH = '/';
  static const String TAG = 'SplashScreen';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final S loc = sl<S>();

  static const _BT_MAP_KEY = "bt";
  static const _TEST_MAP_KEY = "test";
  static const _INET_MAP_KEY = "internet";

  // dialogs states
  bool _btWarningShow = false;
  bool _noInternetShow = false;
  bool _fwUpgradeShow = false;

  StreamSubscription _navigationSub;

  final BleManager bleManager = sl<BleManager>();
  final ServiceScreenManager _serviceManager = sl<ServiceScreenManager>();
  final SystemStateManager _systemStateManager = sl<SystemStateManager>();

  @override
  void initState() {
    sl<SystemStateManager>().updateInternetState();

    internetWarningSub = _systemStateManager.inetConnectionStateStream.where((_) => this.mounted).listen(_handleInternetState);

    _serviceManager.serviceModesStream.listen((mode) {
      if (mode == ServiceMode.customer) {
        sl<SystemStateManager>().setAppMode(AppModes.CS);
        sl<SystemStateManager>().changeState.add(StateChangeActions.APP_MODE_CHANGED);
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => ServiceScreen(mode: mode)));
      } else if (mode == ServiceMode.technician) {
        _showServicePasswordPrompt();
      }
    });

    if (!PrefsProvider.getDataUploadingIncomplete()) {}

    _navigationSub = Observable.combineLatest3(
        _systemStateManager.btStateStream,
        _systemStateManager.testStateStream,
        _systemStateManager.inetConnectionStateStream,
        (BtStates btState, TestStates testState, ConnectivityResult inetState) =>
            {_BT_MAP_KEY: btState, _TEST_MAP_KEY: testState, _INET_MAP_KEY: inetState}).listen((Map<String, dynamic> data) async {
      _handleBtState(data[_BT_MAP_KEY]);
      _handleInternetState(data[_INET_MAP_KEY]);

      if (data[_BT_MAP_KEY] == BtStates.ENABLED && data[_INET_MAP_KEY] != ConnectivityResult.none) {
        if (data[_TEST_MAP_KEY] == TestStates.INTERRUPTED) {
          GlobalSettings.replaceSettingsFromXML();
          Navigator.of(context).pushNamed(RecordingScreen.PATH);
        } else if (data[_TEST_MAP_KEY] == TestStates.STOPPED) {
          _stopAcquisitionOnDeviceConnect();
          Navigator.of(context).pushNamed(UploadingScreen.PATH);
        } else if (data[_TEST_MAP_KEY] == TestStates.SFTP_UPLOAD_INCOMPLETE) {
          _systemStateManager.setDataTransferState(DataTransferState.ENDED);
          Navigator.of(context).pushNamed(EndScreen.PATH);
        } else {
          Navigator.of(context).pushNamed(WelcomeScreen.PATH);
        }
        _navigationSub.cancel();
        return;
      } else if (data[_INET_MAP_KEY] == ConnectivityResult.none && data[_TEST_MAP_KEY] == TestStates.STOPPED) {
        _stopAcquisitionOnDeviceConnect();
        Navigator.of(context).pushNamed(UploadingScreen.PATH);
        return;
      } else if (data[_INET_MAP_KEY] == ConnectivityResult.none &&
          PrefsProvider.getDataUploadingIncomplete() &&
          data[_TEST_MAP_KEY] == TestStates.INTERRUPTED) {
        GlobalSettings.replaceSettingsFromXML();
        Navigator.of(context).pushNamed(RecordingScreen.PATH);
        _navigationSub.cancel();
        return;
      }

      if (PrefsProvider.getDataUploadingIncomplete()) {
        sl<SystemStateManager>().setScanCycleEnabled = false;
        _systemStateManager.setDataTransferState(DataTransferState.ENDED);
        Navigator.of(context).pushNamed(EndScreen.PATH);
        _navigationSub.cancel();
        return;
      }
    });

    if (!PrefsProvider.getDataUploadingIncomplete()) {
      _systemStateManager.btStateStream.where((BtStates state) => state != BtStates.NONE).listen(_handleBtState);
    }

    _systemStateManager.firmwareStateStream.listen(_handleUpgradeProgress);

    sl<IncomingPacketHandlerService>().isPairedResponseStream.listen(_handleIsPaired);

    _systemStateManager.inetConnectionStateStream.firstWhere((ConnectivityResult state) => state != ConnectivityResult.none).then((_) {
      sl<WelcomeActivityManager>().configureApplication();
      sl<WelcomeActivityManager>().allocateSpace();
    });

    super.initState();
  }

  void _stopAcquisitionOnDeviceConnect() {
    sl<SystemStateManager>().deviceCommStateStream.firstWhere((state) => state == DeviceStates.CONNECTED).then((_) async {
      await Future.delayed(Duration(seconds: 2));
      sl<CommandTaskerManager>().addCommandWithCb(DeviceCommands.getStopAcquisitionCmd(), listener: TestStopCallback());
    });
  }

  void _handleIsPaired(bool isPaired) {
    final bool isFirstConnection = PrefsProvider.loadDeviceName() == null;
    if (isFirstConnection && !isPaired || !isFirstConnection && !isPaired || sl<SystemStateManager>().isTestActive) return;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            title: Text(S.of(context).error),
            content: Text(isFirstConnection ? S.of(context).device_is_paired_error : S.of(context).device_is_not_paired_error),
            actions: <Widget>[
              FlatButton(
                child: Text(S.of(context).ok),
                onPressed: () {
//                  sl<ServiceScreenManager>().resetApplication(clearConfig: false);
//                  exit(0);
//                  PrefsProvider.clearDeviceName();
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  void _handleUpgradeProgress(FirmwareUpgradeState state) {
    if (state == FirmwareUpgradeState.UPGRADING && !_fwUpgradeShow) {
      showDialog(barrierDismissible: false, context: context, builder: (_) => FirmwareUpgradeDialog());
      _fwUpgradeShow = true;
    } else if (_fwUpgradeShow) {
      Navigator.of(context).pop();
      _fwUpgradeShow = false;

      if (state == FirmwareUpgradeState.UP_TO_DATE) {
        _showAlertDialog(S.of(context).firmware_upgrade_success);
      } else if (state == FirmwareUpgradeState.UPGRADE_FAILED) {
        _showAlertDialog(S.of(context).firmware_upgrade_failed);
      }
    }
  }

  void _showServicePasswordPrompt() {
    showDialog(context: context, barrierDismissible: false, builder: (_) => ServicePasswordPrompt());
  }

  void _showAlertDialog(String msg) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
              content: Text(msg),
              actions: <Widget>[
                FlatButton(
                  child: Text(S.of(context).ok.toUpperCase()),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ));
  }

  void _handleBtState(BtStates state) {
    if (state == BtStates.NOT_AVAILABLE && !_btWarningShow) {
      _showBTWarning();
      _btWarningShow = true;
    } else if (state == BtStates.ENABLED && _btWarningShow) {
      Navigator.of(context).pop();
      _btWarningShow = false;
    }
  }

  void _handleInternetState(ConnectivityResult state) {
    if (PrefsProvider.getDataUploadingIncomplete()) return;
    if (state == ConnectivityResult.none && !_noInternetShow) {
      _showNoInternetWarning();
      _noInternetShow = true;
    } else if (state != ConnectivityResult.none && _noInternetShow) {
      Navigator.of(context).pop();
      _noInternetShow = false;
    }
  }

  void _showBTWarning() {
    showDialog(
      context: context, barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S.of(context).bt_initiation_error),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(S.of(context).bt_must_be_enabled),
                Container(
                    padding: EdgeInsets.all(20.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNoInternetWarning() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S.of(context).inet_initiation_error),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(S.of(context).no_inet_connection),
                Container(
                    padding: EdgeInsets.all(20.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showUploadingInProgress() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(S.of(context).test_data_from_previous_session_still_uploading),
                Container(
                    padding: EdgeInsets.all(20.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            child: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/splash_final.png'),
          fit: BoxFit.cover,
        ),
      ),
    )));
  }
}

StreamSubscription internetWarningSub;

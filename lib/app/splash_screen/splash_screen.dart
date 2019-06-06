import 'dart:async';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:date_format/date_format.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:my_pat/app/screens.dart';
import 'package:my_pat/app/service_screen/firmware_upgrade_dialog.dart';
import 'package:my_pat/app/service_screen/service_password_prompt.dart';
import 'package:my_pat/app/service_screen/service_screen.dart';
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
    _systemStateManager.inetConnectionStateStream
        .where((_) => this.mounted)
        .listen(_handleInternetState);

    _serviceManager.serviceModesStream.listen((mode) {
      if (mode == ServiceMode.customer) {
        sl<SystemStateManager>().setAppMode(AppModes.CS);
        sl<SystemStateManager>()
            .changeState
            .add(StateChangeActions.APP_MODE_CHANGED);
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ServiceScreen(mode: mode)));
      } else if (mode == ServiceMode.technician) {
        _showServicePasswordPrompt();
      }
    });

    if (!PrefsProvider.getDataUploadingIncomplete()) {}

    _navigationSub = Observable.combineLatest3(
        _systemStateManager.btStateStream,
        _systemStateManager.testStateStream,
        _systemStateManager.inetConnectionStateStream,
        (BtStates btState, TestStates testState,
                ConnectivityResult inetState) =>
            {
              _BT_MAP_KEY: btState,
              _TEST_MAP_KEY: testState,
              _INET_MAP_KEY: inetState
            }).listen((Map<String, dynamic> data) async {
      if (PrefsProvider.getDataUploadingIncomplete()) {
        _showUploadingInProgress();
        Navigator.of(context).pushNamed(WelcomeScreen.PATH);
        return;
      }

      _handleBtState(data[_BT_MAP_KEY]);

      if (data[_BT_MAP_KEY] == BtStates.ENABLED) {
        if (data[_TEST_MAP_KEY] == TestStates.INTERRUPTED) {
          sl<WelcomeActivityManager>().initConnectivityListener();
          Navigator.of(context).pushNamed(RecordingScreen.PATH);
          _navigationSub.cancel();
        } else {
          await _handleInternetState(data[_INET_MAP_KEY]);
          Navigator.of(context).pushNamed(WelcomeScreen.PATH);
          _navigationSub.cancel();
        }
      }
    });

    if (!PrefsProvider.getDataUploadingIncomplete()) {
      _systemStateManager.btStateStream
          .where((BtStates state) => state != BtStates.NONE)
          .listen(_handleBtState);
    }

    _systemStateManager.firmwareStateStream.listen(_handleUpgradeProgress);

    sl<IncomingPacketHandlerService>()
        .isPairedResponseStream
        .listen(_handleIsPaired);

    sl<WelcomeActivityManager>().configureApplication();

    super.initState();
  }

  void _handleIsPaired(bool isPaired) {
    final bool isFirstConnection = PrefsProvider.loadDeviceName() == null;
    if (isFirstConnection && !isPaired || !isFirstConnection && isPaired)
      return;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            title: Text(S.of(context).error),
            content: Text(isFirstConnection
                ? S.of(context).device_is_paired_error
                : S.of(context).device_is_not_paired_error),
            actions: <Widget>[
              FlatButton(
                child: Text(S.of(context).ok),
                onPressed: () {
                  sl<ServiceScreenManager>().resetApplication();
                  exit(0);
                },
              )
            ],
          );
        });
  }

  void _handleUpgradeProgress(FirmwareUpgradeStates state) {
    if (state == FirmwareUpgradeStates.UPGRADING && !_fwUpgradeShow) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) => FirmwareUpgradeDialog());
      _fwUpgradeShow = true;
    } else if (_fwUpgradeShow) {
      Navigator.of(context).pop();
      _fwUpgradeShow = false;
    }
  }

  void _showServicePasswordPrompt() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => ServicePasswordPrompt());
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

  void _showBTWarning() {
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
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

  Future<void> _handleInternetState(ConnectivityResult state) async {
    if (state == ConnectivityResult.none && !_noInternetShow) {
      await _showNoInternetWarning();
      _noInternetShow = true;
    } else if (state != ConnectivityResult.none) {
      _noInternetShow = false;
    }
  }

  Future<void> _showNoInternetWarning() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(S.of(context).no_inet_connection),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
                return;
              },
              child: Text(S.of(context).ok.toUpperCase()),
            )
          ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            child: Padding(
      padding: EdgeInsets.all(55.0),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/splash.png'),
            fit: BoxFit.contain,
          ),
        ),
      ),
    )));
  }
}

import 'package:background_fetch/background_fetch.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/log/log.dart';

// Class responsible for performing various actions in response to system state changes
class TransactionManager extends ManagerBase {
  static const String TAG = "TransactionManager";
  static const platformChannel = const MethodChannel('watchpat');

  final SystemStateManager _sysState = sl<SystemStateManager>();

  TransactionManager() {
    _initTestStatesPersistence();
    _initStartingScanOnBTAvailable();
    _initStartingScanOnDeviceDisconnect();
    _initMethodChannel();
  }

  _initTestStatesPersistence() {
    _sysState.testStateStream.listen((TestStates state) {
      Log.info(TAG, "Test state changed to ${state.toString().toUpperCase()}, persisting");
      switch (state) {
        case TestStates.STARTED:
        case TestStates.RESUMED:
          {
            PrefsProvider.setTestStarted(true);
            break;
          }
        case TestStates.ENDED:
          {
            PrefsProvider.setTestStarted(false);
            PrefsProvider.setTestStoppedByUser(value: false);
            break;
          }
        case TestStates.STOPPED:
          {
            PrefsProvider.setTestStoppedByUser(value: true);
            break;
          }
        default:
      }
    });
  }

  _initStartingScanOnBTAvailable() {
    _sysState.btStateStream.where((BtStates st) => st == BtStates.ENABLED).listen((_) async {
      Log.info(TAG, "Bluetooth went enabled, starting scan");
      await Future.delayed(Duration(seconds: 2));
      sl<BleManager>().startScan(time: GlobalSettings.btScanTimeout, connectToFirstDevice: false);
    });
  }

  _initStartingScanOnDeviceDisconnect() {
    _sysState.deviceCommStateStream
        .where((DeviceStates deviceState) => deviceState == DeviceStates.DISCONNECTED)
        .listen((_) {
      if (sl<SystemStateManager>().isTestActive) {
        Log.info(TAG, "Connection to device was lost during test, reconnecting");
        sl<BleManager>().connect();
      } else if (!sl<SystemStateManager>().isTestActive &&
          sl<SystemStateManager>().isScanCycleEnabled) {
        Log.info(TAG, "Connection to device was lost before test, scanning");
        sl<BleManager>().startScan(time: GlobalSettings.btScanTimeout, connectToFirstDevice: false);
      }
    });
  }

  _initMethodChannel() {
    platformChannel.setMethodCallHandler((MethodCall call) {
      if (call.method == "crashHappened") {
        Log.shout(TAG, ">>>>>>>>>> APPLICATION CRASHED: ${call.arguments}");
      } else if (call.method == "applicationDidEnterBackground") {
        Log.shout(TAG, ">>>>>>>>>> APPLICATION ENTERED BACKGROUND");
      } else if (call.method == "applicationWillTerminate") {
        Log.shout(TAG, ">>>>>>>>>> APPLICATION WILL BE TERMINATED");
      }
      return;
    });
  }

  void initBackgroundTask() async {
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

  @override
  void dispose() {}
}

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
    _initSftpOnInternetAvailable();
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
      Log.info(TAG, "Bluetooth went enabled");
      if (sl<BleManager>().device == null) {
        Log.info(TAG, "Starting scan");
        await Future.delayed(Duration(seconds: 2));
        sl<BleManager>().startScan(time: GlobalSettings.btScanTimeout, connectToFirstDevice: false);
      } else {
        Log.info(TAG, "Reconnecting to previously connected device");
        sl<BleManager>().connect(reconnect: true);
      }
    });
  }

  _initStartingScanOnDeviceDisconnect() {
    _sysState.deviceCommStateStream
        .where((DeviceStates deviceState) => deviceState == DeviceStates.DISCONNECTED)
        .listen((_) {
      if (sl<SystemStateManager>().dataTransferState != DataTransferState.ENDED) {
        Log.info(TAG, "Connection to earlier connected device was lost, reconnecting");
        sl<BleManager>().connect(reconnect: true);
      }
    });
  }

  _initMethodChannel() {
    platformChannel.setMethodCallHandler((MethodCall call) async {
      if (call.method == "nativeLogEvent") {
        Log.info("[iOS]", call.arguments);
      } else if (call.method == "startSftpUploading") {
        sl<SftpService>().initService();
      } else if (call.method == "stopSftpUploading") {
        sl<SftpService>().resetSFTPService();
        await Future.delayed(Duration(seconds: 7));
        BackgroundFetch.finish();
      } else if (call.method == 'stopBackgroundFetch') {
        BackgroundFetch.finish();
      }
      return;
    });
  }

  _initSftpOnInternetAvailable() {
    sl<SystemStateManager>().inetConnectionStateStream.listen((ConnectivityResult state) {
      if (state != ConnectivityResult.none) {
        if (PrefsProvider.getTestStarted() || PrefsProvider.getTestStoppedByUser()) {
          Log.info(TAG, "Internet became available during test, initializing SFTP service");
          sl<SftpService>().initService();
        }
      } else {
        Log.shout(TAG, "Internet connection became unavailable");
      }
    });
  }

  @override
  void dispose() {}
}

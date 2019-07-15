import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/log/log.dart';

// Class responsible for performing various actions in response to system state changes
class TransactionManager extends ManagerBase {
  static const String TAG = "TransactionManager";
  final SystemStateManager _sysState = sl<SystemStateManager>();

  TransactionManager() {
    _initTestStatesPersistence();
    _initStartingScanOnBTAvailable();
    _initStartingScanOnDeviceDisconnect();
  }

  _initTestStatesPersistence() {
    _sysState.testStateStream.listen((TestStates state) {
      Log.info(TAG,
          "Test state changed to ${state.toString().toUpperCase()}, persisting");
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
    _sysState.btStateStream
        .where((BtStates st) => st == BtStates.ENABLED)
        .listen((_) async {
      Log.info(TAG, "Bluetooth went enabled, starting scan");
      await Future.delayed(Duration(seconds: 2));
      sl<BleManager>().startScan(
          time: GlobalSettings.btScanTimeout, connectToFirstDevice: false);
    });
  }

  _initStartingScanOnDeviceDisconnect() {
    _sysState.deviceCommStateStream
        .where((DeviceStates deviceState) =>
            deviceState == DeviceStates.DISCONNECTED &&
            _sysState.testState != TestStates.ENDED &&
            _sysState.isScanCycleEnabled)
        .listen((_) {
      Log.info(TAG, "Connection to device was lost during test, reconnecting");
      sl<BleManager>().startScan(
          time: GlobalSettings.btScanTimeout, connectToFirstDevice: false);
    });
  }

  @override
  void dispose() {}
}

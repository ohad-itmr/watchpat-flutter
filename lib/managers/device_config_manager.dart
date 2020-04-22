import 'package:my_pat/generated/i18n.dart';
import 'package:my_pat/managers/manager_base.dart';
import 'package:my_pat/domain_model/device_config_payload.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/log/log.dart';

class DeviceConfigManager extends ManagerBase {
  static const String TAG = 'DeviceConfigManager';

  S lang = sl<S>();

  DeviceConfigPayload _deviceConfig;

  DeviceConfigPayload get deviceConfig => _deviceConfig;

  void setDeviceConfiguration(DeviceConfigPayload config, {bool force = false}) {
    if (force) {
      Log.info(TAG, 'Setting config block');
      _deviceConfig = config;
    } else if (_deviceConfig == null) {
      Log.info(TAG, 'Setting config block');
      _deviceConfig = config;
    } else {
      Log.info(TAG, 'Config block already exist');
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }
}

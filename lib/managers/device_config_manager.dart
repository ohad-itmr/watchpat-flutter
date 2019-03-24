import 'package:my_pat/generated/i18n.dart';
import 'package:my_pat/managers/manager_base.dart';
import 'package:my_pat/models/device_config_payload.dart';
import 'package:my_pat/service_locator.dart';

class DeviceConfigManager extends ManagerBase {
  S lang = sl<S>();

  DeviceConfigPayload _deviceConfig;

  DeviceConfigPayload get deviceConfig => _deviceConfig;

  void setDeviceConfiguration(DeviceConfigPayload config) => _deviceConfig = config;

  @override
  void dispose() {
    // TODO: implement dispose
  }
}

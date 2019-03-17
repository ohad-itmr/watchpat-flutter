import 'package:my_pat/bloc/bloc_provider.dart';
import 'package:my_pat/bloc/helpers/bloc_base.dart';
import 'package:my_pat/generated/i18n.dart';
import 'package:my_pat/models/device_config_payload.dart';

class DeviceConfigBloc extends BlocBase {
  S lang = S();
  AppBloc _root;

  DeviceConfigPayload _deviceConfig;

  DeviceConfigPayload get deviceConfig => _deviceConfig;

  void setDeviceConfiguration(DeviceConfigPayload config) => _deviceConfig = config;

  DeviceConfigBloc(this._root);

  @override
  void dispose() {
    // TODO: implement dispose
  }
}



import 'package:my_pat/domain_model/global_settings_model.dart';
import 'package:my_pat/config/default_settings.dart';

class GlobalSettings {
  static const String TAG = 'GlobalSettings';

  static const int INVALID_STATE = 2147483647;
  static const int INVALID_L_STATE = 9223372036854775807;

  static GlobalSettingsModel _globalSettings =
      _globalSettings = GlobalSettingsModel.fromResource(DefaultSettings.settingsToMap());

  static int get uploadDataChunkMaxSize => _globalSettings.uploadDataChunkMaxSize;

  static int get uploadDataAccumulationSize => _globalSettings.uploadDataAccumulationSize;

  static int get minStorageSpaceMB => _globalSettings.minStorageSpace;

  static int get minTestLengthSeconds {
    if (isDebugMode) {
      return 15;
    } else {
      final int len = _getMinTestLengthHours;
      return len == INVALID_STATE ? INVALID_STATE : len * 60 * 60;
    }
  }

  static int get _getMinTestLengthHours => _globalSettings.minTestLength;

  static int get maxTestLengthSeconds {
    final int len = _getMaxTestLengthHours;
    return len == INVALID_STATE ? INVALID_STATE : len * 60 * 60;
  }

  static int get _getMaxTestLengthHours => _globalSettings.maxTestLength;

  static int get sessionTimeoutTimeMS {
    final int hours = _getSessionTimeoutTimeHours;
    return (hours == INVALID_STATE ? INVALID_STATE : hours * 60 * 60 * 1000);
  }

  static int get _getSessionTimeoutTimeHours => _globalSettings.sessionTimeoutTimeHours;

  static int get minBatteryLevel => _globalSettings.minBatteryLevel;

  static int get userPinCodeLength => _globalSettings.userPinCodeLength;

  static String get serviceEmailAddress => _globalSettings.serviceEmailAddress;

  static String get dispatcherLink => _globalSettings.dispatcherLink;

  static bool get isDebugMode => _globalSettings.debugMode;
}

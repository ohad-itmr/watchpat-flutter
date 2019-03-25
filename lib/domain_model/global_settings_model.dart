import 'package:my_pat/config/default_settings.dart';

class GlobalSettingsModel {
  static const String TAG = 'GlobalSettingsModel';

  static const int INVALID_STATE = 2147483647;
  static const int INVALID_L_STATE = 9223372036854775807;

  static const String TAG_ROOT = "watchpat";
  static const String TAG_SETTINGS = "settings";

  static const String TAG_UPLOAD_DATA_CHUNK_MAX_SIZE = "uploadDataChunkMaxSize";
  static const String TAG_UPLOAD_DATA_ACCUMULATION_SIZE = "uploadDataAccumulationSize";
  static const String TAG_MIN_STORAGE_SPACE_MB = "minStorageSpaceMb";
  static const String TAG_MIN_TEST_LENGTH_HOURS = "minTestLengthHours";
  static const String TAG_MAX_TEST_LENGTH_HOURS = "maxTestLengthHours";
  static const String TAG_SESSION_TIMEOUT_HOURS = "sessionTimeoutHours";
  static const String TAG_MIN_BATTERY_LEVEL = "minBatteryLevel";
  static const String TAG_PIN_CODE_LENGTH = "userPinCodeLength";
  static const String TAG_SERVICE_EMAIL_ADDRESS = "serviceEmailAddress";
  static const String TAG_DISPATCHER_LINK = "dispatcherLink";
  static const String TAG_DEBUG_MODE = "debugMode";

  int uploadDataChunkMaxSize = INVALID_STATE;
  int uploadDataAccumulationSize = INVALID_L_STATE;
  int minStorageSpace = INVALID_STATE;
  int minTestLength = INVALID_STATE;
  int maxTestLength = INVALID_STATE;
  int sessionTimeoutTimeHours = INVALID_STATE;
  int minBatteryLevel = INVALID_STATE;
  int userPinCodeLength = INVALID_STATE;
  String serviceEmailAddress = "";
  String dispatcherLink = "";
  bool debugMode = false;

  GlobalSettingsModel.fromResource(Map<String, dynamic> parsedJson)
      : uploadDataChunkMaxSize =
            parsedJson[TAG_UPLOAD_DATA_CHUNK_MAX_SIZE] ?? DefaultSettings.uploadDataChunkMaxSize,
        uploadDataAccumulationSize = parsedJson[TAG_UPLOAD_DATA_ACCUMULATION_SIZE] ??
            DefaultSettings.uploadDataAccumulationSize,
        minStorageSpace =
            parsedJson[TAG_MIN_STORAGE_SPACE_MB] ?? DefaultSettings.minStorageSpaceMb,
        minTestLength =
            parsedJson[TAG_MIN_TEST_LENGTH_HOURS] ?? DefaultSettings.minTestLengthHours,
        maxTestLength =
            parsedJson[TAG_MAX_TEST_LENGTH_HOURS] ?? DefaultSettings.maxTestLengthHours,
        sessionTimeoutTimeHours =
            parsedJson[TAG_SESSION_TIMEOUT_HOURS] ?? DefaultSettings.sessionTimeoutHours,
        minBatteryLevel = parsedJson[TAG_MIN_BATTERY_LEVEL] ?? DefaultSettings.minBatteryLevel,
        userPinCodeLength = parsedJson[TAG_PIN_CODE_LENGTH] ?? DefaultSettings.userPinCodeLength,
        serviceEmailAddress =
            parsedJson[TAG_SERVICE_EMAIL_ADDRESS] ?? DefaultSettings.emailService,
        dispatcherLink = parsedJson[TAG_DISPATCHER_LINK] ?? DefaultSettings.dispatcherLink,
        debugMode = parsedJson[TAG_DEBUG_MODE] ?? DefaultSettings.debugMode;
}

import 'package:my_pat/config/default_settings.dart';

class GlobalSettingsModel {
  static const String TAG = 'GlobalSettingsModel';

  static const int INVALID_STATE = 2147483647;
  static const int INVALID_L_STATE = 9223372036854775807;
  static const double INVALID_D_STATE = double.maxFinite;

  static const String TAG_ROOT = "watchpat";
  static const String TAG_SETTINGS = "settings";

  static const String TAG_UPLOAD_DATA_CHUNK_MAX_SIZE = "uploadDataChunkMaxSize";
  static const String TAG_UPLOAD_DATA_ACCUMULATION_SIZE = "uploadDataAccumulationSize";
  static const String TAG_MIN_STORAGE_SPACE_MB = "dataFileSize";

  static const String TAG_DEMO_URL = "demoUrl";
  static const String TAG_DATA_TRANSFER_RATE = "uploadRate";
  static const String TAG_MIN_BATTERY_ASKED_LEVEL = "minBatteryAsk";
  static const String TAG_MIN_DATA_FOR_UPLOAD = "minDataForUpload";
  static const String TAG_FW_VERSIONS_FOR_UPGRADE = "fwVersionsForUpgrade";
  static const String TAG_BT_SCAN_TIMEOUT = "btScanTimeout";
  static const String TAG_DISPATCHERS_URLS = "dispatchersUrls";


  static const String TAG_MIN_TEST_LENGTH_HOURS = "minTestLengthHours";
  static const String TAG_MAX_TEST_LENGTH_HOURS = "maxTestLengthHours";
  static const String TAG_SESSION_TIMEOUT_HOURS = "sessionTimeoutHours";
  static const String TAG_MIN_BATTERY_REQUIRED_LEVEL = "minBatteryRequire";

  static const String TAG_PIN_CODE_LENGTH = "userPinCodeLength";
  static const String TAG_SERVICE_EMAIL_ADDRESS = "supportEmail";
  static const String TAG_DISPATCHER_LINK = "dispatcherLink";
  static const String TAG_DISPATCHER_LINK_1 = "dispatcherLink1";
  static const String TAG_DISPATCHER_LINK_2 = "dispatcherLink2";
  static const String TAG_DEBUG_MODE = "debugMode";
  static const String TAG_IGNORE_DEVICE_ERRORS = "ignoreDeviceErrors";

  int uploadDataChunkMaxSize = INVALID_STATE;
  int uploadDataAccumulationSize = INVALID_L_STATE;
  int minStorageSpace = INVALID_STATE;

  String demoUrl = "";
  double dataTransferRate = INVALID_D_STATE;
  int minBatteryAskedLevel = INVALID_STATE;
  double minDataForUpload = INVALID_D_STATE;
  List<String> fwVersionsForUpgrade = [];
  int btScanTimeout = INVALID_STATE;
  List<String> dispatchersUrls = [];

  double minTestLengthHours = INVALID_D_STATE;
  double maxTestLengthHours = INVALID_D_STATE;
  double sessionTimeoutTimeHours = INVALID_D_STATE;
  int minBatteryRequiredLevel = INVALID_STATE;
  int userPinCodeLength = INVALID_STATE;
  String serviceEmailAddress = "";
  bool debugMode = false;

  GlobalSettingsModel.fromResource(Map<String, dynamic> parsedJson)
      : uploadDataChunkMaxSize = parsedJson[TAG_UPLOAD_DATA_CHUNK_MAX_SIZE] ?? DefaultSettings.uploadDataChunkMaxSize,
        uploadDataAccumulationSize = parsedJson[TAG_UPLOAD_DATA_ACCUMULATION_SIZE] ?? DefaultSettings.uploadDataAccumulationSize,
        minStorageSpace = parsedJson[TAG_MIN_STORAGE_SPACE_MB] ?? DefaultSettings.minStorageSpaceMb,
        demoUrl = parsedJson[TAG_DEMO_URL] ?? DefaultSettings.demoUrl,
        dataTransferRate = parsedJson[TAG_DATA_TRANSFER_RATE] != null ? parsedJson[TAG_DATA_TRANSFER_RATE].toDouble() : DefaultSettings.dataTransferRate,
        minBatteryAskedLevel = parsedJson[TAG_MIN_BATTERY_ASKED_LEVEL] ?? DefaultSettings.minBatteryAskedLevel,
        minDataForUpload = parsedJson[TAG_MIN_DATA_FOR_UPLOAD] ?? DefaultSettings.minDataForUpload,
        fwVersionsForUpgrade = (parsedJson[TAG_FW_VERSIONS_FOR_UPGRADE] as List<dynamic>).map((val) => "$val").toList() ??
            DefaultSettings.fwVersionsForUpgrade,
        btScanTimeout = parsedJson[TAG_BT_SCAN_TIMEOUT] ?? DefaultSettings.btScanTimeout,
        dispatchersUrls = (parsedJson[TAG_DISPATCHERS_URLS] as List<dynamic>).map((val) => "$val").toList() ??
            [DefaultSettings.dispatcherLink1,DefaultSettings.dispatcherLink2],
        minTestLengthHours = parsedJson[TAG_MIN_TEST_LENGTH_HOURS] ?? DefaultSettings.minTestLengthHours,
        maxTestLengthHours = parsedJson[TAG_MAX_TEST_LENGTH_HOURS] ?? DefaultSettings.maxTestLengthHours,
        sessionTimeoutTimeHours = parsedJson[TAG_SESSION_TIMEOUT_HOURS] ?? DefaultSettings.sessionTimeoutHours,
        minBatteryRequiredLevel = parsedJson[TAG_MIN_BATTERY_REQUIRED_LEVEL] ?? DefaultSettings.minBatteryRequiredLevel,
        userPinCodeLength = parsedJson[TAG_PIN_CODE_LENGTH] ?? DefaultSettings.userPinCodeLength,
        serviceEmailAddress = parsedJson[TAG_SERVICE_EMAIL_ADDRESS] ?? DefaultSettings.emailService,
        debugMode = parsedJson[TAG_DEBUG_MODE] ?? DefaultSettings.debugMode;
}

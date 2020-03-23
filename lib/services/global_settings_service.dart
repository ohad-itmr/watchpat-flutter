import 'dart:io';

import 'package:my_pat/domain_model/global_settings_model.dart';
import 'package:my_pat/config/default_settings.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/log/log.dart';
import 'package:xml/xml.dart' as xml;

class GlobalSettings {
  static const String TAG = 'GlobalSettings';

  static const int INVALID_STATE = 2147483647;
  static const int INVALID_L_STATE = 9223372036854775807;

  static bool _isWCPLessMode = false;

  static Map<String, dynamic> _configurationResource = DefaultSettings.settingsToMap();

  static setWCPLessMode(bool active) {
    _isWCPLessMode = active;
  }
  static setExternalConfiguration(Map<String, dynamic> resource) {
    _configurationResource = resource;
  }

  static persistConfiguration(Map<String, dynamic> resource) {
    final String email =
        resource[GlobalSettingsModel.TAG_SERVICE_EMAIL_ADDRESS] ?? DefaultSettings.emailService;
    PrefsProvider.saveServiceEmail(email);
  }

  static Future<void> replaceSettingsFromXML() async {
    try {
      final File xmlFile = await sl<FileSystemService>().configFile;
      final String source = await xmlFile.readAsString();
      final xml.XmlDocument document = xml.parse(source);
      document
          .findAllElements('settings')
          .toList()
          .first
          .attributes
          .forEach((xml.XmlAttribute node) async {
        if (node.name.toString() == GlobalSettingsModel.TAG_DEBUG_MODE) {
          _configurationResource[node.name.toString()] = node.value == 'true';
          printChangedSetting(
              GlobalSettingsModel.TAG_DEBUG_MODE, GlobalSettings.isDebugMode.toString());
        } else if (node.name.toString() == GlobalSettingsModel.TAG_IGNORE_DEVICE_ERRORS) {
          await PrefsProvider.setIgnoreDeviceErrors(node.value == 'true');
          printChangedSetting(GlobalSettingsModel.TAG_IGNORE_DEVICE_ERRORS,
              PrefsProvider.getIgnoreDeviceErrors().toString());
        } else if (node.name.toString() == GlobalSettingsModel.TAG_MIN_STORAGE_SPACE_MB) {
          _configurationResource[node.name.toString()] = int.parse(node.value);
          printChangedSetting(GlobalSettingsModel.TAG_MIN_STORAGE_SPACE_MB,
              '${GlobalSettings.minStorageSpaceMB} MB');
        } else if (node.name.toString() == GlobalSettingsModel.TAG_DISPATCHER_LINK_1) {
          _configurationResource[GlobalSettingsModel.TAG_DISPATCHERS_URLS].clear();
          _configurationResource[GlobalSettingsModel.TAG_DISPATCHERS_URLS].add(node.value);
        } else if (node.name.toString() == GlobalSettingsModel.TAG_DISPATCHER_LINK_2) {
          _configurationResource[GlobalSettingsModel.TAG_DISPATCHERS_URLS].add(node.value);
          printChangedSetting(
              GlobalSettingsModel.TAG_DISPATCHERS_URLS, GlobalSettings.dispatchersUrls.toString());
        } else {
          _configurationResource[node.name.toString()] = double.parse(node.value);
          printChangedSetting(node.name.toString(), double.parse(node.value).toString());
        }
      });
    } catch (e) {
      print("XML configuring error: ${e.toString()}");
    }
    return;
  }

  static void printChangedSetting(String name, String value) {
    Log.info(TAG, '$name was changed from XML, new value is: $value');
  }

  static GlobalSettingsModel get _globalSettings =>
      GlobalSettingsModel.fromResource(_configurationResource);

  static int get uploadDataChunkMaxSize => _globalSettings.uploadDataChunkMaxSize;

  static int get uploadDataAccumulationSize => _globalSettings.uploadDataAccumulationSize;

  static int get minStorageSpaceMB => _globalSettings.minStorageSpace;

  static int get minTestLengthSeconds {
    final double len = _getMinTestLengthHours;
    return len == INVALID_STATE ? INVALID_STATE : (len * 60 * 60).round();
  }

  static double get _getMinTestLengthHours => _globalSettings.minTestLengthHours;

  static int get maxTestLengthSeconds {
    final double len = _getMaxTestLengthHours;
    return len == INVALID_STATE ? INVALID_STATE : (len * 60 * 60).round();
  }

  static double get _getMaxTestLengthHours => _globalSettings.maxTestLengthHours;

  static int get sessionTimeoutTimeSec {
    final double hours = _getSessionTimeoutTimeHours;
    return hours == INVALID_STATE ? INVALID_STATE : (hours * 60 * 60).round();
  }

  static double get _getSessionTimeoutTimeHours => _globalSettings.sessionTimeoutTimeHours;

  static int get minBatteryRequiredLevel => _globalSettings.minBatteryRequiredLevel;

  static int get userPinCodeLength => _globalSettings.userPinCodeLength;

  static String get serviceEmailAddress => PrefsProvider.loadServiceEmail();

  static String getDispatcherLink(int index) =>
      index < dispatchersUrls.length ? dispatchersUrls[index] : dispatchersUrls[0];

  static int get dispatcherUrlsAmount => dispatchersUrls.length;

  static bool get isDebugMode => _globalSettings.debugMode;

  static String get demoUrl => _globalSettings.demoUrl;

  static double get dataTransferRate => _globalSettings.dataTransferRate;

  static int get minBatteryAskedLevel => _globalSettings.minBatteryAskedLevel;

  static double get minDataForUpload => _globalSettings.minDataForUpload;

  static List<String> get fwVersionsForUpgrade => _globalSettings.fwVersionsForUpgrade;

  static int get btScanTimeout => _globalSettings.btScanTimeout;

  static List<String> get dispatchersUrls => _globalSettings.dispatchersUrls;

  static bool get wcpLessMode => _isWCPLessMode;
}

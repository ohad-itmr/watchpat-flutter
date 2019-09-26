import 'dart:async';
import 'dart:ui';

import 'package:my_pat/utils/log/log.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_pat/config/default_settings.dart';

class PrefsNames {
  static const String READING_KEY = DefaultSettings.appName + ".reading";
  static const String FIRST_TIME_RUN_KEY = DefaultSettings.appName + ".firsttimerun";
  static const String IS_TEST_STARTED = ".isteststarted";
  static const String IS_TEST_COMPLETE = ".is.test.complete";
  static const String WRITING_KEY = DefaultSettings.appName + ".writing";
  static const String USER_PIN_CODE = DefaultSettings.appName + ".user.pin.code";
  static const String DEVICE_SERIAL_KEY = DefaultSettings.appName + ".deviceserial";
  static const String DEVICE_NAME_KEY = DefaultSettings.appName + ".devicename";
  static const String DEVICE_ADDRESS_KEY = DefaultSettings.appName + ".deviceaddress";
  static const String TEST_STATE_KEY = DefaultSettings.appName + ".teststate";
  static const String DATA_STATE_KEY = DefaultSettings.appName + ".datastate";
  static const String TEST_DATA_UPLOADING_OFFSET = "testdatauploadingoffset";
  static const String TEST_DATA_RECORDING_OFFSET = "testdatarecordingoffset";
  static const String TEST_DATA_FILENAME = ".testdatafilename";
  static const String TEST_REAL_START_TIME_KEY = DefaultSettings.appName + ".testrealtime";
  static const String TEST_PACKET_TIME_KEY = DefaultSettings.appName + ".testpackettime";
  static const String PACKET_IDENTIFIER_KEY = DefaultSettings.appName + ".packetidentifier";
  static const String PACKET_REMOTE_IDENTIFIER_KEY =
      DefaultSettings.appName + ".packetremoteidentifier";
  static const String IS_FIRST_SFTP_CONNECTION_KEY =
      DefaultSettings.appName + ".isfirstsftpconnection";
  static const String IS_IGNORE_DEVICE_ERRORS_KEY =
      DefaultSettings.appName + ".isignoredeviceerrors";
  static const String SFTP_HOST_KEY = DefaultSettings.appName + ".sftphost";
  static const String SFTP_PORT_KEY = DefaultSettings.appName + ".sftpport";
  static const String SFTP_USERNAME_KEY = DefaultSettings.appName + ".sftpusername";
  static const String SFTP_PASSWORD_KEY = DefaultSettings.appName + ".sftppassword";
  static const String SFTP_PATH_KEY = DefaultSettings.appName + ".sftppath";
  static const String LOCALE_CODE = "locale.code";
  static const String SERVICE_EMAIL_CODE = "service.email";
  static const String DISPATCHER_URL_INDEX = "dispatcher.url.index";
  static const String DATA_UPLOADING_NOT_FINISHED = "test.data.uploaded";
  static const String IS_TEST_STOPPED_BY_USER = "is.test.stopped";
  static const String PACKET_ID_COUNTER_KEY = "packet.counter.key";
  static const String TEST_START_TIME_KEY = "test.start.time.key";
  static const String BLUETOOTH_DEVICE_ID_KEY = "bluetooth.device.id.key";
}

class PrefsService {
  static const String TAG = 'PrefsService';

  static PrefsService _provider = PrefsService._internal();

  static SharedPreferences prefs;

  factory PrefsService() {
    return _provider;
  }

  PrefsService._internal();
}

class PrefsProvider {
  //
  // Reset all the application persistent properties in case the app started normally, not restored after started test
  //
  static void resetPersistentState() {
    saveRemotePacketIdentifier(0);
    saveTestPacketCount(0);
    saveTestDataRecordingOffset(0);
    savePacketId(0);
  }

  //
  // Packet counter
  //
  static Future<void> saveTestPacketCount(int time) async {
    await PrefsService.prefs.setInt(PrefsNames.TEST_PACKET_TIME_KEY, time);
  }

  static int loadTestPacketCount() {
    return PrefsService.prefs.getInt(PrefsNames.TEST_PACKET_TIME_KEY) ?? 0;
  }

  static void incTestPacketCount() async {
    final int currentCount = PrefsProvider.loadTestPacketCount();
    await PrefsProvider.saveTestPacketCount(currentCount + 1);
  }

  //
  // packet identifier
  //
  static Future<int> getPacketIdentifier() async {
    int currIdentifier = PrefsService.prefs.getInt(PrefsNames.PACKET_IDENTIFIER_KEY) ?? 0;
    await PrefsService.prefs.setInt(PrefsNames.PACKET_IDENTIFIER_KEY, currIdentifier + 1);
    return currIdentifier;
  }

  //
  // remote packet identifier
  //
  static void saveRemotePacketIdentifier(int id) async {
    await PrefsService.prefs.setInt(PrefsNames.PACKET_REMOTE_IDENTIFIER_KEY, id);
  }

  static int loadRemotePacketIdentifier() {
    return PrefsService.prefs.getInt(PrefsNames.PACKET_REMOTE_IDENTIFIER_KEY) ?? 0;
  }

  //
  // Device serial
  //
  static void saveDeviceSerial(String serial) async {
    await PrefsService.prefs.setString(PrefsNames.DEVICE_SERIAL_KEY, serial);
  }

  static String loadDeviceSerial() {
    return PrefsService.prefs.getString(PrefsNames.DEVICE_SERIAL_KEY);
  }

  //
  // User OUB
  //
  static void saveUserPin(String serial) async {
    await PrefsService.prefs.setString(PrefsNames.USER_PIN_CODE, serial);
  }

  static String loadUserPin() {
    return PrefsService.prefs.getString(PrefsNames.USER_PIN_CODE);
  }

  //
  // is first time run
  //
  static void setFirstTimeRun({bool state = false}) async {
    await PrefsService.prefs.setBool(PrefsNames.FIRST_TIME_RUN_KEY, state);
  }

  static bool getIsFirstTimeRun() {
    return PrefsService.prefs.getBool(PrefsNames.FIRST_TIME_RUN_KEY) ?? true;
  }

  //
  // persist if test started, to restore testing in case of interruption
  //
  static Future<void> setTestStarted(bool value) async {
    await PrefsService.prefs.setBool(PrefsNames.IS_TEST_STARTED, value);
  }

  static bool getTestStarted() {
    return PrefsService.prefs.get(PrefsNames.IS_TEST_STARTED) ?? false;
  }

  //
  // persist if test was stopped by user
  //
  static Future<void> setTestStoppedByUser({bool value = true}) async {
    await PrefsService.prefs.setBool(PrefsNames.IS_TEST_STOPPED_BY_USER, value);
  }

  static bool getTestStoppedByUser() {
    return PrefsService.prefs.getBool(PrefsNames.IS_TEST_STOPPED_BY_USER) ?? false;
  }

  static void saveDeviceName(String name) async {
    await PrefsService.prefs.setString(PrefsNames.DEVICE_NAME_KEY, name);
  }

  static String loadDeviceName() {
    return PrefsService.prefs.getString(PrefsNames.DEVICE_NAME_KEY);
  }

  static void clearDeviceName() {
    PrefsService.prefs.remove(PrefsNames.DEVICE_NAME_KEY);
    PrefsService.prefs.remove(PrefsNames.BLUETOOTH_DEVICE_ID_KEY);
    Log.info("PrefsProvider", "CONNECTED DEVICE FORGOTTEN");
  }

  //
  // is ignore device error
  //
  static Future<void> setIgnoreDeviceErrors(bool value) async {
    await PrefsService.prefs.setBool(PrefsNames.IS_IGNORE_DEVICE_ERRORS_KEY, value);
  }

  static bool getIgnoreDeviceErrors() {
    return PrefsService.prefs.getBool(PrefsNames.IS_IGNORE_DEVICE_ERRORS_KEY) ?? false;
  }

  //
  // sftp host
  //
  static void saveSftpHost(String host) async {
    await PrefsService.prefs.setString(PrefsNames.SFTP_HOST_KEY, host);
  }

  static String loadSftpHost() {
    return PrefsService.prefs.getString(PrefsNames.SFTP_HOST_KEY) ?? "";
  }

  //
  // sftp port
  //
  static void saveSftpPort(int port) async {
    await PrefsService.prefs.setInt(PrefsNames.SFTP_PORT_KEY, port);
  }

  static int loadSftpPort() {
    return PrefsService.prefs.getInt(PrefsNames.SFTP_PORT_KEY) ?? 0;
  }

  //
  // sftp username
  //
  static void saveSftpUsername(String username) async {
    await PrefsService.prefs.setString(PrefsNames.SFTP_USERNAME_KEY, username);
  }

  static String loadSftpUsername() {
    return PrefsService.prefs.getString(PrefsNames.SFTP_USERNAME_KEY) ?? "";
  }

  //
  // sftp password
  //
  static void saveSftpPassword(String password) async {
    await PrefsService.prefs.setString(PrefsNames.SFTP_PASSWORD_KEY, password);
  }

  static String loadSftpPassword() {
    return PrefsService.prefs.getString(PrefsNames.SFTP_PASSWORD_KEY) ?? "";
  }

  //
  // sftp path
  //
  static void saveSftpPath(String path) async {
    await PrefsService.prefs.setString(PrefsNames.SFTP_PATH_KEY, path);
  }

  static String loadSftpPath() {
    return PrefsService.prefs.getString(PrefsNames.SFTP_PATH_KEY) ?? "";
  }

  //
  // recording test data
  //
  static int loadTestDataRecordingOffset() {
    return PrefsService.prefs.getInt(PrefsNames.TEST_DATA_RECORDING_OFFSET) ?? 0;
  }

  static Future<void> saveTestDataRecordingOffset(int offset) async {
    await PrefsService.prefs.setInt(PrefsNames.TEST_DATA_RECORDING_OFFSET, offset);
  }

  //
  // uploading test data
  //
  static int loadTestDataUploadingOffset() {
    return PrefsService.prefs.getInt(PrefsNames.TEST_DATA_UPLOADING_OFFSET) ?? 0;
  }

  static Future<void> saveTestDataUploadingOffset(int offset) async {
    await PrefsService.prefs.setInt(PrefsNames.TEST_DATA_UPLOADING_OFFSET, offset);
  }

  //
  // Locale
  //
  static Future<void> saveLocale(Locale newLocale) async {
    final String localeCode = newLocale.toString().replaceAll("_", "");
    await PrefsService.prefs.setString(PrefsNames.LOCALE_CODE, localeCode);
  }

  static Locale loadLocale() {
    final String code = PrefsService.prefs.getString(PrefsNames.LOCALE_CODE) ?? 'en';
    return Locale(code, "");
  }

  //
  // Packet id counter
  //
  static Future<void> savePacketId(int packetID) async {
    await PrefsService.prefs.setInt(PrefsNames.PACKET_ID_COUNTER_KEY, packetID);
  }

  static int loadPacketId() {
    return PrefsService.prefs.getInt(PrefsNames.PACKET_ID_COUNTER_KEY) ?? 0;
  }

  //
  // Clear all saved preferences
  //
  static Future<bool> clearAll() async {
    return PrefsService.prefs.clear();
  }

  //
  // Service email
  //

  static Future<void> saveServiceEmail(String email) async {
    await PrefsService.prefs.setString(PrefsNames.SERVICE_EMAIL_CODE, email);
  }

  static String loadServiceEmail() {
    final String mail = PrefsService.prefs.getString(PrefsNames.SERVICE_EMAIL_CODE);
    if (mail == null || mail.isEmpty) {
      return DefaultSettings.emailService;
    } else {
      return mail;
    }
  }

  static Future<void> setDataUploadingIncomplete({bool value = true}) async {
    return PrefsService.prefs.setBool(PrefsNames.DATA_UPLOADING_NOT_FINISHED, value);
  }

  static bool getDataUploadingIncomplete() {
    return PrefsService.prefs.getBool(PrefsNames.DATA_UPLOADING_NOT_FINISHED) ?? false;
  }

  //
  // Dispatcher URL
  //
  static Future<void> saveDispatcherUrlIndex(int index) async {
    return PrefsService.prefs.setInt(PrefsNames.DISPATCHER_URL_INDEX, index);
  }

  static Future<void> incrementDispatcherUrlIndex() async {
    final int newIndex = loadDispatcherUrlIndex() + 1;
    return PrefsService.prefs.setInt(PrefsNames.DISPATCHER_URL_INDEX, newIndex);
  }

  static int loadDispatcherUrlIndex() {
    return PrefsService.prefs.getInt(PrefsNames.DISPATCHER_URL_INDEX) ?? 0;
  }

  // Test start time
  static Future<void> saveTestStartTime(int timestampt) async {
    return PrefsService.prefs.setInt(PrefsNames.TEST_START_TIME_KEY, timestampt);
  }

  static int loadTestStartTimeMS() {
    return PrefsService.prefs.getInt(PrefsNames.TEST_START_TIME_KEY) ?? 0;
  }

  // Bluetooth device ID
  static Future<void> saveBluetoothDeviceID(String id) async {
    return PrefsService.prefs.setString(PrefsNames.BLUETOOTH_DEVICE_ID_KEY, id);
  }

  static String loadBluetoothDeviceID() {
    return PrefsService.prefs.getString(PrefsNames.BLUETOOTH_DEVICE_ID_KEY) ?? null;
  }
}

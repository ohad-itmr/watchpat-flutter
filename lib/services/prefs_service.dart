import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_pat/config/default_settings.dart';

class PrefsNames {

  static const String READING_KEY = DefaultSettings.appName + ".reading";
  static const String WRITING_KEY = DefaultSettings.appName + ".writing";
  static const String USER_PIN_CODE = DefaultSettings.appName + ".userpincode";
  static const String DEVICE_SERIAL_KEY = DefaultSettings.appName + ".deviceserial";
  static const String DEVICE_NAME_KEY = DefaultSettings.appName + ".devicename";
  static const String DEVICE_ADDRESS_KEY = DefaultSettings.appName + ".deviceaddress";
  static const String TEST_STATE_KEY = DefaultSettings.appName + ".teststate";
  static const String DATA_STATE_KEY = DefaultSettings.appName + ".datastate";
  static const String TEST_REAL_START_TIME_KEY = DefaultSettings.appName + ".testrealtime";
  static const String TEST_PACKET_TIME_KEY = DefaultSettings.appName + ".testpackettime";
  static const String PACKET_IDENTIFIER_KEY = DefaultSettings.appName + ".packetidentifier";
  static const String PACKET_REMOTE_IDENTIFIER_KEY =
      DefaultSettings.appName + ".packetremoteidentifier";
  static const String IS_FIRST_DEVICE_CONNECTION_KEY =
      DefaultSettings.appName + ".isfirstdeviceconnection";
  static const String IS_FIRST_SFTP_CONNECTION_KEY =
      DefaultSettings.appName + ".isfirstsftpconnection";
  static const String IS_IGNORE_DEVICE_ERRORS_KEY =
      DefaultSettings.appName + ".isignoredeviceerrors";
  static const String SFTP_HOST_KEY = DefaultSettings.appName + ".sftphost";
  static const String SFTP_PORT_KEY = DefaultSettings.appName + ".sftpport";
  static const String SFTP_USERNAME_KEY = DefaultSettings.appName + ".sftpusername";
  static const String SFTP_PASSWORD_KEY = DefaultSettings.appName + ".sftppassword";
  static const String SFTP_PATH_KEY = DefaultSettings.appName + ".sftppath";
}

class PrefsService {
  static const String TAG = 'PrefsService';

  static final PrefsService _provider = PrefsService._internal();

  static SharedPreferences prefs;

  factory PrefsService() {
    return _provider;
  }

  PrefsService._internal();
}

class PrefsProvider {
  //
  // packet identifier
  //
  static Future<int> getPacketIdentifier() async {
    int currIdentifier = PrefsService.prefs.getInt(PrefsNames.PACKET_IDENTIFIER_KEY);
    await PrefsService.prefs
        .setInt(PrefsNames.PACKET_IDENTIFIER_KEY, currIdentifier + 1);
    return currIdentifier;
  }

  //
  // remote packet identifier
  //
  static void saveRemotePacketIdentifier(final int id) async {
    await PrefsService.prefs.setInt(PrefsNames.PACKET_REMOTE_IDENTIFIER_KEY, id);
  }

  static int loadRemotePacketIdentifier() {
    return PrefsService.prefs.getInt(PrefsNames.PACKET_REMOTE_IDENTIFIER_KEY);
  }

  //
  // Device serial
  //
  static void saveDeviceSerial(final String serial) async {
    await PrefsService.prefs.setString(PrefsNames.DEVICE_SERIAL_KEY, serial);
  }

  static String loadDeviceSerial() {
    return PrefsService.prefs.getString(PrefsNames.DEVICE_SERIAL_KEY);
  }

  //
  // is first device connection
  //
  static void setFirstDeviceConnection() async {
    await PrefsService.prefs.setBool(PrefsNames.IS_FIRST_DEVICE_CONNECTION_KEY, false);
  }

  static bool getIsFirstDeviceConnection() {
    return PrefsService.prefs.getBool(PrefsNames.IS_FIRST_DEVICE_CONNECTION_KEY);
  }

  //
  // Device name
  //
  static void initDeviceName() async {
    await PrefsService.prefs.setString(PrefsNames.DEVICE_NAME_KEY, "ITAMAR_UART");
  }

  static void saveDeviceName(final String name) async {
    await PrefsService.prefs.setString(PrefsNames.DEVICE_NAME_KEY, name);
  }

  static String loadDeviceName() {
    return PrefsService.prefs.getString(PrefsNames.DEVICE_NAME_KEY);
  }

  //
  // is ignore device error
  //
  static void setIgnoreDeviceErrors(final bool value) async {
    await PrefsService.prefs.setBool(PrefsNames.IS_IGNORE_DEVICE_ERRORS_KEY, value);
  }

  static bool getIgnoreDeviceErrors() {
    return PrefsService.prefs.getBool(PrefsNames.IS_IGNORE_DEVICE_ERRORS_KEY);
  }
}

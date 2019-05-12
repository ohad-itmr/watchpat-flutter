import 'dart:typed_data';

import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/convert_formats.dart';
import 'package:my_pat/utils/log/log.dart';

class DeviceConfigPayload {
  static const String TAG = 'DeviceConfigPayload';

  S lang = sl<S>();

  //
  // fields length
  //
  static const int DEVICE_SERIAL_BYTES = 4;

  // SW_VERSION
  static const int OFFSET_FW_VERSION_MAJOR = 0; // 1 bytes
  static const int OFFSET_FW_VERSION_MINOR = 1; // 1 bytes
  static const int OFFSET_FW_COMPILATION_NUMBER = 2; // 2 bytes

  static const int OFFSET_VERSION_DATE = 4; // 12 bytes
  static const int OFFSET_VERSION_TIME = 16; // 9 bytes
  static const int OFFSET_COMPANY_NAME = 25; // 15 bytes
  static const int OFFSET_PRODUCT_NAME = 40; // 13 bytes
  static const int OFFSET_PRODUCT_TYPE = 53; // 1 bytes
  static const int OFFSET_DEVICE_SN = 54; // 4 bytes
  static const int OFFSET_HW_ID = 58; // 1 bytes
  static const int OFFSET_BRACELET_ID = 59; // 6 bytes
  static const int OFFSET_POBE_NS = 65; // 4 bytes

  static const int OFFSET_PROTOCOL_VERSION_MAJOR = 69; // 1 bytes
  static const int OFFSET_PROTOCOL_VERSION_MINOR = 70; // 1 bytes
  static const int OFFSET_PROTOCOL_COMPILATION_NUMBER = 71; // 2 bytes

  static const int OFFSET_RESERVED_1 = 73; // 9 bytes

  // SMARTPHONE_INFO
  static const int OFFSET_SMARTPHONE_INFO_INIT_EVENT = 82; // 2 bytes

  // SW_VERSION
  static const int OFFSET_SMARTPHONE_APP_VERSION_MAJOR = 84; // 1 bytes
  static const int OFFSET_SMARTPHONE_APP_VERSION_MINOR = 85; // 1 bytes
  static const int OFFSET_SMARTPHONE_APP_COMPILATION_NUMBER = 86; // 2 bytes

  // SW_OS_VERSION
  static const int OFFSET_SMARTPHONE_OS_VERSION_MAJOR = 88; // 1 bytes
  static const int OFFSET_SMARTPHONE_OS_VERSION_MINOR = 89; // 1 bytes
  static const int OFFSET_SMARTPHONE_OS_COMPILATION_NUMBER = 90; // 2 bytes

  // SW_KERNEL_VERSION
  static const int OFFSET_SMARTPHONE_KERNEL_VERSION_MAJOR = 92; // 1 bytes
  static const int OFFSET_SMARTPHONE_KERNEL_VERSION_MINOR = 93; // 1 bytes
  static const int OFFSET_SMARTPHONE_KERNEL_COMPILATION_NUMBER = 94; // 2 bytes

  static const int OFFSET_SMARTPHONE_MODEL = 96; // 16 bytes

  // DATE_TIME
  static const int OFFSET_START_TIME_INIT_EVENT_DATE = 112; // 2 bytes
  static const int OFFSET_START_TIME_YEAR = 114; // 1 bytes
  static const int OFFSET_START_TIME_MONTH = 115; // 1 bytes
  static const int OFFSET_START_TIME_DAY = 116; // 1 bytes
  static const int OFFSET_START_TIME_WEEKDAY = 117; // 1 bytes
  static const int OFFSET_START_TIME_INIT_EVENT_TIME = 118; // 2 bytes
  static const int OFFSET_START_TIME_INIT_EVENT_HOUR = 120; // 1 bytes
  static const int OFFSET_START_TIME_INIT_EVENT_MINUTE = 121; // 1 bytes
  static const int OFFSET_START_TIME_INIT_EVENT_SECOND = 122; // 1 bytes

  // CHANNEL_INFO
  static const int OFFSET_CHANNEL_INFO_START = 123; // 40 bytes
  static const int SIZE_CHANNEL_INFO = 8;
  static const int COUNT_CHANNEL_INFO = 5;

  // DIGSBP_INFO
  static const int OFFSET_DIGSBP_INFO_INIT_EVENT = 163; // 2 bytes
  static const int OFFSET_DIGSBP_FW_VERSION_MAJOR = 165; // 1 bytes
  static const int OFFSET_DIGSBP_FW_VERSION_MINOR = 166; // 1 bytes
  static const int OFFSET_DIGSBP_FW_COMPILATION_NUMBER = 167; // 2 bytes
  static const int OFFSET_DIGSBP_PROTOCOL_VERSION_MAJOR = 169; // 1 bytes
  static const int OFFSET_DIGSBP_PROTOCOL_VERSION_MINOR = 170; // 1 bytes
  static const int OFFSET_DIGSBP_PROTOCOL_COMPILATION_NUMBER = 171; // 2 bytes
  static const int OFFSET_DIGSBP_HW_VERSION = 173; // 1 bytes
  static const int OFFSET_DIGSBP_RESERVED = 174; // 1 bytes
  static const int OFFSET_DIGSBP_SERIAL_NUMBER = 175; // 4 bytes
  static const int OFFSET_DIGSBP_CONFIGURATION = 179; // 2 bytes
  static const int OFFSET_DIGSBP_SAMPLE_RATE = 181; // 2 bytes
  static const int OFFSET_DIGSBP_BIT_ERROR_FLAG = 183; // 2 bytes
  static const int OFFSET_DIGSBP_CRC = 185; // 2 bytes

  // SYNC_INFO
  static const int OFFSET_SYNC_INFO_INIT_EVENT = 187; // 2 bytes
  static const int OFFSET_SYNC_INFO_ZERO_WIDTH = 189; // 2 bytes
  static const int OFFSET_SYNC_INFO_ONE_WIDTH = 191; // 2 bytes
  static const int OFFSET_SYNC_INFO_REPETITION_INTERVAL = 193; // 2 bytes
  static const int OFFSET_SYNC_INFO_SYNC_INITIAL_STATE = 195; // 2 bytes

  static const int OFFSET_OXI_INIT_EVENT = 197; // 2 bytes

  // UPAT_OXI_INFO_WP200
  static const int OFFSET_OXI_INFO_WP200_INIT_WAVE_660 = 199; // 1 bytes
  static const int OFFSET_OXI_INFO_WP200_INIT_WAVE_910 = 200; // 1 bytes
  static const int OFFSET_OXI_UPAT_INFO_WP200_COEFF = 201; // 9 bytes
  static const int SIZE_OXI_UPAT_INFO_WP200_COEFF = 3;
  static const int COUNT_OXI_UPAT_INFO_WP200_COEFF = 3;

  // UPAT_OXI_INFO_WP300
  static const int OFFSET_OXI_INFO_WP300_INIT_WAVE_660 = 210; // 1 bytes
  static const int OFFSET_OXI_INFO_WP300_INIT_WAVE_910 = 211; // 1 bytes
  static const int OFFSET_OXI_INFO_WP300_COEFF = 212; // 9 bytes
  static const int SIZE_OXI_INFO_WP300_COEFF = 3;
  static const int COUNT_OXI_INFO_WP300_COEFF = 3;

  static const int OFFSET_PIN_CODE_NUMBER = 221; // 4 bytes

  static const int OFFSET_RESERVED_2 = 225;

  List<int> _configPayloadBytes;

  Version _deviceFWVersion;
  int _deviceSerial;

  static final DeviceConfigPayload _singleton =
      new DeviceConfigPayload._internal();

  factory DeviceConfigPayload() {
    return _singleton;
  }

  DeviceConfigPayload._internal();

  DeviceConfigPayload getNewInstance(List<int> bytesData) {
    DeviceConfigPayload config = _singleton;

    updateSmartPhoneInfo(bytesData);

    config._configPayloadBytes = bytesData;
    config._setFWVersion(bytesData);
    _setDeviceSerial(bytesData);

    Log.info(TAG,
        "Config values >> FW version: ${config.fWVersionString} | device S/N: ${config._deviceSerial}");
    return config;
  }

  String get fWVersionString => _deviceFWVersion.versionString;

  String get deviceSerial => _deviceSerial.toString();

  String get deviceHexSerial => _deviceSerial.toRadixString(16);

  List<int> get payloadBytes => _configPayloadBytes;

  void _setFWVersion(final List<int> bytesConfig) {
    final int compilation = ConvertFormats.byteArrayToHex([
      bytesConfig[OFFSET_FW_COMPILATION_NUMBER + 1],
      bytesConfig[OFFSET_FW_COMPILATION_NUMBER]
    ]);

    _deviceFWVersion = new Version(
      bytesConfig[OFFSET_FW_VERSION_MAJOR],
      bytesConfig[OFFSET_FW_VERSION_MINOR],
      compilation,
      lang.device_ver_name,
    );
  }

  void _setDeviceSerial(final List<int> bytesConfig) {
    final List<int> serialBytes = bytesConfig.sublist(
        OFFSET_DEVICE_SN, OFFSET_DEVICE_SN + DEVICE_SERIAL_BYTES);

    _deviceSerial =
        ConvertFormats.byteArrayToHex(serialBytes.reversed.toList());
  }

  static void updateSmartPhoneInfo(List<int> bytes) {
    bytes[OFFSET_SMARTPHONE_INFO_INIT_EVENT] = 0x0F;
    bytes[OFFSET_SMARTPHONE_INFO_INIT_EVENT + 1] = 0xF0;

    // TOTO implement app version logic
//  final List<String> appVersion = watchPATApp.getVersionName().split("[.]");
    final List<String> appVersion = ['0', '0', '1'];

    bytes[OFFSET_SMARTPHONE_APP_VERSION_MAJOR] = int.parse(appVersion[0]);
    if (appVersion.length > 1) {
      bytes[OFFSET_SMARTPHONE_APP_VERSION_MINOR] = int.parse(appVersion[1]);
    }
    if (appVersion.length > 2) {
      bytes[OFFSET_SMARTPHONE_APP_COMPILATION_NUMBER] =
          int.parse(appVersion[2]);
    }

    // TOTO implement app version logic
//    final List<String> osVersion = Build.VERSION.RELEASE.split("[.]");
    final List<String> osVersion = ['0', '0', '1'];
    bytes[OFFSET_SMARTPHONE_OS_VERSION_MAJOR] = int.parse(osVersion[0]);
    if (osVersion.length > 1) {
      bytes[OFFSET_SMARTPHONE_OS_VERSION_MINOR] = int.parse(osVersion[1]);
    }
    if (osVersion.length > 2) {
      bytes[OFFSET_SMARTPHONE_OS_COMPILATION_NUMBER] = int.parse(osVersion[2]);
    }

    // TOTO implement app version logic
//    final List<int> phoneModel = Build.MODEL.getBytes();
//    final List<int> phoneModel = Build.MODEL.getBytes();
//    final int modelValueSize = Math.min(phoneModel.length, 16);
//    System.arraycopy(phoneModel, 0, bytes, OFFSET_SMARTPHONE_MODEL, modelValueSize);
  }

  void updatePin(String pinString) {
    final int pin = int.parse(pinString);
    final List<int> bytes = ConvertFormats.longToByteList(pin, reversed: true);
    for (int i = 0; i < bytes.length; i++) {
      payloadBytes[OFFSET_PIN_CODE_NUMBER + i] = bytes[i];
    }
  }
}

enum CompareResults { VERSION_HIGHER, VERSION_IDENTICAL, VERSION_LOWER }

class Version {
  static const String TAG = 'Version';

  String _name;
  int _major;
  int _minor;
  int _compilation;

  Version(this._major, this._minor, this._compilation, this._name);

  String get versionString =>
      '$_major.$_minor${_compilation > 0 ? '.$_compilation' : ''}';

  CompareResults compareTo(final Version versionToCmp) {
    Log.info(TAG,
        'comparing versions:\n $_name: $versionString <--> ${versionToCmp._name}: ${versionToCmp.versionString}');

    if (versionToCmp._major > _major) {
      Log.info(TAG, '${versionToCmp._name} is higher');
      return CompareResults.VERSION_HIGHER;
    } else if (versionToCmp._major < _major) {
      Log.info(TAG, "${versionToCmp._name} is lower");
      return CompareResults.VERSION_LOWER;
    } else {
      if (versionToCmp._minor > _minor) {
        Log.info(TAG, "${versionToCmp._name} is higher");
        return CompareResults.VERSION_HIGHER;
      } else if (versionToCmp._minor < _minor) {
        Log.info(TAG, "${versionToCmp._name} is lower");
        return CompareResults.VERSION_LOWER;
      } else {
        if (versionToCmp._compilation > _compilation) {
          Log.info(TAG, "${versionToCmp._name} is higher");
          return CompareResults.VERSION_HIGHER;
        } else if (versionToCmp._compilation < _compilation) {
          Log.info(TAG, "${versionToCmp._name} is lower");
          return CompareResults.VERSION_LOWER;
        } else {
          Log.info(TAG, "versions identical");
          return CompareResults.VERSION_IDENTICAL;
        }
      }
    }
  }

  static Version stringToVersion(final String versionStr, final String name) {
    Log.info(TAG, "parsing version $name: $versionStr");
    final List<String> splitVersion = versionStr.split("[.]");
    if (splitVersion.length != 3) {
      Log.shout(TAG, "invalid version length format");
      return null;
    }

    try {
      int major = int.parse(splitVersion[0]);
      int minor = int.parse(splitVersion[1]);
      int compilation = int.parse(splitVersion[2]);
      return new Version(major, minor, compilation, name);
    } catch (e) {
      Log.shout(TAG, "invalid version format");
      return null;
    }
  }
}

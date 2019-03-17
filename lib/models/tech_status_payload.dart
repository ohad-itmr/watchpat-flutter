import 'package:my_pat/utility/log/log.dart';

class TechStatusPayload {
  //
  // offsets
  //
  static const int OFST_BATT_VOLT = 0; // 2 bytes
  static const int OFST_VDD_VOLT = 2; // 2 bytes
  static const int OFST_IR_LED_STATUS = 4; // 2 bytes
  static const int OFST_RED_LED_STATUS = 6; // 2 bytes
  static const int OFST_PAT_LED_STATUS = 8; // 2 bytes

  // firmware version
  int _batteryVoltage;
  int _vddVoltage;
  int _irLedStatus;
  int _redLedStatus;
  int _patLedStatus;

  //  constructor to prevent instantiating class
  static final TechStatusPayload _singleton = new TechStatusPayload._internal();

  factory TechStatusPayload() {
    return _singleton;
  }

  TechStatusPayload._internal();

  static TechStatusPayload getNewInstance(List<int> bytes) {
    TechStatusPayload returnConfig = new TechStatusPayload();

    returnConfig.setBatteryVoltage(bytes);
    returnConfig.setVddVoltage(bytes);
    returnConfig.setIrLedStatus(bytes);
    returnConfig.setRedLedStatus(bytes);
    returnConfig.setPatLedStatus(bytes);

    Log.info(
        "Tech status:\nBattery voltage: ${returnConfig._batteryVoltage}\nVVD voltage: ${returnConfig._vddVoltage}\nIR LED status: ${returnConfig._irLedStatus}\nRed LED status: ${returnConfig._redLedStatus}\nPat LED status: ${returnConfig._patLedStatus}");

    return returnConfig;
  }

  int get batteryVoltage => _batteryVoltage;

  int get vddVoltage => _vddVoltage;

  int get irLedStatus => _irLedStatus;

  int get redLedStatus => _redLedStatus;

  int get patLedStatus => _patLedStatus;

  void setBatteryVoltage(List<int> bytes) {
    _batteryVoltage = bytes[OFST_BATT_VOLT + 1] << 1 | bytes[OFST_BATT_VOLT];
  }

  void setVddVoltage(List<int> bytes) {
    _vddVoltage = bytes[OFST_VDD_VOLT + 1] << 1 | bytes[OFST_VDD_VOLT];
  }

  void setIrLedStatus(List<int> bytes) {
    _irLedStatus = bytes[OFST_IR_LED_STATUS + 1] << 1 | bytes[OFST_IR_LED_STATUS];
  }

  void setRedLedStatus(List<int> bytes) {
    _redLedStatus = bytes[OFST_RED_LED_STATUS + 1] << 1 | bytes[OFST_RED_LED_STATUS];
  }

  void setPatLedStatus(List<int> bytes) {
    _patLedStatus = bytes[OFST_PAT_LED_STATUS + 1] << 1 | bytes[OFST_PAT_LED_STATUS];
  }
}

import 'package:my_pat/domain_model/command_packets.dart';
import 'package:my_pat/domain_model/command_task.dart';
import 'package:my_pat/services/services.dart';

class DeviceCommands {
  static const String TAG = 'DeviceCommands';

  static const int PACKET_HEADER_SIZE = 24;
  static const int PACKET_CHUNK_SIZE = 20;
  static const int LOAD_FILE_CHUNK_SIZE = 256;

  static const int CMD_SIGNATURE_PACKET = 0xBBBB;
  static const int CMD_SIGNATURE_PACKET_INVALID = 0x0EEE;

  static const int CMD_OPCODE_ACK = 0x00;
  static const int CMD_OPCODE_START_SESSION = 0x01;
  static const int CMD_OPCODE_START_SESSION_CONFIRM = 0x02;
  static const int CMD_OPCODE_CONFIG = 0x03;
  static const int CMD_OPCODE_CONFIG_RESPONSE = 0x05;
  static const int CMD_OPCODE_START_ACQUISITION = 0x06;
  static const int CMD_OPCODE_STOP_ACQUISITION = 0x07;
  static const int CMD_OPCODE_DATA_PACKET = 0x08;
  static const int CMD_OPCODE_END_OF_TEST_DATA = 0x09;
  static const int CMD_OPCODE_ERROR_STATUS = 0x0A;
  static const int CMD_OPCODE_DEVICE_RESET = 0x0B;
  static const int CMD_OPCODE_SET_PARAMETERS_FILE = 0x0C;
  static const int CMD_OPCODE_GET_PARAMETERS_FILE = 0x0D;
  static const int CMD_OPCODE_PARAMETERS_FILE = 0x0E;
  static const int CMD_OPCODE_SEND_STORED_DATA = 0x10;
  static const int CMD_OPCODE_BIT_REQ = 0x12;
  static const int CMD_OPCODE_BIT_RES = 0x13;
  static const int CMD_OPCODE_GET_TECHNICAL_STATUS = 0x15;
  static const int CMD_OPCODE_TECHNICAL_STATUS_REPORT = 0x16;
  static const int CMD_OPCODE_GET_AFE_REGISTERS = 0x17;
  static const int CMD_OPCODE_AFE_REGISTERS_VALUES = 0x18;
  static const int CMD_OPCODE_SET_AFE_REGISTERS = 0x19;
  static const int CMD_OPCODE_GET_ACTIGRAPH_REGISTERS = 0x1A;
  static const int CMD_OPCODE_ACTIGRAPH_REGISTERS_VALUES = 0x1B;
  static const int CMD_OPCODE_SET_ACC_REGISTERS = 0x1C;
  static const int CMD_OPCODE_GET_UPAT_EEPROM = 0x1D;
  static const int CMD_OPCODE_UPAT_EEPROM_VALUES = 0x1E;
  static const int CMD_OPCODE_SET_UPAT_EEPROM = 0x1F;
  static const int CMD_OPCODE_GET_BRACELET_ID = 0x20;
  static const int CMD_OPCODE_BRACELET_ID_VALUES = 0x21;
  static const int CMD_OPCODE_SET_BRACELET_ID = 0x2200;
  static const int CMD_OPCODE_LEDS_CONTROL = 0x23;
  static const int CMD_OPCODE_SET_SERIAL_NUMBER = 0x24;
  static const int CMD_OPCODE_GET_PATIENT_ID = 0x25;
  static const int CMD_OPCODE_FW_UPGRADE_REQ = 0x30;
  static const int CMD_OPCODE_FW_UPGRADE_RES = 0x31;
  static const int CMD_OPCODE_GET_LOG_FILE = 0x44;
  static const int CMD_OPCODE_GET_LOG_FILE_RESPONSE = 0x45;
  static const int CMD_OPCODE_UNKNOWN = 0x0F;

  static const int CMD_OPCODE_IS_DEVICE_PAIRED = 0x2A;
  static const int CMD_OPCODE_IS_DEVICE_PAIRED_RES = 0x2B;

  static const int ACK_STATUS_OK = 0x00;
  static const int ACK_STATUS_CRC_FAIL = 0x01;
  static const int ACK_STATUS_ILLEGAL_OPCODE = 0x02;
  static const int ACK_STATUS_NON_UNIQUE_IDENTITY = 0x03;
  static const int ACK_STATUS_BUSY = 0x04;

  static const int SESSION_START_USE_TYPE_PATIENT = 0x01;
  static const int SESSION_START_USE_TYPE_SERVICE = 0x02;
  static const int SESSION_START_USE_TYPE_PRODUCTION = 0x04;
  static const int SESSION_START_USE_TYPE_DEVELOPER = 0x08;

  static const int ERROR_BATTERY_LOW = 0x11; // Low battery detected during sleep test
  static const int ERROR_BATTERY_RECOVERED = 0x12; // Battery recovered
  static const int ERROR_SBP_MISSING =
      0x14; // SBP is disconnected during SBP type recognition. Input voltage is 0
  static const int ERROR_NO_PULSE_SIGNAL =
      0x15; // No RED and/or IR and PAT/or signal. May be finger is not in probe
  static const int ERROR_DATA_WRITE_FAILED = 0x17; // Error writing data to flash
  static const int ERROR_BATTERY_VOLTAGE_HIGH = 0x18;
  static const int ERROR_BATTERY_HIGH_DEPLETION = 0x19; // Battery voltage drops too fast
  static const int ERROR_SBP_STOPS_TRANSMIT_DATA = 0x1B;
  static const int ERROR_SBP_INTERMITTENT_CONNECTION = 0x1C;
  static const int ERROR_SBP_TRANSMIT_DATA_RECOVERED = 0x1D;
  static const int ERROR_BRACELET_ABSENT = 0x1E;
  static const int ERROR_BRACELET_INTERMITTENT_CONNECTION = 0x1F;
  static const int ERROR_BRACELET_TRANSMIT_DATA_RECOVERED = 0x20;
  static const int ERROR_RED_SATURATED = 0x21;
  static const int ERROR_RED_ADJUSTED = 0x22;
  static const int ERROR_IR_SATURATED = 0x23;
  static const int ERROR_IR_ADJUSTED = 0x24;
  static const int ERROR_PAT_SATURATED = 0x25;
  static const int ERROR_PAT_ADJUSTED = 0x26;
  static const int ERROR_AFE_TEST_FAILED = 0x27;
  static const int ERROR_ACTIGRAPH_TEST_FAILED = 0x28;
  static const int ERROR_BATTERY_TEST_FAILED = 0x2B;
  static const int ERROR_FLASH_TEST_FAILED = 0x2C;
  static const int ERROR_CRITICAL_HW_FAILURE = 0x2D;
  static const int ERROR_UNSENT_DATA = 0x44;
  static const int ERROR_FLASH_FULL = 0x47;
  static const int ERROR_REUSE_PRODUCT = 0x49;

  static const int BIT_MASK_ALL_TESTS = 0x0001;
  static const int BIT_MASK_AFE_LEDS = 0x0002;
  static const int BIT_MASK_AFE_PHOTODIODE = 0x0004;
  static const int BIT_MASK_DC_DC = 0x0010;
  static const int BIT_MASK_BATTERY = 0x0020;
  static const int BIT_MASK_FLASH = 0x0040;
  static const int BIT_MASK_ACTIGRAPH = 0x0080;
  static const int BIT_MASK_SBP_EXIST = 0x0100;
  static const int BIT_MASK_UPAT_EEPROM = 0x0200;
  static const int BIT_MASK_RTC = 0x0400;
  static const int BIT_MASK_BRACELET = 0x0800;
  static const int BIT_MASK_FINGER = 0x1000;

  static const int TECH_CMD_TIMEOUT = 3000;

  static const String FW_UPGRADE_CMD_NAME = "FWUpgradeRequest";

  static int getPacketIdentifier() {
    final int currentPacketId = PrefsProvider.loadPacketId();
    final int newPacketId = currentPacketId + 1;
    PrefsProvider.savePacketId(newPacketId);
    return currentPacketId;

//    final packetId = _packetIdCounter;
//    _packetIdCounter = _packetIdCounter + 1;
//    return packetId;
  }

  static CommandTask getAckCmd(int reqOpcode, int status, int packetID) {
    AckCommandPacket cmdPacket = new AckCommandPacket(reqOpcode, status, packetID);
    return new CommandTask("Ack", packetID, cmdPacket.opCode, cmdPacket.prepare());
  }

  static CommandTask getStartSessionCmd(
    int mobileID,
    int useType,
    List<int> swVersion,
  ) {
    final int packetID = getPacketIdentifier();
    SessionStartCommandPacket cmdPacket =
        new SessionStartCommandPacket(mobileID, useType, swVersion, packetID);
    return new CommandTask("StartSession", packetID, cmdPacket.opCode, cmdPacket.prepare());
  }

  static CommandTask getStartAcquisitionCmd() {
    final int packetID = getPacketIdentifier();
    CommandPacket cmdPacket = new CommandPacket(CMD_OPCODE_START_ACQUISITION, 0, packetID, 0);
    return new CommandTask("StartAcquisition", packetID, cmdPacket.opCode, cmdPacket.prepare());
  }

  static CommandTask getStopAcquisitionCmd() {
    final int packetID = getPacketIdentifier();
    CommandPacket cmdPacket = new CommandPacket(CMD_OPCODE_STOP_ACQUISITION, 0, packetID, 0);
    return new CommandTask("StopAcquisition", packetID, cmdPacket.opCode, cmdPacket.prepare());
  }

  static CommandTask getConfigCmd() {
    final int packetID = getPacketIdentifier();
    CommandPacket cmdPacket = new CommandPacket(CMD_OPCODE_CONFIG, 0, packetID, 0);
    return new CommandTask("ConfigurationRequest", packetID, cmdPacket.opCode, cmdPacket.prepare());
  }

  static CommandTask getSendStoredDataCmd() {
    final int packetID = getPacketIdentifier();
    CommandPacket cmdPacket = new CommandPacket(CMD_OPCODE_SEND_STORED_DATA, 0, packetID, 0);
    return new CommandTask("SendStoredData", packetID, cmdPacket.opCode, cmdPacket.prepare());
  }

  static CommandTask getResetDeviceCmd(final int flag) {
    final int packetID = getPacketIdentifier();
    ResetCommandPacket cmdPacket = new ResetCommandPacket(flag, packetID);
    return new CommandTask("ResetDevice", packetID, cmdPacket.opCode, cmdPacket.prepare());
  }

  static CommandTask getSetLEDsCmd(final int led) {
    final int packetID = getPacketIdentifier();
    SetLEDsCommandPacket cmdPacket = new SetLEDsCommandPacket(led, packetID);
    return new CommandTask("SetLEDs", packetID, cmdPacket.opCode, cmdPacket.prepare());
  }

  static CommandTask getSetDeviceSerialCmd(final int serial) {
    final int packetID = getPacketIdentifier();
    SetDeviceSerialCommandPacket cmdPacket = new SetDeviceSerialCommandPacket(serial, packetID);
    return new CommandTask("SetDeviceSerial", packetID, cmdPacket.opCode, cmdPacket.prepare());
  }

  // Parameters file
  static CommandTask getGetParametersFileCmd(final int offset, final int length) {
    final int packetID = getPacketIdentifier();
    GetParametersFilePacket cmdPacket = new GetParametersFilePacket(packetID, offset, length);
    return new CommandTask("GetDeviceParamFile", packetID, cmdPacket.opCode, cmdPacket.prepare());
  }

  static CommandTask getSetParametersFileCmd(final List<int> chunk, final int offset) {
    final int packetID = getPacketIdentifier();
    SetParametersFilePacket cmdPacket = new SetParametersFilePacket(packetID, chunk, offset);
    return new CommandTask("SetDeviceParamFile", packetID, cmdPacket.opCode, cmdPacket.prepare());
  }

  // Log file
  static CommandTask getGetLogFileCmd(final int offset, final int length) {
    final int packetID = getPacketIdentifier();
    GetLogFilePacket cmdPacket = new GetLogFilePacket(packetID, offset, length);
    return new CommandTask("GetDeviceLogFile", packetID, cmdPacket.opCode, cmdPacket.prepare());
  }

  // AFE registers
  static CommandTask getGetAFERegistersCmd() {
    final int packetID = getPacketIdentifier();
    CommandPacket cmdPacket = new CommandPacket(CMD_OPCODE_GET_AFE_REGISTERS, 0, packetID, 0);
    return new CommandTask("GetAFERegisters", packetID, cmdPacket.opCode, cmdPacket.prepare());
  }

  static CommandTask getSetAFERegistersCmd(final List<int> regData) {
    final int packetID = getPacketIdentifier();
    SetAFERegistersPacket cmdPacket = new SetAFERegistersPacket(packetID, regData);
    return new CommandTask("SetAFERegisters", packetID, cmdPacket.opCode, cmdPacket.prepare());
  }

  // ACC registers
  static CommandTask getGetACCRegistersCmd() {
    final int packetID = getPacketIdentifier();
    CommandPacket cmdPacket = new CommandPacket(CMD_OPCODE_GET_ACTIGRAPH_REGISTERS, 0, packetID, 0);
    return new CommandTask("GetACCRegisters", packetID, cmdPacket.opCode, cmdPacket.prepare());
  }

  static CommandTask getSetACCRegistersCmd(final List<int> regData) {
    final int packetID = getPacketIdentifier();
    SetACCRegistersPacket cmdPacket = new SetACCRegistersPacket(packetID, regData);
    return new CommandTask("SetACCRegisters", packetID, cmdPacket.opCode, cmdPacket.prepare());
  }

  // EEPROM
  static CommandTask getGetEEPROMCmd() {
    final int packetID = getPacketIdentifier();
    CommandPacket cmdPacket = new CommandPacket(CMD_OPCODE_GET_UPAT_EEPROM, 0, packetID, 0);
    return new CommandTask("GetEEPROM", packetID, cmdPacket.opCode, cmdPacket.prepare());
  }

  static CommandTask getSetEEPROMCmd(final List<int> regData) {
    final int packetID = getPacketIdentifier();
    SetEEPROMPacket cmdPacket = new SetEEPROMPacket(packetID, regData);
    return new CommandTask("SetEEPROM", packetID, cmdPacket.opCode, cmdPacket.prepare());
  }

  static CommandTask getGetTechnicalStatusCmd() {
    final int packetID = getPacketIdentifier();
    CommandPacket cmdPacket = new CommandPacket(CMD_OPCODE_GET_TECHNICAL_STATUS, 0, packetID, 0);
    return new CommandTask(
        "TechnicalStatusRequest", packetID, cmdPacket.opCode, cmdPacket.prepare());
  }

  static CommandTask getBitRequestCmd(final int bitOper) {
    final int packetID = getPacketIdentifier();
    BitReqPacket cmdPacket = new BitReqPacket(bitOper, packetID);
    return new CommandTask("BITRequest", packetID, cmdPacket.opCode, cmdPacket.prepare());
  }

  static CommandTask getFWUpgradeRequestCmd(
      final int offset, final int length, final List<int> data) {
    final int packetID = getPacketIdentifier();
    FWUpgradeRequestPacket cmdPacket = new FWUpgradeRequestPacket(offset, length, data, packetID);
    return new CommandTask(FW_UPGRADE_CMD_NAME, packetID, cmdPacket.opCode, cmdPacket.prepare());
  }

  static CommandTask getIsDevicePairedCmd() {
    final int packetID = getPacketIdentifier();
    CommandPacket cmdPacket = CommandPacket(CMD_OPCODE_IS_DEVICE_PAIRED, 0, packetID, 0);
    return CommandTask("IsDevicePaired", packetID, cmdPacket.opCode, cmdPacket.prepare());
  }

  //
  // MISC
  //

  static String byteToHex(int number) => number.toRadixString(16);

  static String bytesToHex(final List<int> bytes) {
    String result = '';
    bytes.forEach((byte) => result = result + byte.toRadixString(16));
    return result;
  }
}

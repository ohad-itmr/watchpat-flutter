import 'package:flutter_blue/flutter_blue.dart';
import 'package:my_pat/utility/crc16.dart';
import 'package:my_pat/utility/lists_combainer.dart';
import 'package:my_pat/utility/log/log.dart';
import 'package:my_pat/utility/time_utils.dart';
import 'package:my_pat/utility/convert_formats.dart';
import 'package:stack_trace/stack_trace.dart';

class BleProvider {
  static const String SERVICE_UID = '6e400001-b5a3-f393-e0a9-e50e24dcca9e';
  static const String TX_CHAR_UUID = '6e400003-b5a3-f393-e0a9-e50e24dcca9e';
  static const String RX_CHAR_UUID = '6e400002-b5a3-f393-e0a9-e50e24dcca9e';

  static const int SEND_COMMANDS_DELAY = 10;
  static const int SEND_ACK_DELAY = 2000;
  static const int MAX_COMMAND_TIMEOUT = 10000;

  FlutterBlue flutterBlue = FlutterBlue.instance;
}

class CommandTask {
  List<List<int>> _byteList;
  int _packetIdentifier;
  int _opCode;
  String _name;

  CommandTask(this._name, this._packetIdentifier, this._opCode, this._byteList);

  List<List<int>> get byteList => _byteList;

  int get packetIdentifier => _packetIdentifier;

  int get opCode => _opCode;

  String get name => _name;
}

class DeviceCommands {
  static const int PACKET_HEADER_SIZE = 24;
  static const int PACKET_CHUNK_SIZE = 20;
  static const int LOAD_FILE_CHUNK_SIZE = 256;

  static const int CMD_SIGNATURE_PACKET = 0xBBBB;
  static const int CMD_SIGNATURE_PACKET_INVALID = 0x0EEE;

  static const int CMD_OPCODE_ACK = 0x0000;
  static const int CMD_OPCODE_START_SESSION = 0x0100;
  static const int CMD_OPCODE_START_SESSION_CONFIRM = 0x0200;
  static const int CMD_OPCODE_CONFIG = 0x0300;
  static const int CMD_OPCODE_CONFIG_RESPONSE = 0x0500;
  static const int CMD_OPCODE_START_ACQUISITION = 0x0600;
  static const int CMD_OPCODE_STOP_ACQUISITION = 0x0700;
  static const int CMD_OPCODE_DATA_PACKET = 0x0800;
  static const int CMD_OPCODE_END_OF_TEST_DATA = 0x0900;
  static const int CMD_OPCODE_ERROR_STATUS = 0x0A00;
  static const int CMD_OPCODE_DEVICE_RESET = 0x0B00;
  static const int CMD_OPCODE_SET_PARAMETERS_FILE = 0x0C00;
  static const int CMD_OPCODE_GET_PARAMETERS_FILE = 0x0D00;
  static const int CMD_OPCODE_PARAMETERS_FILE = 0x0E00;
  static const int CMD_OPCODE_SEND_STORED_DATA = 0x1000;
  static const int CMD_OPCODE_BIT_REQ = 0x1200;
  static const int CMD_OPCODE_BIT_RES = 0x1300;
  static const int CMD_OPCODE_GET_TECHNICAL_STATUS = 0x1500;
  static const int CMD_OPCODE_TECHNICAL_STATUS_REPORT = 0x1600;
  static const int CMD_OPCODE_GET_AFE_REGISTERS = 0x1700;
  static const int CMD_OPCODE_AFE_REGISTERS_VALUES = 0x1800;
  static const int CMD_OPCODE_SET_AFE_REGISTERS = 0x1900;
  static const int CMD_OPCODE_GET_ACTIGRAPH_REGISTERS = 0x1A00;
  static const int CMD_OPCODE_ACTIGRAPH_REGISTERS_VALUES = 0x1B00;
  static const int CMD_OPCODE_SET_ACC_REGISTERS = 0x1C00;
  static const int CMD_OPCODE_GET_UPAT_EEPROM = 0x1D00;
  static const int CMD_OPCODE_UPAT_EEPROM_VALUES = 0x1E00;
  static const int CMD_OPCODE_SET_UPAT_EEPROM = 0x1F00;
  static const int CMD_OPCODE_GET_BRACELET_ID = 0x2000;
  static const int CMD_OPCODE_BRACELET_ID_VALUES = 0x2100;
  static const int CMD_OPCODE_SET_BRACELET_ID = 0x2200;
  static const int CMD_OPCODE_LEDS_CONTROL = 0x2300;
  static const int CMD_OPCODE_SET_SERIAL_NUMBER = 0x2400;
  static const int CMD_OPCODE_GET_PATIENT_ID = 0x2500;
  static const int CMD_OPCODE_FW_UPGRADE_REQ = 0x3000;
  static const int CMD_OPCODE_FW_UPGRADE_RES = 0x3100;
  static const int CMD_OPCODE_GET_LOG_FILE = 0x4400;
  static const int CMD_OPCODE_GET_LOG_FILE_RESPONSE = 0x4500;
  static const int CMD_OPCODE_UNKNOWN = 0x0F00;

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

  static int _packetIdCounter = 0;

  static int getPacketIdentifier() {
    final packetId = _packetIdCounter;
    _packetIdCounter = _packetIdCounter + 1;
    return packetId;
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
    return new CommandTask(
        "StartSession", packetID, cmdPacket.opCode, cmdPacket.prepare());
  }

  static CommandTask getStartAcquisitionCmd() {
    final int packetID = getPacketIdentifier();
    CommandPacket cmdPacket =
        new CommandPacket(CMD_OPCODE_START_ACQUISITION, 0, packetID, 0);
    return new CommandTask(
        "StartAcquisition", packetID, cmdPacket.opCode, cmdPacket.prepare());
  }

  static CommandTask getStopAcquisitionCmd() {
    final int packetID = getPacketIdentifier();
    CommandPacket cmdPacket =
        new CommandPacket(CMD_OPCODE_STOP_ACQUISITION, 0, packetID, 0);
    return new CommandTask(
        "StopAcquisition", packetID, cmdPacket.opCode, cmdPacket.prepare());
  }

  static CommandTask getConfigCmd() {
    final int packetID = getPacketIdentifier();
    CommandPacket cmdPacket = new CommandPacket(CMD_OPCODE_CONFIG, 0, packetID, 0);
    return new CommandTask(
        "ConfigurationRequest", packetID, cmdPacket.opCode, cmdPacket.prepare());
  }

  static CommandTask getSendStoredDataCmd() {
    final int packetID = getPacketIdentifier();
    CommandPacket cmdPacket =
        new CommandPacket(CMD_OPCODE_SEND_STORED_DATA, 0, packetID, 0);
    return new CommandTask(
        "SendStoredData", packetID, cmdPacket.opCode, cmdPacket.prepare());
  }

  static CommandTask getResetDeviceCmd(final int flag) {
    final int packetID = getPacketIdentifier();
    ResetCommandPacket cmdPacket = new ResetCommandPacket(flag, packetID);
    return new CommandTask(
        "ResetDevice", packetID, cmdPacket.opCode, cmdPacket.prepare());
  }

  static CommandTask getSetLEDsCmd(final int led) {
    final int packetID = getPacketIdentifier();
    SetLEDsCommandPacket cmdPacket = new SetLEDsCommandPacket(led, packetID);
    return new CommandTask("SetLEDs", packetID, cmdPacket.opCode, cmdPacket.prepare());
  }

  static CommandTask getSetDeviceSerialCmd(final int serial) {
    final int packetID = getPacketIdentifier();
    SetDeviceSerialCommandPacket cmdPacket =
        new SetDeviceSerialCommandPacket(serial, packetID);
    return new CommandTask(
        "SetDeviceSerial", packetID, cmdPacket.opCode, cmdPacket.prepare());
  }

  // Parameters file
  static CommandTask getGetParametersFileCmd(final int offset, final int length) {
    final int packetID = getPacketIdentifier();
    GetParametersFilePacket cmdPacket =
        new GetParametersFilePacket(packetID, offset, length);
    return new CommandTask(
        "GetDeviceParamFile", packetID, cmdPacket.opCode, cmdPacket.prepare());
  }

  static CommandTask getSetParametersFileCmd(final List<int> chunk, final int offset) {
    final int packetID = getPacketIdentifier();
    SetParametersFilePacket cmdPacket =
        new SetParametersFilePacket(packetID, chunk, offset);
    return new CommandTask(
        "SetDeviceParamFile", packetID, cmdPacket.opCode, cmdPacket.prepare());
  }

  // Log file
  static CommandTask getGetLogFileCmd(final int offset, final int length) {
    final int packetID = getPacketIdentifier();
    GetLogFilePacket cmdPacket = new GetLogFilePacket(packetID, offset, length);
    return new CommandTask(
        "GetDeviceLogFile", packetID, cmdPacket.opCode, cmdPacket.prepare());
  }

  // AFE registers
  static CommandTask getGetAFERegistersCmd() {
    final int packetID = getPacketIdentifier();
    CommandPacket cmdPacket =
        new CommandPacket(CMD_OPCODE_GET_AFE_REGISTERS, 0, packetID, 0);
    return new CommandTask(
        "GetAFERegisters", packetID, cmdPacket.opCode, cmdPacket.prepare());
  }

  static CommandTask getSetAFERegistersCmd(final List<int> regData) {
    final int packetID = getPacketIdentifier();
    SetAFERegistersPacket cmdPacket = new SetAFERegistersPacket(packetID, regData);
    return new CommandTask(
        "SetAFERegisters", packetID, cmdPacket.opCode, cmdPacket.prepare());
  }

  // ACC registers
  static CommandTask getGetACCRegistersCmd() {
    final int packetID = getPacketIdentifier();
    CommandPacket cmdPacket =
        new CommandPacket(CMD_OPCODE_GET_ACTIGRAPH_REGISTERS, 0, packetID, 0);
    return new CommandTask(
        "GetACCRegisters", packetID, cmdPacket.opCode, cmdPacket.prepare());
  }

  static CommandTask getSetACCRegistersCmd(final List<int> regData) {
    final int packetID = getPacketIdentifier();
    SetACCRegistersPacket cmdPacket = new SetACCRegistersPacket(packetID, regData);
    return new CommandTask(
        "SetACCRegisters", packetID, cmdPacket.opCode, cmdPacket.prepare());
  }

  // EEPROM
  static CommandTask getGetEEPROMCmd() {
    final int packetID = getPacketIdentifier();
    CommandPacket cmdPacket =
        new CommandPacket(CMD_OPCODE_GET_UPAT_EEPROM, 0, packetID, 0);
    return new CommandTask("GetEEPROM", packetID, cmdPacket.opCode, cmdPacket.prepare());
  }

  static CommandTask getSetEEPROMCmd(final List<int> regData) {
    final int packetID = getPacketIdentifier();
    SetEEPROMPacket cmdPacket = new SetEEPROMPacket(packetID, regData);
    return new CommandTask("SetEEPROM", packetID, cmdPacket.opCode, cmdPacket.prepare());
  }

  static CommandTask getGetTechnicalStatusCmd() {
    final int packetID = getPacketIdentifier();
    CommandPacket cmdPacket =
        new CommandPacket(CMD_OPCODE_GET_TECHNICAL_STATUS, 0, packetID, 0);
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
    FWUpgradeRequestPacket cmdPacket =
        new FWUpgradeRequestPacket(offset, length, data, packetID);
    return new CommandTask(
        "FWUpgradeRequest", packetID, cmdPacket.opCode, cmdPacket.prepare());
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

class Header {
  // Header - #1 part (20 bytes)
  int _signature;
  final int _opCode;
  final int _timeStamp;
  final int _packetID;
  int _packetLength = DeviceCommands.PACKET_HEADER_SIZE;
  final int _opCodeDep1 = 0;

  // Header - #2 part (4 bytes)
  final int _opCodeDep2 = 0;
  int _crc = 0;

  Header(this._opCode, this._timeStamp, this._packetID) {
    _signature = DeviceCommands.CMD_SIGNATURE_PACKET;
  }

  int get opCode => _opCode;

  List<int> get bytes => [
        ConvertFormats.longToByteList(_signature, size: 2),
        ConvertFormats.longToByteList(_opCode, size: 2),
        ConvertFormats.longToByteList(_timeStamp, size: 8),
        ConvertFormats.longToByteList(_packetID, size: 4),
        ConvertFormats.longToByteList(_packetLength, size: 2, reversed: false),
        ConvertFormats.longToByteList(_opCodeDep1, size: 2),
        ConvertFormats.longToByteList(_opCodeDep2, size: 2),
        ConvertFormats.longToByteList(_crc, size: 2),
      ].expand((x) => x).toList();

  set packetLength(int length) => _packetLength = length;

  set crc(int crc) => _crc = crc;
}

class CommandPacket {
  Header _header;
  int _packetSize;

  CommandPacket(int opCode, int timeStamp, int packetID, int payloadSize) {
    _header = Header(opCode, timeStamp, packetID);
    _packetSize = DeviceCommands.PACKET_HEADER_SIZE + payloadSize;
    _header.packetLength = _packetSize;
  }

  int get opCode => _header.opCode;

  List<List<int>> prepare() {
    calcCRC(_header.bytes);
    return getSplitPacketBytes(_header.bytes);
  }

  void calcCRC(List<int> bytes) {
    _header.crc = Crc16().convert(bytes);
  }

  List<List<int>> getSplitPacketBytes(List<int> bytes) {
    List<List<int>> byteList = List();
    int offset = 0;
    while (offset + DeviceCommands.PACKET_CHUNK_SIZE < bytes.length) {
      byteList.add(bytes.sublist(offset, offset + DeviceCommands.PACKET_CHUNK_SIZE));
      offset += DeviceCommands.PACKET_CHUNK_SIZE;
    }
    if (offset < bytes.length) {
      byteList.add(bytes.sublist(offset, bytes.length));
    }
    return byteList;
  }
}

class AckCommandPacket extends CommandPacket {
  int _reqOpcode;
  int _status;
  int _length;

  AckCommandPacket(this._reqOpcode, this._status, int packetID)
      : super(DeviceCommands.CMD_OPCODE_ACK, 0, packetID, 5) {
    _length = 0; // for future use
  }

  @override
  prepare() {
    final length = ConvertFormats.longToByteList(_length, size: 2);
    final status = ConvertFormats.longToByteList(_status, size: 1);
    final opCode = ConvertFormats.longToByteList(_reqOpcode, size: 2);

    List<int> buffer = ListCombainer.combain([_header.bytes, opCode, status, length],requiredLength: _packetSize);
    calcCRC(buffer);

    buffer.clear();
    buffer = ListCombainer.combain([_header.bytes, opCode, status, length],requiredLength: _packetSize);
    return getSplitPacketBytes(buffer);
  }
}

class SessionStartCommandPacket extends CommandPacket {
  int _mobileID;
  int _useType;
  List<int> _swVersion;
  int _key;

  String get tag => Trace.from(StackTrace.current).terse.toString();

  SessionStartCommandPacket(
    this._mobileID,
    this._useType,
    this._swVersion,
    int packetID,
  ) : super(DeviceCommands.CMD_OPCODE_START_SESSION, (TimeUtils.getTimeStamp()).toInt(),
            packetID, 20) {
    _key = 0;
  }

  @override
  List<List<int>> prepare() {
    final mobileId = ConvertFormats.longToByteList(_mobileID, size: 4);
    final useType = ConvertFormats.longToByteList(_useType, size: 1);
    final key = ConvertFormats.longToByteList(_key, size: 1);

    List<int> buffer =
        ListCombainer.combain([_header.bytes, mobileId, useType, _swVersion, key],requiredLength: _packetSize);

    calcCRC(buffer);

    buffer.clear();
    buffer = ListCombainer.combain([_header.bytes, mobileId, useType, _swVersion, key],requiredLength: _packetSize);
    return getSplitPacketBytes(buffer);
  }
}

class ResetCommandPacket extends CommandPacket {
  int _flag;

  ResetCommandPacket(this._flag, final int packetID)
      : super(DeviceCommands.CMD_OPCODE_DEVICE_RESET, 0, packetID, 1);

  @override
  List<List<int>> prepare() {
    final flag = ConvertFormats.longToByteList(_flag, size: 1);

    List<int> buffer = ListCombainer.combain([_header.bytes, flag],requiredLength: _packetSize);
    calcCRC(buffer);
    buffer.clear();
    buffer = ListCombainer.combain([_header.bytes, flag],requiredLength: _packetSize);
    return getSplitPacketBytes(buffer);
  }
}

class SetLEDsCommandPacket extends CommandPacket {
  int _led;

  SetLEDsCommandPacket(this._led, int packetID)
      : super(DeviceCommands.CMD_OPCODE_LEDS_CONTROL, 0, packetID, 1);

  @override
  List<List<int>> prepare() {
    final led = ConvertFormats.longToByteList(_led, size: 1);

    List<int> buffer = ListCombainer.combain([_header.bytes, led],requiredLength: _packetSize);
    calcCRC(buffer);
    buffer.clear();
    buffer = ListCombainer.combain([_header.bytes, led],requiredLength: _packetSize);
    return getSplitPacketBytes(buffer);
  }
}

class SetDeviceSerialCommandPacket extends CommandPacket {
  int _serial;

  SetDeviceSerialCommandPacket(this._serial, int packetID)
      : super(DeviceCommands.CMD_OPCODE_SET_SERIAL_NUMBER, 0, packetID, 4);

  @override
  List<List<int>> prepare() {
    final serial = ConvertFormats.longToByteList(_serial, size: 4);

    List<int> buffer = ListCombainer.combain([_header.bytes, serial],requiredLength: _packetSize);

    calcCRC(buffer);
    buffer.clear();
    buffer = ListCombainer.combain([_header.bytes, serial],requiredLength: _packetSize);
    return getSplitPacketBytes(buffer);
  }
}

class GetParametersFilePacket extends CommandPacket {
  int _offset;
  int _length; // payload length

  GetParametersFilePacket(int packetID, this._offset, this._length)
      : super(DeviceCommands.CMD_OPCODE_GET_PARAMETERS_FILE, 0, packetID, 4);

  @override
  List<List<int>> prepare() {
    final offset = ConvertFormats.longToByteList(_offset, size: 2);
    final length = ConvertFormats.longToByteList(_length, size: 2);

    List<int> buffer = ListCombainer.combain([_header.bytes, offset, length],requiredLength: _packetSize);

    calcCRC(buffer);
    buffer.clear();
    buffer = ListCombainer.combain([_header.bytes, offset, length],requiredLength: _packetSize);
    return getSplitPacketBytes(buffer);
  }
}

class SetParametersFilePacket extends CommandPacket {
  int _offset;
  int _length; // payload length
  List<int> _dataChunk;

  SetParametersFilePacket(int packetID, chunk, this._offset)
      : super(
          DeviceCommands.CMD_OPCODE_SET_PARAMETERS_FILE,
          0,
          packetID,
          chunk.length + 4,
        ) {
    _length = chunk.length; // payload length
    _dataChunk = chunk;
  }

  @override
  List<List<int>> prepare() {
    Log.shout(">>> set param file chunk size: ${_dataChunk.length}");
    final offset = ConvertFormats.longToByteList(_offset, size: 2);
    final length = ConvertFormats.longToByteList(_length, size: 2);

    List<int> buffer = ListCombainer.combain([_header.bytes, offset, length, _dataChunk],requiredLength: _packetSize);

    calcCRC(buffer);
    buffer.clear();
    buffer = ListCombainer.combain([_header.bytes, offset, length, _dataChunk],requiredLength: _packetSize);
    return getSplitPacketBytes(buffer);
  }
}

class GetLogFilePacket extends CommandPacket {
  int _offset;
  int _length; // payload length

  GetLogFilePacket(int packetID, this._offset, this._length)
      : super(DeviceCommands.CMD_OPCODE_GET_LOG_FILE, 0, packetID, 8);

  @override
  List<List<int>> prepare() {
    final offset = ConvertFormats.longToByteList(_offset, size: 2);
    final length = ConvertFormats.longToByteList(_length, size: 2);

    List<int> buffer = ListCombainer.combain([_header.bytes, offset, length],requiredLength: _packetSize);

    calcCRC(buffer);
    buffer.clear();
    buffer = ListCombainer.combain([_header.bytes, offset, length],requiredLength: _packetSize);
    return getSplitPacketBytes(buffer);
  }
}

class SetAFERegistersPacket extends CommandPacket {
  List<int> _regData;

  SetAFERegistersPacket(int packetID, List<int> regData)
      : super(DeviceCommands.CMD_OPCODE_SET_AFE_REGISTERS, 0, packetID, regData.length);

  @override
  List<List<int>> prepare() {
    List<int> buffer = ListCombainer.combain([_header.bytes, _regData],requiredLength: _packetSize);

    calcCRC(buffer);
    buffer.clear();
    buffer = ListCombainer.combain([_header.bytes, _regData],requiredLength: _packetSize);
    return getSplitPacketBytes(buffer);
  }
}

class SetACCRegistersPacket extends CommandPacket {
  List<int> _regData;

  SetACCRegistersPacket(int packetID, this._regData)
      : super(DeviceCommands.CMD_OPCODE_SET_ACC_REGISTERS, 0, packetID, _regData.length);

  @override
  List<List<int>> prepare() {
    List<int> buffer = ListCombainer.combain([_header.bytes, _regData],requiredLength: _packetSize);

    calcCRC(buffer);
    buffer.clear();
    buffer = ListCombainer.combain([_header.bytes, _regData],requiredLength: _packetSize);
    return getSplitPacketBytes(buffer);
  }
}

class SetEEPROMPacket extends CommandPacket {
  List<int> _regData;

  SetEEPROMPacket(int packetID, this._regData)
      : super(DeviceCommands.CMD_OPCODE_SET_UPAT_EEPROM, 0, packetID, _regData.length);

  @override
  List<List<int>> prepare() {
    List<int> buffer = ListCombainer.combain([_header.bytes, _regData],requiredLength: _packetSize);

    calcCRC(buffer);
    buffer.clear();
    buffer = ListCombainer.combain([_header.bytes, _regData],requiredLength: _packetSize);
    return getSplitPacketBytes(buffer);
  }
}

class BitReqPacket extends CommandPacket {
  int _bitType;

  BitReqPacket(this._bitType, final int packetID)
      : super(DeviceCommands.CMD_OPCODE_BIT_REQ, 0, packetID, 4);

  @override
  List<List<int>> prepare() {
    final bitType = ConvertFormats.longToByteList(_bitType, size: 4);

    List<int> buffer = ListCombainer.combain([_header.bytes, bitType],requiredLength: _packetSize);

    calcCRC(buffer);
    buffer.clear();
    buffer = ListCombainer.combain([_header.bytes, bitType],requiredLength: _packetSize);
    return getSplitPacketBytes(buffer);
  }
}

class FWUpgradeRequestPacket extends CommandPacket {
  int _offset;
  int _length;
  List<int> _upgradeData;

  FWUpgradeRequestPacket(this._offset, this._length, this._upgradeData, int packetID)
      : super(DeviceCommands.CMD_OPCODE_FW_UPGRADE_REQ, 0, packetID, _length + 8);

  @override
  List<List<int>> prepare() {
    final offset = ConvertFormats.longToByteList(_offset, size: 2);
    final length = ConvertFormats.longToByteList(_length, size: 2);

    List<int> buffer = ListCombainer.combain([_header.bytes, offset, length, _upgradeData],requiredLength: _packetSize);

    calcCRC(buffer);
    buffer.clear();
    buffer = ListCombainer.combain([_header.bytes, offset, length, _upgradeData],requiredLength: _packetSize);
    return getSplitPacketBytes(buffer);
  }
}

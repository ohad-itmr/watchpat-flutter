import 'package:my_pat/api/ble_provider.dart';
import 'package:my_pat/models/device_config_payload.dart';
import 'package:my_pat/models/tech_status_payload.dart';
import 'package:my_pat/utility/convert_formats.dart';
import 'package:my_pat/utility/log/log.dart';
import 'package:my_pat/utility/crc16.dart';
import 'package:my_pat/bloc/bloc_provider.dart';

class ReceivedPacket {
  static const int PACKET_SIGNATURE_STARTING_BYTE = 0;
  static const int PACKET_OPCODE_STARTING_BYTE = 2;
  static const int PACKET_IDENTIFIER_STARTING_BYTE = 12;
  static const int PACKET_SIZE_STARTING_BYTE = 16;
  static const int PACKET_DEPENDENT_STARTING_BYTE = 18;
  static const int PACKET_CRC_STARTING_BYTE = 22;

  List<int> bytes;
  int _signature;
  int opCode;
  int identifier;
  int _len;
  int opCodeDependent;

  final CommandTaskerBloc _commandTasker;

  int packetType;

  ReceivedPacket(this.bytes, this._commandTasker)
      : _signature = ConvertFormats.byteArrayToHex([bytes[1], bytes[0]]),
        opCode = int.parse(bytes
            .sublist(PACKET_OPCODE_STARTING_BYTE, PACKET_OPCODE_STARTING_BYTE + 2)
            .join()),
        identifier = int.parse(bytes
            .sublist(PACKET_IDENTIFIER_STARTING_BYTE, PACKET_IDENTIFIER_STARTING_BYTE + 4)
            .join()),
        _len = int.parse(bytes
            .sublist(PACKET_SIZE_STARTING_BYTE, PACKET_SIZE_STARTING_BYTE + 2)
            .join()),
        opCodeDependent = int.parse(bytes
            .sublist(PACKET_DEPENDENT_STARTING_BYTE, PACKET_DEPENDENT_STARTING_BYTE + 4)
            .join()) {
    packetType = _extractPacketType();
  }

  int get size => _len;

  int _extractPacketType() {
    print('_extractPacketType $_signature');
    print('_extractPacketType_2 ${_signature == DeviceCommands.CMD_SIGNATURE_PACKET}');
    if (_signature != DeviceCommands.CMD_SIGNATURE_PACKET) {
      return DeviceCommands.CMD_SIGNATURE_PACKET_INVALID;
    }

    if (opCode == DeviceCommands.CMD_OPCODE_ACK) {
      return DeviceCommands.CMD_OPCODE_ACK;
    }

    if (opCode == DeviceCommands.CMD_OPCODE_START_SESSION_CONFIRM) {
      return DeviceCommands.CMD_OPCODE_START_SESSION_CONFIRM;
    }

    if (opCode == DeviceCommands.CMD_OPCODE_CONFIG_RESPONSE) {
      return DeviceCommands.CMD_OPCODE_CONFIG_RESPONSE;
    }

    if (opCode == DeviceCommands.CMD_OPCODE_DATA_PACKET) {
      return DeviceCommands.CMD_OPCODE_DATA_PACKET;
    }

    if (opCode == DeviceCommands.CMD_OPCODE_END_OF_TEST_DATA) {
      return DeviceCommands.CMD_OPCODE_END_OF_TEST_DATA;
    }

    if (opCode == DeviceCommands.CMD_OPCODE_ERROR_STATUS) {
      return DeviceCommands.CMD_OPCODE_ERROR_STATUS;
    }

    if (opCode == DeviceCommands.CMD_OPCODE_GET_PARAMETERS_FILE) {
      return DeviceCommands.CMD_OPCODE_GET_PARAMETERS_FILE;
    }

    if (opCode == DeviceCommands.CMD_OPCODE_BIT_RES) {
      return DeviceCommands.CMD_OPCODE_BIT_RES;
    }

    if (opCode == DeviceCommands.CMD_OPCODE_TECHNICAL_STATUS_REPORT) {
      return DeviceCommands.CMD_OPCODE_TECHNICAL_STATUS_REPORT;
    }

    if (opCode == DeviceCommands.CMD_OPCODE_AFE_REGISTERS_VALUES) {
      return DeviceCommands.CMD_OPCODE_AFE_REGISTERS_VALUES;
    }

    if (opCode == DeviceCommands.CMD_OPCODE_ACTIGRAPH_REGISTERS_VALUES) {
      return DeviceCommands.CMD_OPCODE_ACTIGRAPH_REGISTERS_VALUES;
    }

    if (opCode == DeviceCommands.CMD_OPCODE_PARAMETERS_FILE) {
      return DeviceCommands.CMD_OPCODE_PARAMETERS_FILE;
    }

    if (opCode == DeviceCommands.CMD_OPCODE_GET_LOG_FILE_RESPONSE) {
      return DeviceCommands.CMD_OPCODE_GET_LOG_FILE_RESPONSE;
    }

    if (opCode == DeviceCommands.CMD_OPCODE_UPAT_EEPROM_VALUES) {
      return DeviceCommands.CMD_OPCODE_UPAT_EEPROM_VALUES;
    }

    if (opCode == DeviceCommands.CMD_OPCODE_FW_UPGRADE_RES) {
      return DeviceCommands.CMD_OPCODE_FW_UPGRADE_RES;
    }

    Log.shout("unknown packet type: ${opCode.toRadixString(16)}");
    return DeviceCommands.CMD_OPCODE_UNKNOWN;
  }

  bool isValidPacket() {
    if (packetType == DeviceCommands.CMD_SIGNATURE_PACKET_INVALID) {
      Log.shout("Illegal packet signature ");
      return false;
    } else if (packetType == DeviceCommands.CMD_OPCODE_UNKNOWN) {
      Log.shout("Unknown opCode");

      _commandTasker.addAck(DeviceCommands.getAckCmd(
          packetType, DeviceCommands.ACK_STATUS_ILLEGAL_OPCODE, identifier));
      return false;
    } else if (!_validatePacketCRC()) {
      Log.shout("Invalid CRC");
//      _commandTasker.addAck(DeviceCommands.getAckCmd(
//          packetType, DeviceCommands.ACK_STATUS_CRC_FAIL, identifier));
      return false;
    }

    return true;
  }

  bool _validatePacketCRC() {
    int crcByte1 = bytes[PACKET_CRC_STARTING_BYTE];
    int crcByte2 = bytes[PACKET_CRC_STARTING_BYTE + 1];
    print('Before validation $bytes');

    bytes[PACKET_CRC_STARTING_BYTE] = 0;
    bytes[PACKET_CRC_STARTING_BYTE + 1] = 0;

    int packetCRC = ConvertFormats.byteArrayToHex([crcByte2, crcByte1]);
    int validationCRC = Crc16().convert(bytes);

    bytes[PACKET_CRC_STARTING_BYTE] = crcByte1;
    bytes[PACKET_CRC_STARTING_BYTE + 1] = crcByte2;

    if (packetCRC == validationCRC) {
      return true;
    }

    Log.shout(
        "CRC validation failed. packet CRC: $packetCRC | should be: $validationCRC");
    return false;
  }

  List<int> extractPayload() {
    return bytes.sublist(DeviceCommands.PACKET_HEADER_SIZE);
  }

  List<int> extractParameterFilePayload() {
    return bytes.sublist(DeviceCommands.PACKET_HEADER_SIZE + 4);
  }

  int extractSingleBytePayload() {
    return bytes[DeviceCommands.PACKET_HEADER_SIZE];
  }

  DeviceConfigPayload extractConfigBlock() {
    return DeviceConfigPayload().getNewInstance(extractPayload());
  }

  TechStatusPayload extractTechStatusPayload() {
    return TechStatusPayload.getNewInstance(extractPayload());
  }

  int extractBitResponse() {
    return int.parse(extractPayload().reversed.join());
  }

  int extractLogFileSize() {
    List<int> packetSizeBytes = extractPayload().sublist(4, 8);
    return int.parse(packetSizeBytes.reversed.join());
  }

  int extractParamFileSize() {
    List<int> payload = extractPayload();
    List<int> bytes = List(4);
    bytes[2] = payload[3];
    bytes[3] = payload[2];
    return int.parse(bytes.join());
  }
}

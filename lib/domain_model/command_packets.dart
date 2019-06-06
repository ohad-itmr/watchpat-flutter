import 'package:my_pat/domain_model/device_commands.dart';
import 'package:my_pat/utils/convert_formats.dart';
import 'package:my_pat/utils/crc16.dart';
import 'package:my_pat/utils/lists_combainer.dart';
import 'package:my_pat/utils/log/log.dart';
import 'package:my_pat/utils/time_utils.dart';
import 'package:stack_trace/stack_trace.dart';

class Header {
  static const String TAG = 'Header';

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
        ConvertFormats.longToByteList(_opCode, size: 2, reversed: false),
        ConvertFormats.longToByteList(_timeStamp, size: 8, reversed: false),
        ConvertFormats.longToByteList(_packetID, size: 4, reversed: false),
        ConvertFormats.longToByteList(_packetLength, size: 2, reversed: false),
        ConvertFormats.longToByteList(_opCodeDep1, size: 2),
        ConvertFormats.longToByteList(_opCodeDep2, size: 2),
        ConvertFormats.longToByteList(_crc, size: 2, reversed: false),
//        [_crc & 0xff, (_crc >> 8) & 0xff],// CRC
      ].expand((x) => x).toList();

  set packetLength(int length) => _packetLength = length;

  set crc(int crc) => _crc = crc;
}

class CommandPacket {
  static const String TAG = 'CommandPacket';

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
    _header.crc = Crc16.convert(bytes);
  }

  List<List<int>> getSplitPacketBytes(List<int> bytes) {
    List<List<int>> byteList = List();
    int offset = 0;
    while (offset + DeviceCommands.PACKET_CHUNK_SIZE < bytes.length) {
      byteList.add(
          bytes.sublist(offset, offset + DeviceCommands.PACKET_CHUNK_SIZE));
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
    final opCode = ConvertFormats.longToByteList(_reqOpcode, size: 2, reversed: false);

    List<int> buffer = ListCombainer.combain(
        [_header.bytes, opCode, status, length],
        requiredLength: _packetSize);
    calcCRC(buffer);

    buffer.clear();
    buffer = ListCombainer.combain([_header.bytes, opCode, status, length],
        requiredLength: _packetSize);
    return getSplitPacketBytes(buffer);
  }
}

class SessionStartCommandPacket extends CommandPacket {
  static const String TAG = 'SessionStartCommandPacket';

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
  ) : super(DeviceCommands.CMD_OPCODE_START_SESSION, (TimeUtils.getTimeStamp()),
            packetID, 20) {
    _key = 0;
  }

  @override
  List<List<int>> prepare() {
    final mobileId = ConvertFormats.longToByteList(_mobileID, size: 4);
    final useType = ConvertFormats.longToByteList(_useType, size: 1);
    final key = ConvertFormats.longToByteList(_key, size: 1);
    List<int> buffer = ListCombainer.combain(
        [_header.bytes, mobileId, useType, _swVersion, key],
        requiredLength: _packetSize);
    print('$TAG - CommandPacket Send bytes to prepare $buffer ');

    calcCRC(buffer);

    buffer.clear();
    buffer = ListCombainer.combain(
        [_header.bytes, mobileId, useType, _swVersion, key],
        requiredLength: _packetSize);
    return getSplitPacketBytes(buffer);
  }
}

class ResetCommandPacket extends CommandPacket {
  static const String TAG = 'ResetCommandPacket';

  int _flag;

  ResetCommandPacket(this._flag, final int packetID)
      : super(DeviceCommands.CMD_OPCODE_DEVICE_RESET, 0, packetID, 1);

  @override
  List<List<int>> prepare() {
    final flag = ConvertFormats.longToByteList(_flag, size: 1);

    List<int> buffer = ListCombainer.combain([_header.bytes, flag],
        requiredLength: _packetSize);
    calcCRC(buffer);
    buffer.clear();
    buffer = ListCombainer.combain([_header.bytes, flag],
        requiredLength: _packetSize);
    return getSplitPacketBytes(buffer);
  }
}

class SetLEDsCommandPacket extends CommandPacket {
  static const String TAG = 'SetLEDsCommandPacket';

  int _led;

  SetLEDsCommandPacket(this._led, int packetID)
      : super(DeviceCommands.CMD_OPCODE_LEDS_CONTROL, 0, packetID, 1);

  @override
  List<List<int>> prepare() {
    final led = ConvertFormats.longToByteList(_led, size: 1);

    List<int> buffer = ListCombainer.combain([_header.bytes, led],
        requiredLength: _packetSize);
    calcCRC(buffer);
    buffer.clear();
    buffer = ListCombainer.combain([_header.bytes, led],
        requiredLength: _packetSize);
    return getSplitPacketBytes(buffer);
  }
}

class SetDeviceSerialCommandPacket extends CommandPacket {
  static const String TAG = 'SetDeviceSerialCommandPacket';

  int _serial;

  SetDeviceSerialCommandPacket(this._serial, int packetID)
      : super(DeviceCommands.CMD_OPCODE_SET_SERIAL_NUMBER, 0, packetID, 4);

  @override
  List<List<int>> prepare() {
    final serial = ConvertFormats.longToByteList(_serial, size: 4, reversed: false);

    List<int> buffer = ListCombainer.combain([_header.bytes, serial],
        requiredLength: _packetSize);

    calcCRC(buffer);
    buffer.clear();
    buffer = ListCombainer.combain([_header.bytes, serial],
        requiredLength: _packetSize);
    return getSplitPacketBytes(buffer);
  }
}

class GetParametersFilePacket extends CommandPacket {
  static const String TAG = 'GetParametersFilePacket';

  int _offset;
  int _length; // payload length

  GetParametersFilePacket(int packetID, this._offset, this._length)
      : super(DeviceCommands.CMD_OPCODE_GET_PARAMETERS_FILE, 0, packetID, 4);

  @override
  List<List<int>> prepare() {
    final offset =
        ConvertFormats.longToByteList(_offset, size: 2, reversed: false);
    final length =
        ConvertFormats.longToByteList(_length, size: 2, reversed: false);

    List<int> buffer = ListCombainer.combain([_header.bytes, offset, length],
        requiredLength: _packetSize);

    calcCRC(buffer);
    buffer.clear();
    buffer = ListCombainer.combain([_header.bytes, offset, length],
        requiredLength: _packetSize);
    return getSplitPacketBytes(buffer);
  }
}

class SetParametersFilePacket extends CommandPacket {
  static const String TAG = 'SetParametersFilePacket';

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
    Log.shout(TAG, ">>> set param file chunk size: ${_dataChunk.length}");
    final offset = ConvertFormats.longToByteList(_offset, size: 2);
    final length = ConvertFormats.longToByteList(_length, size: 2);

    List<int> buffer = ListCombainer.combain(
        [_header.bytes, offset, length, _dataChunk],
        requiredLength: _packetSize);

    calcCRC(buffer);
    buffer.clear();
    buffer = ListCombainer.combain([_header.bytes, offset, length, _dataChunk],
        requiredLength: _packetSize);
    return getSplitPacketBytes(buffer);
  }
}

class GetLogFilePacket extends CommandPacket {
  static const String TAG = 'GetLogFilePacket';

  int _offset;
  int _length; // payload length

  GetLogFilePacket(int packetID, this._offset, this._length)
      : super(DeviceCommands.CMD_OPCODE_GET_LOG_FILE, 0, packetID, 8);

  @override
  List<List<int>> prepare() {
    final offset = ConvertFormats.longToByteList(_offset, size: 4, reversed: false);
    final length = ConvertFormats.longToByteList(_length, size: 4, reversed: false);

    List<int> buffer = ListCombainer.combain([_header.bytes, offset, length],
        requiredLength: _packetSize);

    calcCRC(buffer);
    buffer.clear();
    buffer = ListCombainer.combain([_header.bytes, offset, length],
        requiredLength: _packetSize);
    return getSplitPacketBytes(buffer);
  }
}

class SetAFERegistersPacket extends CommandPacket {
  static const String TAG = 'SetAFERegistersPacket';

  List<int> _regData;

  SetAFERegistersPacket(int packetID, List<int> regData)
      : _regData = regData,
        super(DeviceCommands.CMD_OPCODE_SET_AFE_REGISTERS, 0, packetID,
            regData.length);

  @override
  List<List<int>> prepare() {
    List<int> buffer = ListCombainer.combain([_header.bytes, _regData],
        requiredLength: _packetSize);

    calcCRC(buffer);
    buffer.clear();
    buffer = ListCombainer.combain([_header.bytes, _regData],
        requiredLength: _packetSize);
    return getSplitPacketBytes(buffer);
  }
}

class SetACCRegistersPacket extends CommandPacket {
  static const String TAG = 'SetACCRegistersPacket';

  List<int> _regData;

  SetACCRegistersPacket(int packetID, this._regData)
      : super(DeviceCommands.CMD_OPCODE_SET_ACC_REGISTERS, 0, packetID,
            _regData.length);

  @override
  List<List<int>> prepare() {
    List<int> buffer = ListCombainer.combain([_header.bytes, _regData],
        requiredLength: _packetSize);

    calcCRC(buffer);
    buffer.clear();
    buffer = ListCombainer.combain([_header.bytes, _regData],
        requiredLength: _packetSize);
    return getSplitPacketBytes(buffer);
  }
}

class SetEEPROMPacket extends CommandPacket {
  static const String TAG = 'SetEEPROMPacket';

  List<int> _regData;

  SetEEPROMPacket(int packetID, this._regData)
      : super(DeviceCommands.CMD_OPCODE_SET_UPAT_EEPROM, 0, packetID,
            _regData.length);

  @override
  List<List<int>> prepare() {
    List<int> buffer = ListCombainer.combain([_header.bytes, _regData],
        requiredLength: _packetSize);

    calcCRC(buffer);
    buffer.clear();
    buffer = ListCombainer.combain([_header.bytes, _regData],
        requiredLength: _packetSize);
    return getSplitPacketBytes(buffer);
  }
}

class BitReqPacket extends CommandPacket {
  static const String TAG = 'BitReqPacket';

  int _bitType;

  BitReqPacket(this._bitType, final int packetID)
      : super(DeviceCommands.CMD_OPCODE_BIT_REQ, 0, packetID, 4);

  @override
  List<List<int>> prepare() {
    final bitType =
        ConvertFormats.longToByteList(_bitType, size: 4, reversed: false);

    List<int> buffer = ListCombainer.combain([_header.bytes, bitType],
        requiredLength: _packetSize);

    calcCRC(buffer);
    buffer.clear();
    buffer = ListCombainer.combain([_header.bytes, bitType],
        requiredLength: _packetSize);
    return getSplitPacketBytes(buffer);
  }
}

class FWUpgradeRequestPacket extends CommandPacket {
  static const String TAG = 'FWUpgradeRequestPacket';

  int _offset;
  int _length;
  List<int> _upgradeData;

  FWUpgradeRequestPacket(
      this._offset, this._length, this._upgradeData, int packetID)
      : super(
            DeviceCommands.CMD_OPCODE_FW_UPGRADE_REQ, 0, packetID, _length + 8);

  @override
  List<List<int>> prepare() {
    final offset = ConvertFormats.longToByteList(_offset, size: 4, reversed: false);
    final length = ConvertFormats.longToByteList(_length, size: 4, reversed: false);

    List<int> buffer = ListCombainer.combain(
        [_header.bytes, offset, length, _upgradeData],
        requiredLength: _packetSize);

    calcCRC(buffer);
    buffer.clear();
    buffer = ListCombainer.combain(
        [_header.bytes, offset, length, _upgradeData],
        requiredLength: _packetSize);
    return getSplitPacketBytes(buffer);
  }
}

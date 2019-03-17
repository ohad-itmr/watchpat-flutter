import 'package:my_pat/generated/i18n.dart';
import 'package:my_pat/bloc/helpers/bloc_base.dart';
import 'package:my_pat/bloc/bloc_provider.dart';
import 'package:my_pat/utility/log/log.dart';
import 'package:my_pat/utility/time_utils.dart';
import 'package:my_pat/utility/convert_formats.dart';
import 'package:my_pat/api/ble_provider.dart';
import 'package:my_pat/api/prefs_provider.dart';
import 'package:my_pat/api/received_packet.dart';
import 'package:my_pat/api/file_system_provider.dart';

enum PacketState { WAITING_FOR_NEW, HANDLING_PACKET, PACKET_COMPLETE }

class IncomingPacketHandlerBloc extends BlocBase {
  S lang;

  AppBloc _root;
  SystemStateBloc _systemStateBloc;
  CommandTaskerBloc _commandTasker;
  FileSystemProvider _fileSystemProvider = fileSystemProvider;

  static const int _PATIENT_ERROR_BATTERY_VOLTAGE_TEST = 0x0001;
  static const int _PATIENT_ERROR_ACTIGRAPH_TEST = 0x0008;
  static const int _PATIENT_ERROR_DEVICE_USED = 0x0020;
  static const int _PATIENT_ERROR_FLASH_TEST = 0x0040;
  static const int _PATIENT_ERROR_PROBE_LEDS_TEST = 0x0080;
  static const int _PATIENT_ERROR_PROBE_PHOTO_TEST = 0x0100;
  static const int _PATIENT_ERROR_SBP_TEST = 0x0400;
  static const int _PATIENT_ERROR_NO_FINGER = 0x2000;

  PacketState _packetState = PacketState.WAITING_FOR_NEW;

  WatchPATTimer _dataReceivedTimer;
  WatchPATTimer _testStartTimer;
  WatchPATTimer _packetAnalysisTimer;

  List<int> _receivedByteStream;
  List<int> _paramFileByteStream;
  List<int> _logFileByteStream;

  List<int> _incomingData;
  int _incomingPacketLength;
  bool _isPacketAnalysis;
  int _packetAnalyzed;
  int _bytesAnalyzed;

  bool _isFirstPacketOfDataReceived = false;
  bool _isDataReceiving = false;

  IncomingPacketHandlerBloc(this._root) {
    lang = S();
    _commandTasker = _root.commandTaskerBloc;
    _systemStateBloc = _root.systemStateBloc;
    _incomingPacketLength = 0;
    _dataReceivedTimer =
        WatchPATTimer('DataReceivedTimeout', 3000, () => _isDataReceiving = false);
    _packetAnalysisTimer = WatchPATTimer('PacketAnalysisTimer', 60 * 1000, () {
      _isPacketAnalysis = false;
      Log.info(
          '>>>>>>>>>>>> PACKET ANALYSIS END.\n\n @@@packets received: $_packetAnalyzed, \n@@@bytes received: $_bytesAnalyzed');
    });
    _testStartTimer = WatchPATTimer('TestStartTimeout', 60 * 1000, () {
      Log.info(">>>>>>>>>>>> STARTING PACKET ANALYSIS ,$this");
      _packetAnalysisTimer.startTimer();
      _isPacketAnalysis = true;
    });

    _packetAnalyzed = 0;
    _bytesAnalyzed = 0;
    _isPacketAnalysis = false;
  }

  void startPacketAnalysis() {
    _testStartTimer.startTimer();
  }

  bool isDataReceiving() {
    return _isDataReceiving;
  }

  void acceptAndHandleData(List<int> data) {
    _incomingData = data;

    if (_packetState == PacketState.WAITING_FOR_NEW) {
      // starting to receive a new packet
      Log.info("Handling new packet $this");
      _packetState = PacketState.HANDLING_PACKET;

      if (_isValidSignature()) {
        if (!_setPacketSize()) {
          Log.shout("Wrong packet size" + ConvertFormats.bytesToHex(data));
          resetPacket();
          return;
        }
        //Log.i(TAG, "Packet size: " + _incomingPacketLength);
      } else {
        Log.shout("Wrong starting packet " + ConvertFormats.bytesToHex(data));
        resetPacket();
        return;
      }
    }

    _recordPacket();

    if (_packetState == PacketState.PACKET_COMPLETE) {
      // packet is fully received
      ReceivedPacket receivedPacket = ReceivedPacket(_receivedByteStream, _commandTasker);
      final int packetType = receivedPacket.packetType;

      Log.info(">>> New packet: " + ConvertFormats.bytesToHex(receivedPacket.bytes));

      // packet validity check
      if (!receivedPacket.isValidPacket()) {
        resetPacket();
        return;
      }

      // system reaction to the packet
      switch (packetType) {
        case DeviceCommands.CMD_OPCODE_ACK:
          Log.info("packet received (ACK)");
          // ACK received - notify cmdTasker
          _commandTasker.ackCommandReceived(receivedPacket.identifier);
          break;
        case DeviceCommands.CMD_OPCODE_DATA_PACKET:
          Log.info("packet received (DATA_PACKET)");
          // data packet received - store to local file
          _isDataReceiving = true;
          _dataReceivedTimer.restart();

          if (_isPacketAnalysis) {
            _packetAnalyzed++;
            _bytesAnalyzed += receivedPacket.bytes.length;
          }

          // send data packet ACK
          _commandTasker.addAck(DeviceCommands.getAckCmd(
              packetType, DeviceCommands.ACK_STATUS_OK, receivedPacket.identifier));
          break;
        case DeviceCommands.CMD_OPCODE_START_SESSION_CONFIRM:
          Log.info("### start session confirm received");
          Log.info("packet received (START_SESSION_CONFIRM)");
          // start-session-confirm packet received
          // retrieve device configuration
          _root.configBloc.setDeviceConfiguration(receivedPacket.extractConfigBlock());
          Log.info("### start session confirm: device configuration set");
          if (_checkStartSessionErrors(receivedPacket.opCodeDependent)) {
            PrefsProvider.saveDeviceSerial(_root.configBloc.deviceConfig.deviceSerial);
            Log.info("### start session confirm: device serial saved");

            if (PrefsProvider.getIsFirstDeviceConnection()) {
              PrefsProvider.setFirstDeviceConnection();

              //getDataFileHandler().storeData(getDeviceConfiguration().getPayloadBytes());
              // TODO implement

//              _context.sendBroadcast(new Intent(ACTION_SEND_DISPATCHER)
//                  .putExtra(EXTRA_CMD, DISPATCHER_CMD_GET_CONFIG));

              Log.info("first connection to device");
              Log.info("### start session confirm: device FW version check START");
              //todo Firmwarer upgrade
//              if (getFirmwareUpgrader().isDeviceFirmwareVersionUpToDate()) {
//                Log.info("### start session confirm: device FW version check END");
//                Log.info("device FW up to date");
//                getStateNotifier()
//                    .setFirmwareState(SystemStateNotifier.FIRMWARE_STATE_UP_TO_DATE);
//              } else {
//                Log.info("device FW outdated");
//                getFirmwareUpgrader().upgradeDeviceFirmwareFromResources();
//              }
            }
          }
          // send start-session-confirm packet ACK
          _commandTasker.addAck(DeviceCommands.getAckCmd(
              packetType, DeviceCommands.ACK_STATUS_OK, receivedPacket.identifier));
          final String deviceName =
              "ITAMAR_${_root.configBloc.deviceConfig.deviceHexSerial}";
          Log.info("device new name: $deviceName");
          PrefsProvider.saveDeviceName(deviceName);
          Log.info("### start session confirm: END");
          break;
        case DeviceCommands.CMD_OPCODE_CONFIG_RESPONSE:
          Log.info("packet received (CONFIG_RESPONSE)");
          _root.configBloc.setDeviceConfiguration(receivedPacket.extractConfigBlock());
          PrefsProvider.saveDeviceSerial(_root.configBloc.deviceConfig.deviceSerial);
          _commandTasker.addAck(
            DeviceCommands.getAckCmd(
              packetType,
              DeviceCommands.ACK_STATUS_OK,
              receivedPacket.identifier,
            ),
          );
          break;
        case DeviceCommands.CMD_OPCODE_TECHNICAL_STATUS_REPORT:
          Log.info("packet received (TECHNICAL_STATUS_REPORT)");
          // tech-status-report packet received
          // TODO implement
//          broadcastTechStatusReceived(
//            receivedPacket.extractTechStatusPayload(),
//          );
          // send tech-status-report packet ACK
          _commandTasker.addAck(
            DeviceCommands.getAckCmd(
              packetType,
              DeviceCommands.ACK_STATUS_OK,
              receivedPacket.identifier,
            ),
          );
          break;
        case DeviceCommands.CMD_OPCODE_BIT_RES:
          Log.info(
              "packet received (BIT_RES): ${ConvertFormats.bytesToHex(receivedPacket.bytes)}");
          // TODO implement

          // bit-response packet received
//          broadcastBitResponseReceived(receivedPacket.extractBitResponse());
          // send bit-response packet ACK
          _commandTasker.addAck(
            DeviceCommands.getAckCmd(
              packetType,
              DeviceCommands.ACK_STATUS_OK,
              receivedPacket.identifier,
            ),
          );
          break;
        case DeviceCommands.CMD_OPCODE_ERROR_STATUS:
          Log.info("packet received (ERROR_STATUS)");
          _manageError(receivedPacket.extractSingleBytePayload());
          _commandTasker.addAck(DeviceCommands.getAckCmd(
              packetType, DeviceCommands.ACK_STATUS_OK, receivedPacket.identifier));
          break;
        case DeviceCommands.CMD_OPCODE_END_OF_TEST_DATA:
          Log.info("packet received (END_OF_TEST_DATA)");
          // end-of-test-data packet received
          _systemStateBloc.setTestState(TestStates.ENDED);
          _systemStateBloc.setDataTransferState(DataTransferStates.UPLOADING_TO_SERVER);
          _commandTasker.addAck(DeviceCommands.getAckCmd(
              packetType, DeviceCommands.ACK_STATUS_OK, receivedPacket.identifier));
          break;
        case DeviceCommands.CMD_OPCODE_FW_UPGRADE_RES:
          Log.info("packet received (FW_UPGRADE_RES)");
          // fw-response packet received
          // TODO implement getFirmwareUpgrader
//          getFirmwareUpgrader().responseReceived();
//          _commandTasker.addAck(DeviceCommands.getAckCmd(
//              packetType, DeviceCommands.ACK_STATUS_OK, receivedPacket.identifier));
          break;
        case DeviceCommands.CMD_OPCODE_AFE_REGISTERS_VALUES:
          Log.info("packet received (AFE_REGISTERS_VALUES)");
          _commandTasker.addAck(DeviceCommands.getAckCmd(
              packetType, DeviceCommands.ACK_STATUS_OK, receivedPacket.identifier));
          break;
        case DeviceCommands.CMD_OPCODE_ACTIGRAPH_REGISTERS_VALUES:
          Log.info("packet received (ACTIGRAPH_REGISTERS_VALUES)");
          _commandTasker.addAck(DeviceCommands.getAckCmd(
              packetType, DeviceCommands.ACK_STATUS_OK, receivedPacket.identifier));
          break;
        case DeviceCommands.CMD_OPCODE_GET_LOG_FILE_RESPONSE:
          Log.info("packet received (LOG_FILE_RESPONSE): " +
              ConvertFormats.bytesToHex(receivedPacket.bytes));
          final int payloadSize = receivedPacket.extractLogFileSize();
          Log.info(">> log chunk size: $payloadSize");
          // todo implement write to file
//          _logFileByteStream.write(
//              receivedPacket.extractParameterFilePayload(), 0, payloadSize);
//          if (payloadSize < ServiceActivity.LOG_FILE_DATA_CHUNK) {
//            Log.info(">> log EOF!");
//            getParameterFileHandler().getLogFileResponse(false);
//            _logFileByteStream.reset();
//          } else {
//            getParameterFileHandler().getLogFileResponse(true);
//          }
          _commandTasker.addAck(DeviceCommands.getAckCmd(
              packetType, DeviceCommands.ACK_STATUS_OK, receivedPacket.identifier));
          break;
        case DeviceCommands.CMD_OPCODE_PARAMETERS_FILE:
          Log.info(
              "packet received (PARAMETERS_FILE): ${ConvertFormats.bytesToHex(receivedPacket.bytes)}");
          final int payloadSize = receivedPacket.extractParamFileSize();
          // todo implement
//          _paramFileByteStream.write(
//              receivedPacket.extractParameterFilePayload(), 0, payloadSize);
//          if (payloadSize < ServiceActivity.PARAM_FILE_DATA_CHUNK) {
//            Log.info(">> param EOF!");
//            getParameterFileHandler().getParamFileResponse(false);
//
//            _paramFileByteStream.reset();
//          } else {
//            getParameterFileHandler().getParamFileResponse(true);
//          }
          _commandTasker.addAck(DeviceCommands.getAckCmd(
              packetType, DeviceCommands.ACK_STATUS_OK, receivedPacket.identifier));
          break;
        case DeviceCommands.CMD_OPCODE_UPAT_EEPROM_VALUES:
          Log.info("packet received (UPAT_EEPROM_VALUES)");

          _commandTasker.addAck(DeviceCommands.getAckCmd(
              packetType, DeviceCommands.ACK_STATUS_OK, receivedPacket.identifier));
          break;
        default:
          break;
      }

      resetPacket();
    }
  }

  void _recordPacket() {
    if (_incomingPacketLength >= DeviceCommands.PACKET_CHUNK_SIZE) {
      // todo implement

//      _receivedByteStream.write(_incomingData, 0, DeviceCommands.PACKET_CHUNK_SIZE);
      _incomingPacketLength -= DeviceCommands.PACKET_CHUNK_SIZE;
    } else {
      // todo implement

//      _receivedByteStream.write(_incomingData, 0, _incomingPacketLength);
      _incomingPacketLength = 0;
    }

    if (_incomingPacketLength == 0) {
      _packetState = PacketState.PACKET_COMPLETE;
    }
  }

  void resetPacket() {
    // todo implement

//    _receivedByteStream.reset();
    _incomingPacketLength = 0;
    _packetState = PacketState.WAITING_FOR_NEW;
  }

  bool _isValidSignature() {
    final int signature = int.parse([
      _incomingData[ReceivedPacket.PACKET_SIGNATURE_STARTING_BYTE + 1],
      _incomingData[ReceivedPacket.PACKET_SIGNATURE_STARTING_BYTE]
    ].join());

    return signature == DeviceCommands.CMD_SIGNATURE_PACKET;
  }

  bool _setPacketSize() {
    List<int> bytes = new List(4);
    bytes[0] = _incomingData[ReceivedPacket.PACKET_SIZE_STARTING_BYTE];
    bytes[1] = _incomingData[ReceivedPacket.PACKET_SIZE_STARTING_BYTE + 1];
    _incomingPacketLength = int.parse(bytes.join());
    return _incomingPacketLength >= 0;
  }

  bool _checkStartSessionErrors(final int opcodeDependant) {
    Log.info(">>> opcodeDependant: $opcodeDependant");

    if (PrefsProvider.getIgnoreDeviceErrors()) {
      Log.info(">>> device errors ignored");
      _systemStateBloc.setDeviceErrorState(DeviceErrorStates.NO_ERROR);
      return true;
    }

    if (opcodeDependant == 0) {
      Log.info("start session error: No error");
      _systemStateBloc.setDeviceErrorState(DeviceErrorStates.NO_ERROR);
      return true;
    }

    String errorString = "Device errors:\n";
    DeviceErrorStates errorState;

    if ((opcodeDependant & _PATIENT_ERROR_DEVICE_USED) != 0) {
      Log.info(">>> Used device");
      errorState = DeviceErrorStates.USED_DEVICE;
      errorString += '- ${lang.err_used_device}\n';
    } else {
      Log.info(">>> Used NOT device");
    }
    if ((opcodeDependant & _PATIENT_ERROR_BATTERY_VOLTAGE_TEST) != 0) {
      errorState = DeviceErrorStates.CHANGE_BATTERY;
      errorString += '- ${lang.err_battery_low}\n';
    }
    if ((opcodeDependant & _PATIENT_ERROR_ACTIGRAPH_TEST) != 0) {
      errorState = DeviceErrorStates.HW_ERROR;
      errorString += '- ${lang.err_actigraph_test}\n';
    }
    if ((opcodeDependant & _PATIENT_ERROR_FLASH_TEST) != 0) {
      errorState = DeviceErrorStates.HW_ERROR;
      errorString += '- ${lang.err_flash_test}\n';
    }
    if ((opcodeDependant & _PATIENT_ERROR_PROBE_LEDS_TEST) != 0) {
      errorState = DeviceErrorStates.HW_ERROR;
      errorString += '- ${lang.err_probe_leds}\n';
    }
    if ((opcodeDependant & _PATIENT_ERROR_PROBE_PHOTO_TEST) != 0) {
      errorState = DeviceErrorStates.HW_ERROR;
      errorString += '- ${lang.err_probe_photo}\n';
    }
    if ((opcodeDependant & _PATIENT_ERROR_SBP_TEST) != 0) {
      errorState = DeviceErrorStates.HW_ERROR;
      errorString += '- ${lang.err_sbp}\n';
    }

    _systemStateBloc.setDeviceErrorState(errorState, errors: errorString.toString());
    return false;
  }

  void _manageError(final int errorCode) {
    if (PrefsProvider.getIgnoreDeviceErrors()) {
      Log.info(">>> ignoring device errors");
      _systemStateBloc.setDeviceErrorState(DeviceErrorStates.NO_ERROR);
      return;
    }

    switch (errorCode) {
      case DeviceCommands.ERROR_BATTERY_LOW:
        _systemStateBloc.setDeviceErrorState(DeviceErrorStates.CHANGE_BATTERY);
        Log.info(lang.low_power);
        break;

      case DeviceCommands.ERROR_FLASH_FULL:
        Log.info(lang.flash_full);
      // for future use: do something
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }
}

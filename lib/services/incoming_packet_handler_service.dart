import 'package:my_pat/domain_model/device_commands.dart';
import 'package:my_pat/generated/i18n.dart';
import 'package:my_pat/managers/managers.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/managers/manager_base.dart';
import 'package:my_pat/utils/log/log.dart';
import 'package:my_pat/utils/time_utils.dart';
import 'package:my_pat/utils/convert_formats.dart';
import 'package:my_pat/services/prefs_service.dart';
import 'package:my_pat/domain_model/received_packet.dart';
import 'package:stack_trace/stack_trace.dart';

enum PacketState { WAITING_FOR_NEW, HANDLING_PACKET, PACKET_COMPLETE }

class IncomingPacketHandlerService extends ManagerBase {
  S lang;

  String get tag => Trace.from(StackTrace.current).terse.toString();

  IncomingPacketHandlerService() {
    lang = sl<S>();
    _incomingPacketLength = 0;
    _receivedByteStream = [];
    _paramFileByteStream = [];
    _logFileByteStream = [];
    _dataReceivedTimer =
        WatchPATTimer('DataReceivedTimeout', 3000, () => _isDataReceiving = false);
    _packetAnalysisTimer = WatchPATTimer('PacketAnalysisTimer', 60 * 1000, () {
      _isPacketAnalysis = false;
      Log.info(
          '>>>>>>>>>>>> PACKET ANALYSIS END.\n\n @@@packets received: $_packetAnalyzed, \n@@@bytes received: $_bytesAnalyzed');
    });
    _testStartTimer = WatchPATTimer('TestStartTimeout', 60 * 1000, () {
      Log.info(">>>>>>>>>>>> STARTING PACKET ANALYSIS ,$tag");
      _packetAnalysisTimer.startTimer();
      _isPacketAnalysis = true;
    });

    _packetAnalyzed = 0;
    _bytesAnalyzed = 0;
    _isPacketAnalysis = false;
  }

  static const int _PATIENT_ERROR_BATTERY_VOLTAGE_TEST = 0x2b;
  static const int _PATIENT_ERROR_ACTIGRAPH_TEST = 0x28;
  static const int _PATIENT_ERROR_DEVICE_USED = 0x49;
  static const int _PATIENT_ERROR_FLASH_TEST = 0x2c;
  static const int _PATIENT_ERROR_PROBE_LEDS_TEST = 0x0080;
  static const int _PATIENT_ERROR_PROBE_PHOTO_TEST = 0x0100;
  static const int _PATIENT_ERROR_SBP_TEST = 0x14;
  static const int _PATIENT_ERROR_NO_FINGER = 0x15;

  static PacketState _packetState = PacketState.WAITING_FOR_NEW;

  WatchPATTimer _dataReceivedTimer;
  WatchPATTimer _testStartTimer;
  WatchPATTimer _packetAnalysisTimer;

  List<int> _receivedByteStream = [];
  List<int> _paramFileByteStream = [];
  List<int> _logFileByteStream = [];

  List<int> _incomingData;
  int _incomingPacketLength = 0;
  bool _isPacketAnalysis;
  int _packetAnalyzed;
  int _bytesAnalyzed;

  bool _isFirstPacketOfDataReceived = false;
  bool _isDataReceiving = false;

  void startPacketAnalysis() {
    _testStartTimer.startTimer();
  }

  bool isDataReceiving() {
    return _isDataReceiving;
  }

  void acceptAndHandleData(List<int> data) {
    print('acceptAndHandleData $_packetState');
    _incomingData = data;

    if (_packetState == PacketState.WAITING_FOR_NEW) {
      // starting to receive a new packet
      Log.info("Handling new packet $tag, $_packetState");
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
    } else {
      Log.info("Handling continue of packet");
    }

    _recordPacket();

    if (_packetState == PacketState.PACKET_COMPLETE) {
      // packet is fully received
      ReceivedPacket receivedPacket =
          ReceivedPacket(_receivedByteStream, sl<CommandTaskerManager>());
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
          sl<CommandTaskerManager>().ackCommandReceived(receivedPacket.identifier);
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
          sl<CommandTaskerManager>().addAck(DeviceCommands.getAckCmd(
              packetType, DeviceCommands.ACK_STATUS_OK, receivedPacket.identifier));
          break;
        case DeviceCommands.CMD_OPCODE_START_SESSION_CONFIRM:
          Log.info("### start session confirm received");
          Log.info("packet received (START_SESSION_CONFIRM)");
          // start-session-confirm packet received
          // retrieve device configuration
          sl<DeviceConfigManager>()
              .setDeviceConfiguration(receivedPacket.extractConfigBlock());
          Log.info("### start session confirm: device configuration set");
          if (_checkStartSessionErrors(receivedPacket.opCodeDependent)) {
            PrefsProvider.saveDeviceSerial(
                sl<DeviceConfigManager>().deviceConfig.deviceSerial);
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
          sl<CommandTaskerManager>().addAck(DeviceCommands.getAckCmd(
              packetType, DeviceCommands.ACK_STATUS_OK, receivedPacket.identifier));
          final String deviceName =
              "ITAMAR_${sl<DeviceConfigManager>().deviceConfig.deviceHexSerial}";
          Log.info("device new name: $deviceName");
          PrefsProvider.saveDeviceName(deviceName);
          Log.info("### start session confirm: END");
          break;
        case DeviceCommands.CMD_OPCODE_CONFIG_RESPONSE:
          Log.info("packet received (CONFIG_RESPONSE)");
          sl<DeviceConfigManager>()
              .setDeviceConfiguration(receivedPacket.extractConfigBlock());
          PrefsProvider.saveDeviceSerial(
              sl<DeviceConfigManager>().deviceConfig.deviceSerial);
          sl<CommandTaskerManager>().addAck(
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
          sl<CommandTaskerManager>().addAck(
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
          sl<CommandTaskerManager>().addAck(
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
          sl<CommandTaskerManager>().addAck(DeviceCommands.getAckCmd(
              packetType, DeviceCommands.ACK_STATUS_OK, receivedPacket.identifier));
          break;
        case DeviceCommands.CMD_OPCODE_END_OF_TEST_DATA:
          Log.info("packet received (END_OF_TEST_DATA)");
          // end-of-test-data packet received
          sl<SystemStateManager>().setTestState(TestStates.ENDED);
          sl<SystemStateManager>()
              .setDataTransferState(DataTransferStates.UPLOADING_TO_SERVER);
          sl<CommandTaskerManager>().addAck(DeviceCommands.getAckCmd(
              packetType, DeviceCommands.ACK_STATUS_OK, receivedPacket.identifier));
          break;
        case DeviceCommands.CMD_OPCODE_FW_UPGRADE_RES:
          Log.info("packet received (FW_UPGRADE_RES)");
          // fw-response packet received
          // TODO implement getFirmwareUpgrader
//          getFirmwareUpgrader().responseReceived();
//          sl<CommandTaskerManager>().addAck(DeviceCommands.getAckCmd(
//              packetType, DeviceCommands.ACK_STATUS_OK, receivedPacket.identifier));
          break;
        case DeviceCommands.CMD_OPCODE_AFE_REGISTERS_VALUES:
          Log.info("packet received (AFE_REGISTERS_VALUES)");
          sl<CommandTaskerManager>().addAck(DeviceCommands.getAckCmd(
              packetType, DeviceCommands.ACK_STATUS_OK, receivedPacket.identifier));
          break;
        case DeviceCommands.CMD_OPCODE_ACTIGRAPH_REGISTERS_VALUES:
          Log.info("packet received (ACTIGRAPH_REGISTERS_VALUES)");
          sl<CommandTaskerManager>().addAck(DeviceCommands.getAckCmd(
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
          sl<CommandTaskerManager>().addAck(DeviceCommands.getAckCmd(
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
          sl<CommandTaskerManager>().addAck(DeviceCommands.getAckCmd(
              packetType, DeviceCommands.ACK_STATUS_OK, receivedPacket.identifier));
          break;
        case DeviceCommands.CMD_OPCODE_UPAT_EEPROM_VALUES:
          Log.info("packet received (UPAT_EEPROM_VALUES)");

          sl<CommandTaskerManager>().addAck(DeviceCommands.getAckCmd(
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
      print('_recordPacket $_incomingData');
      _receivedByteStream.addAll(_incomingData);
//      _receivedByteStream.write(_incomingData, 0, DeviceCommands.PACKET_CHUNK_SIZE);
      _incomingPacketLength -= _incomingData.length;
    } else {
      print('_recordPacket_2 $_incomingData');
      _receivedByteStream.addAll(_incomingData.sublist(0, _incomingPacketLength));
      _incomingPacketLength = 0;
    }

    if (_incomingPacketLength == 0) {
      print('_recordPacket_2 PacketState.PACKET_COMPLETE');

      _packetState = PacketState.PACKET_COMPLETE;
    }
  }

  void resetPacket() {
    print('resetPacket');
    _receivedByteStream.clear();
    _incomingPacketLength = 0;
    _packetState = PacketState.WAITING_FOR_NEW;
  }

  bool _isValidSignature() {
    final int signature = ConvertFormats.byteArrayToHex([
      _incomingData[ReceivedPacket.PACKET_SIGNATURE_STARTING_BYTE + 1],
      _incomingData[ReceivedPacket.PACKET_SIGNATURE_STARTING_BYTE]
    ]);
    return signature == DeviceCommands.CMD_SIGNATURE_PACKET;
  }

  bool _setPacketSize() {
    List<int> bytes = new List(2);
    bytes[0] = _incomingData[ReceivedPacket.PACKET_SIZE_STARTING_BYTE];
    bytes[1] = _incomingData[ReceivedPacket.PACKET_SIZE_STARTING_BYTE + 1];
    _incomingPacketLength = ConvertFormats.byteArrayToHex([bytes[1], bytes[0]]);
    return _incomingPacketLength >= 0;
  }

  bool _checkStartSessionErrors(final int opcodeDependant) {
    Log.info(">>> opcodeDependant: $opcodeDependant");

    if (PrefsProvider.getIgnoreDeviceErrors() != null &&
        PrefsProvider.getIgnoreDeviceErrors()) {
      Log.info(">>> device errors ignored");
      sl<SystemStateManager>().setDeviceErrorState(DeviceErrorStates.NO_ERROR);
      return true;
    }

    if (opcodeDependant == 0) {
      Log.info("start session error: No error");
      sl<SystemStateManager>().setDeviceErrorState(DeviceErrorStates.NO_ERROR);
      return true;
    }

    String errorString = "Device errors:\n";
    DeviceErrorStates errorState;

    if ((opcodeDependant & _PATIENT_ERROR_DEVICE_USED) != 0) {
      Log.info(">>> Used device");
      errorState = DeviceErrorStates.USED_DEVICE;
      errorString += '- ${lang.err_used_device}\n';
    } else {
      Log.info(">>>  NOT Used device");
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

    sl<SystemStateManager>()
        .setDeviceErrorState(errorState, errors: errorString.toString());
    return false;
  }

  void _manageError(final int errorCode) {
    if (PrefsProvider.getIgnoreDeviceErrors() != null &&
        PrefsProvider.getIgnoreDeviceErrors()) {
      Log.info(">>> ignoring device errors");
      sl<SystemStateManager>().setDeviceErrorState(DeviceErrorStates.NO_ERROR);
      return;
    }

    switch (errorCode) {
      case DeviceCommands.ERROR_BATTERY_LOW:
        sl<SystemStateManager>().setDeviceErrorState(DeviceErrorStates.CHANGE_BATTERY);
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

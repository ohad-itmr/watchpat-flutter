import 'dart:io';

import 'package:my_pat/domain_model/device_commands.dart';
import 'package:my_pat/domain_model/dispatcher_response_models.dart';
import 'package:my_pat/domain_model/tech_status_payload.dart';
import 'package:my_pat/generated/i18n.dart';
import 'package:my_pat/managers/managers.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/managers/manager_base.dart';
import 'package:my_pat/utils/FirmwareUpgrader.dart';
import 'package:my_pat/utils/ParameterFileHandler.dart';
import 'package:my_pat/utils/log/log.dart';
import 'package:my_pat/utils/time_utils.dart';
import 'package:my_pat/utils/convert_formats.dart';
import 'package:my_pat/services/prefs_service.dart';
import 'package:my_pat/domain_model/received_packet.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stack_trace/stack_trace.dart';

enum PacketState { WAITING_FOR_NEW, HANDLING_PACKET, PACKET_COMPLETE }

class IncomingPacketHandlerService extends ManagerBase {
  static const String TAG = 'IncomingPacketHandlerService';

  S lang;

  String get tag => Trace.from(StackTrace.current).terse.toString();

  IncomingPacketHandlerService() {
    lang = sl<S>();
    _incomingPacketLength = 0;
    _receivedByteStream = [];
    _paramFileByteStream = [];
    _logFileByteStream = [];
//    _dataReceivedTimer = WatchPATTimer(
//        'DataReceivedTimeout', 3000, () => _isDataReceiving = false);
//    _packetAnalysisTimer = WatchPATTimer('PacketAnalysisTimer', 60 * 1000, () {
//      _isPacketAnalysis = false;
//      Log.info(TAG,
//          '>>>>>>>>>>>> PACKET ANALYSIS END.\n\n @@@packets received: $_packetAnalyzed, \n@@@bytes received: $_bytesAnalyzed');
//    });
//    _testStartTimer = WatchPATTimer('TestStartTimeout', 60 * 1000, () {
//      Log.info(TAG, ">>>>>>>>>>>> STARTING PACKET ANALYSIS ,$tag");
//      _packetAnalysisTimer.startTimer();
//      _isPacketAnalysis = true;
//    });

    _packetAnalyzed = 0;
    _bytesAnalyzed = 0;
    _isPacketAnalysis = false;
  }

  static const int _PATIENT_ERROR_BATTERY_VOLTAGE_TEST = 0x0001;
  static const int _PATIENT_ERROR_ACTIGRAPH_TEST = 0x0008;
  static const int _PATIENT_ERROR_DEVICE_USED = 0x0020;
  static const int _PATIENT_ERROR_FLASH_TEST = 0x0040;
  static const int _PATIENT_ERROR_PROBE_LEDS_TEST = 0x0080;
  static const int _PATIENT_ERROR_PROBE_PHOTO_TEST = 0x0100;
  static const int _PATIENT_ERROR_SBP_TEST = 0x0400;
  static const int _PATIENT_ERROR_NO_FINGER = 0x2000;

  static PacketState _packetState = PacketState.WAITING_FOR_NEW;

//  WatchPATTimer _dataReceivedTimer;
//  WatchPATTimer _testStartTimer;
//  WatchPATTimer _packetAnalysisTimer;

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
  String _errorString = "Device errors:\n\n";

  // SERVICE OPERATIONS RESULTS STREAM
  PublishSubject<int> _bitResponse = PublishSubject<int>();
  PublishSubject<TechStatusPayload> _techStatusResponse = PublishSubject<TechStatusPayload>();

  Observable<int> get bitResponse => _bitResponse.stream;

  Observable<TechStatusPayload> get techStatusResponse => _techStatusResponse.stream;

  // Is paired response stream to show warning
  PublishSubject<bool> _isPairedResponse = PublishSubject<bool>();

  Observable<bool> get isPairedResponseStream => _isPairedResponse.stream;

  static int startAcquisitionCmdId;

  void startPacketAnalysis() {
//    _testStartTimer.startTimer();
  }

  void clearDeviceErrors() {
    _errorString = "Device errors:\n\n";
  }

  bool isDataReceiving() {
    return _isDataReceiving;
  }

  void acceptAndHandleData(List<int> data) async {
    _incomingData = data;

    if (_packetState == PacketState.WAITING_FOR_NEW) {
      // starting to receive a new packet
//      print("Handling new packet  $_packetState");
      _setPacketState(PacketState.HANDLING_PACKET);

      if (_isValidSignature()) {
        if (!_setPacketSize()) {
          Log.shout(TAG, "Wrong packet size " + ConvertFormats.bytesToHex(data));
          resetPacket();
          return;
        }
      } else {
        Log.shout(TAG, "Wrong starting packet " + ConvertFormats.bytesToHex(data));
        resetPacket();
        return;
      }
    } else {
//      Log.info(TAG, "Handling continue of packet");
    }

    _recordPacket();

    if (_packetState == PacketState.PACKET_COMPLETE) {
      // packet is fully received
      ReceivedPacket receivedPacket =
          ReceivedPacket(_receivedByteStream, sl<CommandTaskerManager>());
      ReceivedPacket(_receivedByteStream, sl<CommandTaskerManager>());
      final int packetType = receivedPacket.packetType;

      // packet validity check
      if (!receivedPacket.isValidPacket()) {
        resetPacket();
        return;
      }

      // system reaction to the packet
      switch (packetType) {
        case DeviceCommands.CMD_OPCODE_ACK:
          Log.info(TAG, "packet received (ACK)");
          // ACK received - notify cmdTasker

          if (startAcquisitionCmdId != null && startAcquisitionCmdId == receivedPacket.identifier) {
            _setTestStarted();
            startAcquisitionCmdId = null;
          }

          sl<CommandTaskerManager>().ackCommandReceived(receivedPacket.identifier);
          break;
        case DeviceCommands.CMD_OPCODE_DATA_PACKET:
//          Log.info(TAG, "packet received (DATA_PACKET)");
          // data packet received - store to local file
          _isDataReceiving = true;
//          _dataReceivedTimer.restart();

          if (_isPacketAnalysis) {
            _packetAnalyzed++;
            _bytesAnalyzed += receivedPacket.bytes.length;
          }

          // send data packet ACK
          sl<CommandTaskerManager>().addAck(DeviceCommands.getAckCmd(
              packetType, DeviceCommands.ACK_STATUS_OK, receivedPacket.identifier));

          if (!_isFirstPacketOfDataReceived) {
            _isFirstPacketOfDataReceived = true;

            _setTestStarted();
          }

          // set data transfer state
          sl<SystemStateManager>().setDataTransferState(DataTransferState.TRANSFERRING);

          final int prevRemoteIdentifier = PrefsProvider.loadRemotePacketIdentifier();
          if (prevRemoteIdentifier < receivedPacket.identifier) {
//            Log.info(
//                TAG, ">>> remote id: ${receivedPacket.identifier}, size: ${receivedPacket.size}");
            PrefsProvider.saveRemotePacketIdentifier(receivedPacket.identifier);
            TimeUtils.packetCounterTick();

            sl<DataWritingService>().writeToLocalFile(
                DataPacket(data: List.from(receivedPacket.bytes), id: receivedPacket.identifier));
          } else {
            Log.warning(TAG,
                "retransmission of same packet is detected. prevRemoteID: $prevRemoteIdentifier | receivedID: ${receivedPacket.identifier}");
          }

          break;
        case DeviceCommands.CMD_OPCODE_START_SESSION_CONFIRM:
          if (sl<SystemStateManager>().startSessionState == StartSessionState.CONFIRMED) break;
          Log.info(TAG, "### start session confirm received");
          Log.info(TAG, "packet received (START_SESSION_CONFIRM)");

          // Send ACK
          sl<CommandTaskerManager>().addAck(DeviceCommands.getAckCmd(
              packetType, DeviceCommands.ACK_STATUS_OK, receivedPacket.identifier));

          // set start session state to confirmed
          sl<SystemStateManager>().setStartSessionState(StartSessionState.CONFIRMED);

          // start-session-confirm packet received
          sl<DeviceConfigManager>().setDeviceConfiguration(receivedPacket.extractConfigBlock());

          Log.info(TAG, "### start session confirm: device configuration set");

          PrefsProvider.saveDeviceSerial(sl<DeviceConfigManager>().deviceConfig.deviceSerial);
          Log.info(TAG, "### start session confirm: device serial saved");

          // Send start session to dispatcher
          sl<DispatcherService>().sendStartSession(receivedPacket.opCodeDependent.toString());

          final bool sessionHasNoErrors = await _checkSessionErrors();
          final bool deviceHasNoErrors = _checkDeviceErrors(receivedPacket.opCodeDependent);

          if (sessionHasNoErrors && deviceHasNoErrors) {
            if (PrefsProvider.loadDeviceName() == null) {
              Log.info(TAG, "first connection to device");
              Log.info(TAG, "### start session confirm: device FW version check START");

              final bool isUpToDate =
                  await sl<FirmwareUpgrader>().isDeviceFirmwareVersionUpToDate();

              if (isUpToDate) {
                Log.info(TAG, "### start session confirm: device FW version check END");
                Log.info(TAG, "device FW up to date");
                sl<SystemStateManager>().setFirmwareState(FirmwareUpgradeState.UP_TO_DATE);
              } else {
                await Future.delayed(Duration(seconds: 1));
                Log.info(TAG, "device FW outdated");
                sl<FirmwareUpgrader>().upgradeDeviceFirmwareFromResources();
              }
            }
          }

          if (deviceHasNoErrors) {
            final String deviceName =
                "ITAMAR_${sl<DeviceConfigManager>().deviceConfig.deviceHexSerial.toUpperCase()}";
            Log.info(TAG, "device new name: $deviceName");
            PrefsProvider.saveDeviceName(deviceName);
          }

          Log.info(TAG, "### start session confirm: END");
          break;

        case DeviceCommands.CMD_OPCODE_CONFIG_RESPONSE:
          Log.info(TAG, "packet received (CONFIG_RESPONSE)");
          sl<DeviceConfigManager>().setDeviceConfiguration(receivedPacket.extractConfigBlock());

          PrefsProvider.saveDeviceSerial(sl<DeviceConfigManager>().deviceConfig.deviceSerial);

          sl<CommandTaskerManager>().addAck(
            DeviceCommands.getAckCmd(
              packetType,
              DeviceCommands.ACK_STATUS_OK,
              receivedPacket.identifier,
            ),
          );
          break;
        case DeviceCommands.CMD_OPCODE_TECHNICAL_STATUS_REPORT:
          Log.info(TAG, "packet received (TECHNICAL_STATUS_REPORT)");
          _techStatusResponse.sink.add(receivedPacket.extractTechStatusPayload());
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
              TAG, "packet received (BIT_RES): ${ConvertFormats.bytesToHex(receivedPacket.bytes)}");
          _bitResponse.sink.add(receivedPacket.extractBitResponse());

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
          Log.info(TAG, "packet received (ERROR_STATUS)");
          _manageError(receivedPacket.extractSingleBytePayload());
          sl<CommandTaskerManager>().addAck(DeviceCommands.getAckCmd(
              packetType, DeviceCommands.ACK_STATUS_OK, receivedPacket.identifier));
          break;

        case DeviceCommands.CMD_OPCODE_END_OF_TEST_DATA:
          Log.info(TAG, "packet received (END_OF_TEST_DATA)");

          sl<TestingManager>().forceEndTesting();

          sl<CommandTaskerManager>().addAck(DeviceCommands.getAckCmd(
              packetType, DeviceCommands.ACK_STATUS_OK, receivedPacket.identifier));

          // disconnect from device
//          await Future.delayed(Duration(seconds: 2));
//          sl<BleManager>().disconnection();

          break;
        case DeviceCommands.CMD_OPCODE_FW_UPGRADE_RES:
          Log.info(TAG, "packet received (FW_UPGRADE_RES)");

          // fw-response packet received
          sl<CommandTaskerManager>().addAck(DeviceCommands.getAckCmd(
              packetType, DeviceCommands.ACK_STATUS_OK, receivedPacket.identifier));

          await Future.delayed(Duration(milliseconds: 100));
          sl<FirmwareUpgrader>().responseReceived();

          break;
        case DeviceCommands.CMD_OPCODE_AFE_REGISTERS_VALUES:
          Log.info(TAG, "packet received (AFE_REGISTERS_VALUES)");

          // store received AFE file to documents folder
          File f = await sl<FileSystemService>().watchpatDirAFEFile;
          f.createSync();
          f.writeAsBytesSync(receivedPacket.bytes, mode: FileMode.write);

          sl<CommandTaskerManager>().addAck(DeviceCommands.getAckCmd(
              packetType, DeviceCommands.ACK_STATUS_OK, receivedPacket.identifier));
          break;
        case DeviceCommands.CMD_OPCODE_ACTIGRAPH_REGISTERS_VALUES:
          Log.info(TAG, "packet received (ACTIGRAPH_REGISTERS_VALUES)");

          // store received ACC file to documents folder
          File f = await sl<FileSystemService>().watchpatDirACCFile;
          f.createSync();
          f.writeAsBytesSync(receivedPacket.bytes, mode: FileMode.write);

          sl<CommandTaskerManager>().addAck(DeviceCommands.getAckCmd(
              packetType, DeviceCommands.ACK_STATUS_OK, receivedPacket.identifier));
          break;

        case DeviceCommands.CMD_OPCODE_GET_LOG_FILE_RESPONSE:
          Log.info(
              TAG,
              "packet received (LOG_FILE_RESPONSE): " +
                  ConvertFormats.bytesToHex(receivedPacket.bytes));
          final int payloadSize = receivedPacket.extractLogFileSize();
          print(">> log file chunk size: $payloadSize");
          File f = await sl<FileSystemService>().deviceLogFile;
          f.writeAsBytesSync(receivedPacket.extractParameterFilePayload(),
              mode: FileMode.append, flush: true);

          if (payloadSize < ParameterFileHandler.LOG_FILE_DATA_CHUNK) {
            Log.info(TAG, ">> log EOF!");
            sl<ParameterFileHandler>().getLogFileResponse(false);
          } else {
            sl<ParameterFileHandler>().getLogFileResponse(true);
          }
          sl<CommandTaskerManager>().addAck(DeviceCommands.getAckCmd(
              packetType, DeviceCommands.ACK_STATUS_OK, receivedPacket.identifier));
          break;
        case DeviceCommands.CMD_OPCODE_PARAMETERS_FILE:
          Log.info(TAG, "packet received (PARAMETERS_FILE)");

          final int payloadSize = receivedPacket.extractParamFileSize();
          print(">> parameters file chunk size: $payloadSize");
          final List<int> payload = receivedPacket.extractParameterFilePayload();

          File f = await sl<FileSystemService>().watchpatDirParametersFile;
          f.writeAsBytesSync(payload, mode: FileMode.append, flush: true);
          if (payloadSize < ParameterFileHandler.PARAM_FILE_DATA_CHUNK) {
            Log.info(TAG, ">> param EOF!");
            sl<ParameterFileHandler>().getParamFileResponse(false);
          } else {
            sl<ParameterFileHandler>().getParamFileResponse(true);
          }
          sl<CommandTaskerManager>().addAck(DeviceCommands.getAckCmd(
              packetType, DeviceCommands.ACK_STATUS_OK, receivedPacket.identifier));
          break;
        case DeviceCommands.CMD_OPCODE_UPAT_EEPROM_VALUES:
          Log.info(TAG, "packet received (UPAT_EEPROM_VALUES)");

          sl<CommandTaskerManager>().addAck(DeviceCommands.getAckCmd(
              packetType, DeviceCommands.ACK_STATUS_OK, receivedPacket.identifier));
          break;
        case DeviceCommands.CMD_OPCODE_IS_DEVICE_PAIRED_RES:
          Log.info(TAG, "packet received (IS_DEVICE_PAIRED)");
          Log.info(TAG, ">>> opCodeDependent: ${receivedPacket.opCodeDependent}");

          bool isPaired;

          //
          if (!sl<SystemStateManager>().isTestActive) {
            if (PrefsProvider.loadDeviceName() == null) {
              // fresh pairing - no saved device serial
              if (receivedPacket.opCodeDependent == 0) {
                // device response - not paired device
                Log.info(TAG, ">>> fresh pairing / unpaired device");
                isPaired = false;
                sl<SystemStateManager>().setAppMode(AppModes.USER);
                sl<SystemStateManager>().changeState.add(StateChangeActions.APP_MODE_CHANGED);
              } else {
                // device response - already paired device
                Log.info(TAG, ">>> fresh pairing / paired device - ERROR");
                isPaired = true;
              }
            } else {
              // reconnection pairing - saved device serial located
              if (receivedPacket.opCodeDependent == 0) {
                // device response - not paired device
                Log.info(TAG, ">>> reconnection pairing / 'N' in name / unpaired device");
                isPaired = false;
                sl<SystemStateManager>().setAppMode(AppModes.USER);
                sl<SystemStateManager>().changeState.add(StateChangeActions.APP_MODE_CHANGED);
              } else {
                // device response - already paired device
                Log.info(TAG, ">>> reconnection pairing / 'N' in name / paired device - ERROR");
                isPaired = true;
              }
            }
          } else {
            // test in progress/ended
            if (receivedPacket.opCodeDependent == 0) {
              // device response - not paired device
              isPaired = false;
              sl<TestingManager>().forceEndTesting();
            } else {
              isPaired = true;
            }
          }

          sl<CommandTaskerManager>().addAck(DeviceCommands.getAckCmd(
              packetType, DeviceCommands.ACK_STATUS_OK, receivedPacket.identifier));

          _isPairedResponse.sink.add(isPaired);

          break;
        default:
          break;
      }

      resetPacket();
    }
  }

  void _recordPacket() {
    if (_incomingPacketLength >= DeviceCommands.PACKET_CHUNK_SIZE) {
      _receivedByteStream.addAll(_incomingData);
      _incomingPacketLength -= _incomingData.length;
    } else {
      _receivedByteStream.addAll(_incomingData.sublist(0, _incomingPacketLength));
      _incomingPacketLength = 0;
    }

    if (_incomingPacketLength == 0) {
      _setPacketState(PacketState.PACKET_COMPLETE);
    }
  }

  void resetPacket() {
//    print('resetPacket');
    _receivedByteStream.clear();
    _incomingPacketLength = 0;
    _setPacketState(PacketState.WAITING_FOR_NEW);
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
    _incomingPacketLength = ConvertFormats.twoBytesToInt(byte1: bytes[0], byte2: bytes[1]);
//    print('---------------------------> setPacketSize $_incomingPacketLength');

    return _incomingPacketLength >= 24 && _incomingPacketLength < 2500;
  }

  bool _checkDeviceErrors(final int opcodeDependant) {
    Log.info(TAG, ">>> opcodeDependant: $opcodeDependant");

    if (PrefsProvider.getIgnoreDeviceErrors()) {
      Log.info(TAG, ">>> device errors ignored");
      sl<SystemStateManager>().setDeviceErrorState(DeviceErrorStates.NO_ERROR);
      return true;
    }

    if (opcodeDependant == 0) {
      Log.info(TAG, "start session error: No error");
      sl<SystemStateManager>().setDeviceErrorState(DeviceErrorStates.NO_ERROR);
      return true;
    }

    DeviceErrorStates errorState;

    if ((opcodeDependant & _PATIENT_ERROR_DEVICE_USED) != 0) {
      Log.info(TAG, ">>> Used device");
      errorState = DeviceErrorStates.USED_DEVICE;
      _errorString += '- ${lang.err_used_device}\n';
    } else {
      Log.info(TAG, ">>>  NOT Used device");
    }

    if ((opcodeDependant & _PATIENT_ERROR_BATTERY_VOLTAGE_TEST) != 0) {
      errorState = DeviceErrorStates.CHANGE_BATTERY;
      _errorString += '- ${lang.err_battery_low}\n';
    }

    if ((opcodeDependant & _PATIENT_ERROR_ACTIGRAPH_TEST) != 0) {
      errorState = DeviceErrorStates.HW_ERROR;
      _errorString += '- ${lang.err_actigraph_test}\n';
    }
    if ((opcodeDependant & _PATIENT_ERROR_FLASH_TEST) != 0) {
      errorState = DeviceErrorStates.HW_ERROR;
      _errorString += '- ${lang.err_flash_test}\n';
    }
    if ((opcodeDependant & _PATIENT_ERROR_PROBE_LEDS_TEST) != 0) {
      errorState = DeviceErrorStates.HW_ERROR;
      _errorString += '- ${lang.err_probe_leds}\n';
    }
    if ((opcodeDependant & _PATIENT_ERROR_PROBE_PHOTO_TEST) != 0) {
      errorState = DeviceErrorStates.HW_ERROR;
      _errorString += '- ${lang.err_probe_photo}\n';
    }

//    IGNORING SPB ERROR
//    if ((opcodeDependant & _PATIENT_ERROR_SBP_TEST) != 0) {
//      errorState = DeviceErrorStates.HW_ERROR;
//      _errorString += '- ${lang.err_sbp}\n';
//    }
    if ((opcodeDependant & _PATIENT_ERROR_SBP_TEST) != 0) {
      if (errorState == DeviceErrorStates.UNKNOWN) {
        Log.info(TAG, "Device errors: only SPB error - ignoring");
        sl<SystemStateManager>().setDeviceErrorState(DeviceErrorStates.NO_ERROR);
        return true;
      } else {
        _errorString += '- ${lang.err_probe_photo}\n';
      }
    }

    sl<SystemStateManager>().setDeviceErrorState(errorState, errors: _errorString.toString());
    return false;
  }

  Future<bool> _checkSessionErrors() async {
    Log.info(TAG, "### Checking for session errors");
    String errors = "Session errors:\n\n";
    await sl<WelcomeActivityManager>().configFinished.firstWhere((done) => done);
    GeneralResponse res =
        await sl<DispatcherService>().getPatientPolicy(PrefsProvider.loadDeviceSerial());
    if (res.error) {
      if (res.message == DispatcherService.DISPATCHER_ERROR_STATUS) {
        errors += "- Connection to dispatcher failed";
        sl<SystemStateManager>()
            .setSessionErrorState(SessionErrorState.NO_DISPATCHER, errors: errors);
      } else if (res.message == DispatcherService.NO_PIN_RETRIES) {
        errors += "- Number of PIN retries exceeded";
        sl<SystemStateManager>().setSessionErrorState(SessionErrorState.PIN_ERROR, errors: errors);
      } else if (res.message == DispatcherService.SN_NOT_REGISTERED_ERROR_STATUS) {
        errors += "- Serial number of your device is not registered";
        sl<SystemStateManager>()
            .setSessionErrorState(SessionErrorState.SN_NOT_REGISTERED, errors: errors);
      } else {
        errors += "- Internal policy error: ${res.message}";
        sl<SystemStateManager>().setSessionErrorState(SessionErrorState.UNDEFINED, errors: errors);
      }
      return false;
    }
    sl<SystemStateManager>().setSessionErrorState(SessionErrorState.NO_ERROR);
    return true;
  }

  void _manageError(final int errorCode) {
    if (PrefsProvider.getIgnoreDeviceErrors()) {
      Log.info(TAG, ">>> ignoring device errors");
      sl<SystemStateManager>().setDeviceErrorState(DeviceErrorStates.NO_ERROR);
      return;
    }

    switch (errorCode) {
      case DeviceCommands.ERROR_BATTERY_LOW:
        sl<SystemStateManager>().setDeviceErrorState(DeviceErrorStates.CHANGE_BATTERY);
        Log.info(TAG, lang.low_power);
        break;

      case DeviceCommands.ERROR_FLASH_FULL:
        Log.info(TAG, lang.flash_full);
      // for future use: do something
    }
  }

  void _setTestStarted() {
    if (sl<SystemStateManager>().testState == TestStates.NOT_STARTED) {
      sl<SystemStateManager>().setTestState(TestStates.STARTED);
    } else if (sl<SystemStateManager>().testState == TestStates.INTERRUPTED) {
      sl<SystemStateManager>().setTestState(TestStates.RESUMED);
    }
    Log.info(TAG, "TEST STARTED / RESUMED");
  }

  @override
  void dispose() {
    _isPairedResponse.close();
    _bitResponse.close();
    _techStatusResponse.close();
  }

  void _setPacketState(PacketState state) {
    if (_packetState != state) {
//      print("Setting packet state to: ${state.toString()}");
      _packetState = state;
    }
  }
}

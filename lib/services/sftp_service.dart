import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:my_pat/config/default_settings.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/services/services.dart';
import 'package:my_pat/utils/log/log.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ssh/ssh.dart';
import 'package:path_provider/path_provider.dart';

enum SftpConnectionState { CONNECTED, DISCONNECTED }

class SftpService {
  static const String TAG = 'SftpService';

  // Services
  SystemStateManager _systemState = sl<SystemStateManager>();
  FileSystemService _fileSystem = sl<FileSystemService>();
  SSHClient _client;

  // Streams
  BehaviorSubject<SftpConnectionState> sftpConnectionStateStream =
      BehaviorSubject<SftpConnectionState>.seeded(
          SftpConnectionState.DISCONNECTED);

  // Working variables
  String _sftpFileName;
  String _sftpFilePath;
  File _dataFile;
  RandomAccessFile _raf;
  Directory _tempDir;
  int _dataChunkSize = DefaultSettings.uploadDataChunkMaxSize;
  bool _uploadingAvailable = false;
  TestStates _currentTestState;
  DataTransferStates _currentTransferState;
  int _reconnectionAttempts = 0;
  Timer _reconnectionTimer;

  SftpService() {
    _systemState = sl<SystemStateManager>();
    _fileSystem = sl<FileSystemService>();
    _systemState.testStateStream.listen(_handleTestState);
    _systemState.dispatcherStateStream.listen(_handleDispatcherState);
    _systemState.dataTransferStateStream.listen(_handleDataTransferState);

    _initConnectionAvailabilityListener();
  }

  void _initConnectionAvailabilityListener() {
    Observable.combineLatest2(
        _systemState.inetConnectionStateStream,
        sftpConnectionStateStream.stream,
        (ConnectivityResult inet, SftpConnectionState sftp) =>
            _uploadingAvailable = inet != ConnectivityResult.none &&
                sftp != SftpConnectionState.DISCONNECTED).listen(null);
  }

  _handleDispatcherState(DispatcherStates state) {
    switch (state) {
      case DispatcherStates.AUTHENTICATED:
        _initService();
        break;
      default:
    }
  }

  _handleTestState(TestStates state) async {
    _currentTestState = state;
    switch (state) {
      case TestStates.STARTED:
        _systemState.setDataTransferState(DataTransferStates.TRANSFERRING);
        _awaitForData();
        break;
      case TestStates.RESUMED:
        await _initService();
        _restoreUploading();
        break;
      default:
    }
  }

  _handleDataTransferState(DataTransferStates state) {
    _currentTransferState = state;
    if (state == DataTransferStates.ALL_TRANSFERRED) _closeConnection();
  }

  Future<void> _initService() async {
    Log.info(TAG, "Initializing SFTP service");

    UserAuthenticationService _authService = sl<UserAuthenticationService>();
    _client = SSHClient(
        host: _authService.sftpHost,
        port: _authService.sftpPort,
        username: _authService.sftpUserName,
        passwordOrKey: _authService.sftpPassword);

    if (_currentTestState != TestStates.RESUMED) {
      await PrefsProvider.saveTestDataUploadingOffset(0);
    }

    _sftpFilePath = _authService.sftPath;
    _sftpFileName = DefaultSettings.serverDataFileName;
    _tempDir = await getTemporaryDirectory();

    _dataFile = await _fileSystem.localDataFile;
    _raf = await _dataFile.open(mode: FileMode.read);

    await _initSftpConnection();
  }

  Future<void> _initSftpConnection() async {
    try {
      Log.info(TAG, "Connecting to SFTP server");
      final resultSession = await _client.connect();
      final resultConnection = await _client.connectSFTP();
      Log.info(
          TAG, "Connected to SFTP server: $resultSession, $resultConnection");
      sftpConnectionStateStream.sink.add(SftpConnectionState.CONNECTED);
    } catch (e) {
      Log.shout(TAG, "Connection to SFTP failed, $e");
      _tryToReconnect(error: e.toString());
    }
  }

  void _tryToReconnect({@required String error}) async {
    _reconnectionAttempts++;
    if (_reconnectionAttempts > 3) {
      _reconnectionAttempts = 0;
      sl<EmailSenderService>().sendSftpFailureEmail(error: error);
      _startReconnectionTimer();
      return;
    } else {
      await Future.delayed(Duration(seconds: 3));
      Log.shout(TAG,
          "Trying to reconnect to SFTP server, attempt: $_reconnectionAttempts");
      _initSftpConnection();
    }
  }

  void _startReconnectionTimer() {
    Log.shout(TAG,
        "Starting SFTP reconnection timer, the next attemps will be made in 1 hour");
    _reconnectionTimer = Timer(Duration(hours: 1), () => _initSftpConnection());
  }

  void _awaitForData() async {
    do {
      // Check for connections, if none start waiting
      if (!_uploadingAvailable) {
        sl<SystemStateManager>()
            .setDataTransferState(DataTransferStates.WAITING_FOR_DATA);
        await _awaitForConnection();
      }

      final int currentRecordingOffset =
          PrefsProvider.loadTestDataRecordingOffset();
      final int currentUploadingOffset =
          PrefsProvider.loadTestDataUploadingOffset();

      if (currentUploadingOffset < currentRecordingOffset) {
        _systemState.setDataTransferState(DataTransferStates.TRANSFERRING);
        await _uploadDataChunk(
            uploadingOffset: currentUploadingOffset,
            recordingOffset: currentRecordingOffset);

        // Check if test ended and all data is uploaded
        final int newUploadingOffset = PrefsProvider.loadTestDataUploadingOffset();
        if (currentRecordingOffset == newUploadingOffset &&
            _currentTestState == TestStates.ENDED) {
          _currentTransferState = DataTransferStates.ALL_TRANSFERRED;
          _systemState.setDataTransferState(DataTransferStates.ALL_TRANSFERRED);
        }
      } else {
        _systemState.setDataTransferState(DataTransferStates.WAITING_FOR_DATA);
        Log.info(TAG,
            "Waiting for data: UPLOADING OFFSET: $currentUploadingOffset, RECORDING OFFSET: $currentRecordingOffset");
        await Future.delayed(Duration(seconds: 3));
      }
    } while (_currentTransferState != DataTransferStates.ALL_TRANSFERRED);
  }

  Future<void> _awaitForConnection() async {
    do {
      Log.info(TAG, "Waiting for connection");
      await Future.delayed(Duration(seconds: 3));
    } while (_uploadingAvailable);
  }

  Future<void> _uploadDataChunk({
    @required int uploadingOffset,
    @required int recordingOffset,
  }) async {

    RandomAccessFile rafWithOffset = await _raf.setPosition(uploadingOffset);
    final int lengthToRead = recordingOffset - uploadingOffset > _dataChunkSize
        ? _dataChunkSize
        : recordingOffset - uploadingOffset;

    List<int> bytes = await rafWithOffset.read(lengthToRead);

    final File tempFile = File("${_tempDir.path}/$_sftpFileName");
    await tempFile.writeAsBytes(bytes);

    try {
      final String result = await _client.sftpAppendToFile(
          fromFilePath: tempFile.path,
          toFilePath: '$_sftpFilePath/$_sftpFileName');

      if (result == SftpService.APPENDING_SUCCESS) {

        await PrefsProvider.saveTestDataUploadingOffset(
            uploadingOffset + bytes.length);
        Log.info(TAG,
            "Uploaded chunk to SFTP. Current uploading offset: ${PrefsProvider.loadTestDataUploadingOffset()}, current recording offset: $recordingOffset");

        // todo test sftp offset
        SFTPFile file = await _client.sftpFileInfo(filePath: "$_sftpFilePath/$_sftpFileName");
        print("CURRENT UPLOADING OFFSET: ${PrefsProvider.loadTestDataUploadingOffset()}");
        print("CURRENT REMOTE FILE SIZE: ${file.size}");
        //

      }
    } catch (e) {
      Log.shout(TAG, "Uploading to SFTP Failed: $e");
      sl<SystemStateManager>()
          .setDataTransferState(DataTransferStates.WAITING_FOR_DATA);
      await Future.delayed(Duration(seconds: 3));
    }
  }

  void _restoreUploading() async {
    final SFTPFile remoteFile =
        await _client.sftpFileInfo(filePath: "$_sftpFilePath/$_sftpFileName");
    await PrefsProvider.saveTestDataUploadingOffset(remoteFile.size);
    _awaitForData();
  }

  void _closeConnection() {
    Log.info(TAG,
        "Uploading of test data complete, closing sftp connection and informing dispatcher");
    sl<DispatcherService>().sendTestComplete(PrefsProvider.loadDeviceSerial());
    sftpConnectionStateStream.close();
  }

  static const String APPENDING_SUCCESS = "appending_success";
}

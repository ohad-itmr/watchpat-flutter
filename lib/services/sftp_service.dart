import 'dart:async';
import 'dart:io';

import 'package:background_fetch/background_fetch.dart';
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
      BehaviorSubject<SftpConnectionState>.seeded(SftpConnectionState.DISCONNECTED);

  String _sftpFileName;
  String _sftpFilePath;
  File _dataFile;
  RandomAccessFile _raf;
  Directory _tempDir;
  int _dataChunkSize = DefaultSettings.uploadDataChunkMaxSize;
  bool _uploadingAvailable = false;
  SftpUploadingState _currentUploadingState;
  DataTransferState _currentDataTransferState;
  int _reconnectionAttempts = 0;
  Timer _reconnectionTimer;

  bool _serviceInitialized = false;
  bool _connectionInProgress = false;

  SftpService() {
    _systemState = sl<SystemStateManager>();
    _fileSystem = sl<FileSystemService>();
    _systemState.dataTransferStateStream.listen(_handleDataTransferState);
    _systemState.sftpUploadingStateStream.listen(_handleSftpUploadingState);

    _initConnectionAvailabilityListener();
  }

  bool _resetInProgress = false;

  void resetSFTPService() {
    if (_resetInProgress) return;
    _resetInProgress = true;
    Log.info(TAG, "Stopping SFTP service");
    sftpConnectionStateStream.sink.add(SftpConnectionState.DISCONNECTED);
    _reconnectionAttempts = 0;
    _serviceInitialized = false;
    _resetInProgress = false;
    BackgroundFetch.finish();
    Log.info(TAG, "SFTP service stopped");
  }

  void _initConnectionAvailabilityListener() {
    Observable.combineLatest2(
            _systemState.inetConnectionStateStream,
            sftpConnectionStateStream.stream,
            (ConnectivityResult inet, SftpConnectionState sftp) => _uploadingAvailable =
                inet != ConnectivityResult.none && sftp != SftpConnectionState.DISCONNECTED)
        .listen(null);
  }

  _handleDataTransferState(DataTransferState state) {
    _currentDataTransferState = state;
    if (state == DataTransferState.TRANSFERRING && !_serviceInitialized) {
      initService();
      PrefsProvider.setDataUploadingIncomplete(value: true);
    } else if (state == DataTransferState.ENDED && !_serviceInitialized) {
      PrefsProvider.setDataUploadingIncomplete(value: true);
      initService();
    }
  }

  _handleSftpUploadingState(SftpUploadingState state) async {
    _currentUploadingState = state;
    if (state == SftpUploadingState.ALL_UPLOADED) {
      Log.info(TAG, "SFTP uploading complete, closing sftp connection and informing dispatcher");
      PrefsProvider.setDataUploadingIncomplete(value: false);
      await _checkRemoteFileSize();
      resetSFTPService();
      await _informDispatcher();
      await sl<EmailSenderService>().sendLogsArchive();
      await sl<ServiceScreenManager>().resetApplication(clearConfig: false, killApp: false);
      await BackgroundFetch.stop();
      TransactionManager.platformChannel.invokeMethod("backgroundSftpUploadingFinished");
      BackgroundFetch.finish();
    }
  }

  Future<void> initService() async {
    if (_serviceInitialized) {
      Log.info(TAG, "SFTP service already initialized");
      return;
    }
    _serviceInitialized = true;
    Log.info(TAG, "Initializing SFTP service");

    _client = SSHClient(
        host: PrefsProvider.loadSftpHost(),
        port: PrefsProvider.loadSftpPort(),
        username: PrefsProvider.loadSftpUsername(),
        passwordOrKey: PrefsProvider.loadSftpPassword());

    _sftpFilePath = PrefsProvider.loadSftpPath();
    _sftpFileName = DefaultSettings.serverDataFileName;
    _tempDir = await getTemporaryDirectory();

    _dataFile = await _fileSystem.localDataFile;
    _raf = await _dataFile.open(mode: FileMode.read);

    if (sl<SystemStateManager>().inetConnectionState == ConnectivityResult.none) {
      await Future.delayed(Duration(seconds: 5));
      if (sl<SystemStateManager>().inetConnectionState == ConnectivityResult.none) {
        Log.shout(TAG, "No internet connection, SFTP service could not be initalized");
        _serviceInitialized = false;
        return;
      }
    }

    await _initSftpConnection();

    // set up or restore uploading offset
    if (sl<SystemStateManager>().testState == TestStates.STARTED) {
      await PrefsProvider.saveTestDataUploadingOffset(0);
    } else {
      await _restoreUploadingOffset();
    }

    _awaitForData();
  }

  Future<void> _initSftpConnection() async {
    try {
      if (_connectionInProgress || !_serviceInitialized) return;
      _connectionInProgress = true;
      Log.info(TAG, "Connecting to SFTP server");
      final resultSession = await _client.connect();
      Log.info(TAG, "Opened SSH session: $resultSession");
      final resultConnection = await _client.connectSFTP();
      Log.info(TAG, "Connected to SFTP server: $resultConnection");
      await Future.delayed(Duration(seconds: 1));
      await _writeTestInformationFile();
      await _restoreUploadingOffset();
      sftpConnectionStateStream.sink.add(SftpConnectionState.CONNECTED);
      _reconnectionAttempts = 0;
      _connectionInProgress = false;
    } catch (e) {
      _connectionInProgress = false;
      Log.shout(TAG, "Connection to SFTP failed, $e");
      _connectionInProgress = false;
      _tryToReconnect(error: e.toString());
    }
  }

  Future<void> _writeTestInformationFile() async {
    File infoFile = await sl<FileSystemService>().testInformationFile;
    await infoFile.writeAsString("WatchPAT device S/N: ${PrefsProvider.loadDeviceSerial()}\n");
    await infoFile.writeAsString("User ID: ${PrefsProvider.loadUserPin()}", mode: FileMode.append);
    try {
      await _client.sftpUpload(path: infoFile.path, toPath: _sftpFilePath);
      Log.info(TAG, "${DefaultSettings.serverInfoFileName} file created");
    } catch (e) {
      Log.shout(TAG, "Failed to create ${DefaultSettings.serverInfoFileName}, ${e.toString()}");
    }
  }

  void _tryToReconnect({@required String error}) async {
    if (sl<SystemStateManager>().inetConnectionState == ConnectivityResult.none) return;
    _reconnectionAttempts++;
    if (_reconnectionAttempts > 3) {
      _reconnectionAttempts = 0;
      sl<EmailSenderService>().sendSftpFailureEmail(error: error);
      _startReconnectionTimer();
      return;
    } else {
      await Future.delayed(Duration(seconds: 3));
      Log.shout(TAG, "Trying to reconnect to SFTP server, attempt: $_reconnectionAttempts");
      _initSftpConnection();
    }
  }

  void _startReconnectionTimer() {
    Log.shout(TAG, "Starting SFTP reconnection timer, the next attemps will be made in 1 hour");
    _serviceInitialized = false;
    _reconnectionTimer = Timer(Duration(hours: 1), () => _initSftpConnection());
  }

  void _awaitForData() async {
    do {
      if (sl<SystemStateManager>().inetConnectionState == ConnectivityResult.none) {
        Log.info(TAG, "Internet connection not available, cannot upload");
        resetSFTPService();
        return;
      }

      if (!_serviceInitialized) {
        Log.info(TAG, "SFTP service not initialized, cannot upload");
        return;
      }

      if (sftpConnectionStateStream.value == SftpConnectionState.DISCONNECTED) {
        Log.info(TAG, "SFTP disconnected, waiting for connection");
        await Future.delayed(Duration(seconds: 5));
        continue;
      }

      final int currentRecordingOffset = PrefsProvider.loadTestDataRecordingOffset();
      final int currentUploadingOffset = PrefsProvider.loadTestDataUploadingOffset();

      if (currentUploadingOffset < currentRecordingOffset) {
        _systemState.setSftpUploadingState(SftpUploadingState.UPLOADING);
        await _uploadDataChunk();

        // Check if test ended and all data is uploaded
        final int newUploadingOffset = PrefsProvider.loadTestDataUploadingOffset();
        if (currentRecordingOffset == newUploadingOffset &&
            _currentDataTransferState == DataTransferState.ENDED) {
          _currentUploadingState = SftpUploadingState.ALL_UPLOADED;
          _systemState.setSftpUploadingState(SftpUploadingState.ALL_UPLOADED);
        }
      } else if (currentUploadingOffset == currentRecordingOffset &&
          _currentDataTransferState == DataTransferState.ENDED) {
        _currentUploadingState = SftpUploadingState.ALL_UPLOADED;
        _systemState.setSftpUploadingState(SftpUploadingState.ALL_UPLOADED);
      } else {
        _systemState.setSftpUploadingState(SftpUploadingState.WAITING_FOR_DATA);
        Log.info(TAG,
            "Waiting for data: UPLOADING OFFSET: $currentUploadingOffset, RECORDING OFFSET: $currentRecordingOffset");
        await Future.delayed(Duration(seconds: 5));
      }
    } while (_currentUploadingState != SftpUploadingState.ALL_UPLOADED);
    Log.info(TAG, "Data waiting loop finished");
  }

  Future<int> getRemoteOffset() async {
    try {
      final SFTPFile remoteFile =
          await _client.sftpFileInfo(filePath: "$_sftpFilePath/$_sftpFileName");
      return remoteFile.size;
    } catch (e) {
      if (PrefsProvider.loadTestDataUploadingOffset() == 0) {
        return 0;
      } else {
        throw Exception("Remote file unreachable");
      }
    }
  }

  Future<void> _uploadDataChunk() async {
    try {
      int uploadingOffset = await getRemoteOffset();
      int recordingOffset = PrefsProvider.loadTestDataRecordingOffset();

      RandomAccessFile rafWithOffset = await _raf.setPosition(uploadingOffset);

      final int lengthToRead = recordingOffset - uploadingOffset > _dataChunkSize
          ? _dataChunkSize
          : recordingOffset - uploadingOffset;

      List<int> bytes = await rafWithOffset.read(lengthToRead);

      final File tempFile = File("${_tempDir.path}/$_sftpFileName");
      await tempFile.writeAsBytes(bytes);

      final String result = await _client.sftpAppendToFile(
          fromFilePath: tempFile.path, toFilePath: '$_sftpFilePath/$_sftpFileName');

      if (result == SftpService.APPENDING_SUCCESS) {
        int newOffset = await getRemoteOffset();

        while (newOffset == uploadingOffset) {
          Log.shout(TAG, ">>>>>>>>>> Same remote offset detected after successfull appending!!");
          await Future.delayed(Duration(seconds: 5));
          newOffset = await getRemoteOffset();
        }

        await PrefsProvider.saveTestDataUploadingOffset(newOffset);
        Log.info(TAG,
            "Uploaded chunk to SFTP. Current uploading offset: ${PrefsProvider.loadTestDataUploadingOffset()}, current recording offset: $recordingOffset");
      } else {
        Log.info(TAG, "Uploading to SFTP Failed with status: $result");
      }
    } catch (e) {
      Log.shout(TAG, "Uploading to SFTP Failed: $e");
      sftpConnectionStateStream.sink.add(SftpConnectionState.DISCONNECTED);
      await Future.delayed(Duration(seconds: 3));
      _tryToReconnect(error: e.toString());
    }
  }

  Future<void> _restoreUploadingOffset() async {
    try {
      final SFTPFile remoteFile =
          await _client.sftpFileInfo(filePath: "$_sftpFilePath/$_sftpFileName");
      Log.info(TAG, "Uploading offset restored");
      await PrefsProvider.saveTestDataUploadingOffset(remoteFile.size);
    } catch (e) {
      Log.info(TAG, "Restoring uploading offset: SFTP data file not found");
    }
  }

  Future<void> _checkRemoteFileSize() async {
    SFTPFile file = await _client.sftpFileInfo(filePath: "$_sftpFilePath/$_sftpFileName");
    Log.info(TAG, "UPLOADING OFFSET: ${PrefsProvider.loadTestDataUploadingOffset()}");
    Log.info(TAG, "REMOTE FILE SIZE: ${file.size}");
  }

  Future<void> _informDispatcher() async {
    await sl<DispatcherService>().sendTestComplete(PrefsProvider.loadDeviceSerial());
    sl<SystemStateManager>().setGlobalProcedureState(GlobalProcedureState.COMPLETE);
  }

  static const String APPENDING_SUCCESS = "appending_success";
}

class SftpFileRestoringTimeoutException implements Exception {}

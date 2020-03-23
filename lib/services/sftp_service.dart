import 'dart:async';
import 'dart:io';

import 'package:background_fetch/background_fetch.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/widgets.dart';
import 'package:my_pat/config/default_settings.dart';
import 'package:my_pat/domain_model/dispatcher_response_models.dart';
import 'package:my_pat/managers/managers.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/services/services.dart';
import 'package:my_pat/utils/log/log.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ssh/ssh.dart';

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
  }

  void resetSFTPService() async {
    deInitializeService();
    Log.info(TAG, "Stopping SFTP service");
    if (_client != null) {
      _client.sftpCancelUpload();
    }
    sftpConnectionStateStream.sink.add(SftpConnectionState.DISCONNECTED);
    _reconnectionAttempts = 0;
    Log.info(TAG, "SFTP service stopped");
  }

  _handleDataTransferState(DataTransferState state) {
    _currentDataTransferState = state;
    if (state == DataTransferState.TRANSFERRING && !_serviceInitialized) {
      initService();
//      PrefsProvider.setDataUploadingIncomplete(value: true);
    } else if (state == DataTransferState.ENDED && !_serviceInitialized) {
//      PrefsProvider.setDataUploadingIncomplete(value: true);
      initService();
    }
  }

  _handleSftpUploadingState(SftpUploadingState state) async {
    _currentUploadingState = state;
    if (state == SftpUploadingState.ALL_UPLOADED) {
      Log.info(TAG, "SFTP uploading complete, closing sftp connection and informing dispatcher");
      await _checkRemoteFileSize();
      resetSFTPService();
      await _informDispatcher();
      await sl<ServiceScreenManager>().resetApplication(clearConfig: false, killApp: false);
      sl<SystemStateManager>().setGlobalProcedureState(GlobalProcedureState.COMPLETE);
      PrefsProvider.setDataUploadingIncomplete(value: false);
      TransactionManager.platformChannel.invokeMethod("backgroundSftpUploadingFinished");
      TransactionManager.platformChannel.invokeMethod("enableAutoSleep");
      BackgroundFetch.finish();
      await BackgroundFetch.stop();
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

    if (sl<SystemStateManager>().inetConnectionState == ConnectivityResult.none) {
      await Future.delayed(Duration(seconds: 5));
      if (sl<SystemStateManager>().inetConnectionState == ConnectivityResult.none) {
        Log.shout(TAG, "No internet connection, SFTP service could not be initalized");
        deInitializeService();
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

  deInitializeService() {
    Log.info(TAG, "SFTP service deinitialized");
    _serviceInitialized = false;
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

  Future<int> getRemoteOffset() async {
    try {
      final SFTPFile remoteFile = await _client.sftpFileInfo(filePath: "$_sftpFilePath/$_sftpFileName");
      return remoteFile.size;
    } catch (e) {
      if (PrefsProvider.loadTestDataUploadingOffset() == 0) {
        return 0;
      } else {
        throw Exception("Remote file unreachable");
      }
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

      if (_currentDataTransferState == DataTransferState.ENDED) {
        await _uploadAllData(complete: true);
      } else {
        final int currentRecordingOffset = PrefsProvider.loadTestDataRecordingOffset();
        final int currentUploadingOffset = PrefsProvider.loadTestDataUploadingOffset();
        if ((currentRecordingOffset - currentUploadingOffset) < 100000) {
          Log.info(TAG, 'Accumulating data to 100k, recording offset: $currentRecordingOffset, uploading offset: $currentUploadingOffset');
          await Future.delayed(Duration(seconds: 10));
          continue;
        } else {
          await _uploadAllData();
          await _uploadLogFile();
        }
      }
    } while (_currentUploadingState != SftpUploadingState.ALL_UPLOADED);
    Log.info(TAG, "Data waiting loop finished");
  }

  void _startReconnectionTimer() {
    Log.shout(TAG, "Starting SFTP reconnection timer, the next attemps will be made in 1 hour");
    deInitializeService();
    _reconnectionTimer = Timer(Duration(hours: 1), () => _initSftpConnection());
  }

  Future<void> _uploadAllData({bool complete = false}) async {
    _systemState.setSftpUploadingState(SftpUploadingState.UPLOADING);
    try {
      Log.info(TAG, "Starting uploading");
      final File localFile = await sl<FileSystemService>().localDataFile;

      final String result = await _client.sftpResumeFile(
          path: localFile.path,
          toPath: '$_sftpFilePath/$_sftpFileName',
          callback: (var progress) {
            sl<SystemStateManager>().setSftpUploadingProgress(progress as int);
            Log.info(TAG, "Uploading progress: $progress");
          });

      _systemState.setSftpUploadingState(SftpUploadingState.NOT_UPLOADING);

      if (result == SftpService.UPLOADING_SUCCESS) {
        Log.info(TAG, "Uploading successful");
        await Future.delayed(Duration(seconds: 1));
        if (complete) {
          await _uploadLogFile();
          _currentUploadingState = SftpUploadingState.ALL_UPLOADED;
          _systemState.setSftpUploadingState(SftpUploadingState.ALL_UPLOADED);
        } else {
          int newOffset = await getRemoteOffset();
          await PrefsProvider.saveTestDataUploadingOffset(newOffset);
        }
      } else {
        throw Exception("Uploading to SFTP Failed with status: $result");
      }
    } catch (e) {
      Log.info(TAG, "Resuming upload to SFTP Failed with status: $e");
      sftpConnectionStateStream.sink.add(SftpConnectionState.DISCONNECTED);
      await Future.delayed(Duration(seconds: 3));
      if (_serviceInitialized) {
        _tryToReconnect(error: e.toString());
      }
    }
  }

  Future<void> _uploadLogFile() async {
    try {
      final File logFile = await sl<FileSystemService>().logMainFile;
      final String logFileName = sl<FileSystemService>().logMainFileName;
      final String result = await _client.sftpResumeFile(path: logFile.path, toPath: '$_sftpFilePath/$logFileName', callback: (_) {});
      if (result != SftpService.UPLOADING_SUCCESS) {
        throw Exception("Uploading to SFTP Failed with status: $result");
      }
    } catch (e) {
      Log.shout(TAG, "Uploading logs failed: $e");
    }
  }

  Future<void> _restoreUploadingOffset() async {
    try {
      final SFTPFile remoteFile = await _client.sftpFileInfo(filePath: "$_sftpFilePath/$_sftpFileName");
      Log.info(TAG, "Uploading offset restored");
      await PrefsProvider.saveTestDataUploadingOffset(remoteFile.size);
    } catch (e) {
      Log.info(TAG, "Restoring uploading offset: SFTP data file not found");
      await PrefsProvider.saveTestDataUploadingOffset(0);
    }
  }

  Future<void> _checkRemoteFileSize() async {
    final SFTPFile file = await _client.sftpFileInfo(filePath: "$_sftpFilePath/$_sftpFileName");
    final File localFile = await sl<FileSystemService>().localDataFile;
    Log.info(TAG, "LOCAL FILE SIZE: ${await localFile.length()}");
    Log.info(TAG, "REMOTE FILE SIZE: ${file.size}");
  }

  Future<void> _informDispatcher() async {
    final DispatcherResponse res = await sl<DispatcherService>().sendTestComplete(PrefsProvider.loadDeviceSerial());
    if (!res.error) {
      Log.info(TAG, "Test complete successfully sent");
    } else {
      Log.shout(TAG, "Failed to send test complete: ${res.message}");
    }
  }

  static const String APPENDING_SUCCESS = "appending_success";
  static const String UPLOADING_SUCCESS = "uploading_success";

  //todo TESTT
  cancelUpload() {
    _client.sftpCancelUpload();
  }
}

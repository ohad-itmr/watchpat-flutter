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
  BehaviorSubject<SftpConnectionState> _sftpConnectionState =
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
        _sftpConnectionState.stream,
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
      case TestStates.ENDED:
//        _closeConnection();
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
      String stamp = DateFormat("yyyy.MM.dd_HH:mm:ss").format(DateTime.now());
      await PrefsProvider.saveTestDataFilename(
          "${stamp}_${DefaultSettings.serverDataFileName}");
      await PrefsProvider.saveTestDataUploadingOffset(0);
    }

    _sftpFilePath = PrefsProvider.loadSftpPath();
    _sftpFileName = PrefsProvider.loadTestDataFilename();
    _tempDir = await getTemporaryDirectory();

    _dataFile = await _fileSystem.localDataFile;
    _raf = await _dataFile.open(mode: FileMode.read);

    await _initSftpConnection();
  }

  Future<void> _initSftpConnection() async {
    try {
      final resultSession = await _client.connect();
      final resultConnection = await _client.connectSFTP();
      Log.info(
          TAG, "Connected to SFTP server: $resultSession, $resultConnection");
      _sftpConnectionState.sink.add(SftpConnectionState.CONNECTED);
    } catch (e) {
      Log.shout(TAG, "Connection to SFTP failed, $e");
    }
  }

  void _awaitForData() async {
    do {
      // Check for connections, if none start waiting
      if (!_uploadingAvailable) {
        await _awaitForConnection();
      }

      final int currentRecordingOffset =
          PrefsProvider.loadTestDataRecordingOffset();
      final int currentUploadingOffset =
          PrefsProvider.loadTestDataUploadingOffset();


      if (currentUploadingOffset < currentRecordingOffset) {
        await _uploadDataChunk(
            uploadingOffset: currentUploadingOffset,
            recordingOffset: currentRecordingOffset);
      } else {
        Log.info(TAG,
            "Waiting for data: UPLOADING OFFSET: $currentUploadingOffset, RECORDING OFFSET: $currentRecordingOffset");
        await Future.delayed(Duration(seconds: 3));
      }

      // Check if test ended and all data is uploaded
      final int newUploadingOffset = PrefsProvider.loadTestDataUploadingOffset();
      if (currentRecordingOffset == newUploadingOffset &&
          _currentTestState == TestStates.ENDED) {
        _systemState.setDataTransferState(DataTransferStates.ALL_TRANSFERRED);
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

    final String result = await _client.sftpAppendToFile(
        fromFilePath: tempFile.path,
        toFilePath: '$_sftpFilePath/$_sftpFileName');

    if (result == SftpService.APPENDING_SUCCESS) {
      Log.info(TAG,
          "Uploaded chunk to SFTP. Current uploading offset: $uploadingOffset, current recording offset: $recordingOffset");
    } else {
      Log.shout(TAG, "Uploading to SFTP Failed: $result");
      return;
    }

    await PrefsProvider.saveTestDataUploadingOffset(
        uploadingOffset + bytes.length);
  }

  void _restoreUploading() async {
    final SFTPFile remoteFile =
        await _client.sftpFileInfo(filePath: "$_sftpFilePath/$_sftpFileName");
    await PrefsProvider.saveTestDataUploadingOffset(remoteFile.size);
    _awaitForData();
  }

  void _closeConnection() {
    Log.info(TAG, "Uploading of data complete, closing sftp connection");
    _sftpConnectionState.close();
  }

  static const String APPENDING_SUCCESS = "appending_success";
}

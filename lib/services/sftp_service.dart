import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
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
  TestStates _testState;

  SftpService() {
    _systemState = sl<SystemStateManager>();
    _fileSystem = sl<FileSystemService>();
    _systemState.testStateStream.listen(_handleTestState);
    _systemState.dispatcherStateStream.listen(_handleDispatcherState);

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

  // TESTING
  void checkFileSizes() async {
    final File localFile = _dataFile;
    final int localFileSize = await localFile.length();

    final SFTPFile remoteFile =
        await _client.sftpFileInfo(filePath: "$_sftpFilePath/$_sftpFileName");

    print(
        "CHECK = LOCAL SIZE: $localFileSize, REMOTE SIZE: ${remoteFile.size}");
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

  Future<void> _initService() async {
    Log.info(TAG, "Initializing SFTP service");

    UserAuthenticationService _authService = sl<UserAuthenticationService>();
    _client = SSHClient(
        host: _authService.sftpHost,
        port: _authService.sftpPort,
        username: _authService.sftpUserName,
        passwordOrKey: _authService.sftpPassword);

    String stamp = DateFormat("yyyy.MM.dd_HH:mm:ss").format(DateTime.now());
    await PrefsProvider.saveTestDataFilename(
        "${stamp}_${DefaultSettings.serverDataFileName}");
    await PrefsProvider.saveTestDataUploadingOffset(0);

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
      // TODO Check if test ended and data fully uploaded

      // Check for connections, if none start waiting
      if (!_uploadingAvailable) {
        await _awaitForConnection();
      }

      final int fileSize = await _raf.length();
      final int currentOffset = PrefsProvider.loadTestDataUploadingOffset();

      if (currentOffset < fileSize) {
        await _uploadDataChunk(offset: currentOffset);
      } else {
        Log.info(TAG,
            "Waiting for data: FILE SIZE: $fileSize, CURRENT OFFSET: $currentOffset");
        await Future.delayed(Duration(seconds: 3));
      }
    } while (_testState != TestStates.ENDED);
  }

  Future<void> _awaitForConnection() async {
    do {
      Log.info(TAG, "Waiting for connection");
      await Future.delayed(Duration(seconds: 3));
    } while (_uploadingAvailable);
  }

  Future<void> _uploadDataChunk({int offset}) async {
    RandomAccessFile rafWithOffset = await _raf.setPosition(offset);
    List<int> bytes = await rafWithOffset.read(_dataChunkSize);
    final File tempFile = File("${_tempDir.path}/$_sftpFileName");
    await tempFile.writeAsBytes(bytes);

    final String result = await _client.sftpAppendToFile(
        fromFilePath: tempFile.path,
        toFilePath: '$_sftpFilePath/$_sftpFileName');

    if (result == SftpService.APPENDING_SUCCESS) {
      final int fileLength = await _raf.length();
      Log.info(TAG,
          "Uploaded chunk to SFTP. Local file size: $fileLength, current writing offset: $offset");
    } else {
      Log.shout(TAG, "Uploading to SFTP Failed: $result");
      return;
    }

    await PrefsProvider.saveTestDataUploadingOffset(offset + bytes.length);
  }

  void _restoreUploading() async {
    final SFTPFile remoteFile =
        await _client.sftpFileInfo(filePath: "$_sftpFilePath/$_sftpFileName");
    await PrefsProvider.saveTestDataUploadingOffset(remoteFile.size);
    _awaitForData();
  }

  void _closeConnection() {
    Log.info(TAG, "Uploading of data file complete, closing sftp connection");
    _sftpConnectionState.close();
    _client.disconnectSFTP();
    _client.disconnect();
    _raf.close();
  }

  static const String APPENDING_SUCCESS = "appending_success";
}

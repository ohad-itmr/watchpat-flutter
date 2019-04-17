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

    final String remoteFilePath = await _client.sftpDownload(
      path: "$_sftpFilePath/$_sftpFileName",
      toPath: _tempDir.path,
    );
    File remoteFile = File(remoteFilePath);
    final int remoteFileSize = await remoteFile.length();

    print("CHECK = LOCAL SIZE: $localFileSize, REMOTE SIZE: $remoteFileSize");
  }

  _handleDispatcherState(DispatcherStates state) {
    switch (state) {
      case DispatcherStates.AUTHENTICATED:
        _initService();
        break;
      default:
    }
  }

  _handleTestState(TestStates state) {
    switch (state) {
      case TestStates.STARTED:
        _systemState.setDataTransferState(DataTransferStates.TRANSFERRING);
        _awaitForData();
        break;
      case TestStates.ENDED:
        _closeConnection();
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

    _initSftpConnection();
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

  Future<void> _uploadDataChunk({int offset}) async {
    print("ENTERED UPLOAD");
    final int fileLength = await _raf.length();
    Log.info(TAG,
        "Uploading data chunk to SFTP. Current data file size: $fileLength, current writing offset: $offset");

    RandomAccessFile rafWithOffset = await _raf.setPosition(offset);
    List<int> bytes = await rafWithOffset.read(_dataChunkSize);
    final File tempFile = File("${_tempDir.path}/$_sftpFileName");
    await tempFile.writeAsBytes(bytes);

    await _client.sftpUpload(path: tempFile.path, toPath: _sftpFilePath);

    await PrefsProvider.saveTestDataUploadingOffset(offset + bytes.length);

  }

  void _awaitForData() async {
    while (_testState != TestStates.ENDED) {

      // CHECK IF TEST ENDED AND DATA FULLY UPLOADED

      // CHECK CONNECTION
      final int fileSize = await _raf.length();
      final int currentOffset = PrefsProvider.loadTestDataUploadingOffset();

      if ((currentOffset + _dataChunkSize) < fileSize) {
        await _uploadDataChunk(offset: currentOffset);
      } else {
        Log.info(TAG,
            "Waiting for data: FILE SIZE: $fileSize, CURRENT OFFSET: $currentOffset");
        await Future.delayed(Duration(seconds: 3));
      }

    }
  }

  void _closeConnection() {
    Log.info(TAG, "Uploading of data file complete, closing sftp connection");
    _sftpConnectionState.close();
    _client.disconnectSFTP();
    _client.disconnect();
    _raf.close();
  }
}

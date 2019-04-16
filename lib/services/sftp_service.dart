import 'dart:async';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:my_pat/config/default_settings.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/services/services.dart';
import 'package:my_pat/utils/log/log.dart';
import 'package:ssh/ssh.dart';
import 'package:path_provider/path_provider.dart';

class SftpService {
  static const String TAG = 'SftpService';

  SystemStateManager _systemState = sl<SystemStateManager>();
  FileSystemService _fileSystem = sl<FileSystemService>();
  SSHClient _client;

  String _sftpFileName;
  String _sftpFilePath;
  File _dataFile;
  RandomAccessFile _raf;
  Directory _tempDir;
  int _dataChunkSize = DefaultSettings.uploadDataChunkMaxSize;

  SftpService() {
    _systemState = sl<SystemStateManager>();
    _fileSystem = sl<FileSystemService>();
    _systemState.testStateStream.listen(_handleTestState);
    _systemState.dispatcherStateStream.listen(_handleDispatcherState);
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

    final resultSession = await _client.connect();
    Log.info(TAG, "Starting SFTP session: $resultSession");

    final resultConnection = await _client.connectSFTP();
    Log.info(TAG, "Connecting to SFTP server: $resultConnection");
  }

  Future<void> _uploadDataChunk({int offset}) async {
    final int fileLength = await _raf.length();
    Log.info(TAG,
        "Uploading data chunk to SFTP. Current data file size: $fileLength, current writing offset: $offset");

    RandomAccessFile rafWithOffset = await _raf.setPosition(offset);
    List<int> bytes = await rafWithOffset.read(_dataChunkSize);
    final File tempFile = File("${_tempDir.path}/$_sftpFileName");
    await tempFile.writeAsBytes(bytes);

    await _client.sftpUpload(path: tempFile.path, toPath: _sftpFilePath);

    await PrefsProvider.saveTestDataUploadingOffset(offset + bytes.length);

    if (offset + _dataChunkSize < fileLength) {
      _uploadDataChunk(offset: offset + bytes.length);
    } else {
      _awaitForData();
    }
  }

  void _awaitForData() async {
    final int fileSize = await _raf.length();
    final int currentOffset = PrefsProvider.loadTestDataUploadingOffset();

    if (currentOffset < fileSize) {
      _uploadDataChunk(offset: currentOffset);
    } else {
      Log.info(TAG,
          "Waiting for data: FILE SIZE: $fileSize, CURRENT OFFSET: $currentOffset");
      await Future.delayed(Duration(seconds: 3));
      _awaitForData();
    }
  }

  void _closeConnection() {
    Log.info(TAG, "Uploading of data file complete, closing sftp connection");
    _client.disconnectSFTP();
    _client.disconnect();
    _raf.close();
  }
}

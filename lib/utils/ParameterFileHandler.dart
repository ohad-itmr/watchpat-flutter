import 'dart:io';

import 'package:my_pat/domain_model/device_commands.dart';
import 'package:my_pat/service_locator.dart';
import 'package:rxdart/rxdart.dart';

import 'log/log.dart';

class ParameterFileHandler extends ManagerBase {
  static const String TAG = "ParametersFileHandler";
  final S _loc = sl<S>();

  static const int PARAM_FILE_DATA_CHUNK = 2048;
  static const int LOG_FILE_DATA_CHUNK = 2048;

  List<int> _paramFileData;
  int _getFileOffset;
  bool _isGetFileDone;

  bool get ifFileGetDone => _isGetFileDone;

  PublishSubject<bool> _logFileStatus = PublishSubject<bool>();
  PublishSubject<bool> _paramFileGetStatus = PublishSubject<bool>();
  PublishSubject<bool> _paramFileSetStatus = PublishSubject<bool>();

  Observable<bool> get logFileStatusStream => _logFileStatus.stream;

  Observable<bool> get paramFileGetStatusStream => _paramFileGetStatus.stream;

  Observable<bool> get paramFileSetStatusStream => _paramFileSetStatus.stream;

  _getLogFile() {
    Log.info(TAG, "GetLogFile started");
    sl<CommandTaskerManager>().addCommandWithNoCb(
        DeviceCommands.getGetLogFileCmd(_getFileOffset, LOG_FILE_DATA_CHUNK));
    Log.info(TAG, ">>> Log file request offset: $_getFileOffset");
    _getFileOffset += LOG_FILE_DATA_CHUNK;
    Log.info(TAG, "GetLogFileCommand finished");
  }

  _getParamFile() {
    Log.info(TAG, "GetParamFile started");
    sl<CommandTaskerManager>().addCommandWithNoCb(
        DeviceCommands.getGetParametersFileCmd(
            _getFileOffset, PARAM_FILE_DATA_CHUNK));
    Log.info(TAG, ">>> Param file request offset: $_getFileOffset");
    _getFileOffset += PARAM_FILE_DATA_CHUNK;
    Log.info(TAG, "GetParamFileCommand finished");
  }

  _setParamFile() async {
    Log.info(TAG, "SetParamFile started");
    int currChunkSize;
    int offset = 0;
    while (offset < _paramFileData.length) {
      if (offset + PARAM_FILE_DATA_CHUNK < _paramFileData.length) {
        currChunkSize = PARAM_FILE_DATA_CHUNK;
      } else {
        currChunkSize = _paramFileData.length - offset;
      }
//      final List<int> currentChunk = Arrays.copyOfRange(_paramFileData, offset, offset + currChunkSize);
      final List<int> currentChunk =
          _paramFileData.getRange(offset, offset + currChunkSize).toList();
      sl<CommandTaskerManager>().sendDirectCommand(
          DeviceCommands.getSetParametersFileCmd(currentChunk, offset));
      offset += currChunkSize;
      await Future.delayed(Duration(seconds: 2));
    }
    Log.info(TAG, "SetParamFileCommand finished");
    _paramFileSetStatus.sink.add(true);
  }

  void startParamFileSet() {
    if (!readParamFile()) {
      return;
    }
    Log.info(TAG, ">>> param file size: ${_paramFileData.length}");
    _setParamFile();
  }

  void startParamFileGet() {
    _isGetFileDone = false;
    _getFileOffset = 0;
    _getParamFile();
  }

  void startLogFileGet() {
    _isGetFileDone = false;
    _getFileOffset = 0;
    _getLogFile();
  }

  void getParamFileResponse(final bool isRequestNext) {
    if (!_isGetFileDone) {
      if (isRequestNext) {
        _getParamFile();
      } else {
        _isGetFileDone = true;
        _paramFileGetStatus.sink.add(true);
      }
    }
  }

  void getLogFileResponse(final bool isRequestNext) {
    if (!_isGetFileDone) {
      if (isRequestNext) {
        _getLogFile();
      } else {
        _isGetFileDone = true;
        _logFileStatus.sink.add(true);
      }
    }
  }

  bool readParamFile() {
//    File paramFile = File(IOUtils.getExternalWatchPATDir(), _appContext.getString(R.string.params_ini_file_name));
//    if (paramFile.exists()) {
//      Log.info(TAG, "Loading parameter file from watchPAT dir");
//      _paramFileData = IOUtils.readTextFileFromInternalStorage(paramFile.getAbsolutePath());
//      return true;
//    } else if (IOUtils.isResourceExists(_appContext.getString(R.string.params_res_name), _appContext.getString(R.string.location_raw))) {
//      Log.info(TAG, "Loading parameter file from resources");
//      _paramFileData = IOUtils.readTextFileFromResource(R.raw.watchpat_params);
//      return true;
//    } else {
//      Log.shout(TAG, "Parameter file not found");
//      return false;
//    }
  return false;
  }

  @override
  void dispose() {
    _paramFileGetStatus.close();
    _paramFileSetStatus.close();
    _logFileStatus.close();
  }
}

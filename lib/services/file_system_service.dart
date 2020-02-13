import 'dart:io';
import 'dart:async';
import 'package:archive/archive_io.dart';
import 'package:flutter/services.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/services/services.dart';
import 'package:my_pat/utils/log/log.dart';
import 'package:my_pat/utils/time_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:my_pat/config/default_settings.dart';

import 'package:my_pat/domain_model/response_model.dart';

class FileSystemService {
  static const String TAG = 'FileSystemService';

  String _logFileName;

  final String localDataFileName = DefaultSettings.dataFileName;
  final String logInputFileName = DefaultSettings.logInputFileName;
  final String logOutputFileName = DefaultSettings.logOutputFileName;
  final String parametersFileName = DefaultSettings.parametersFileName;
  final String resourceParameterFileName = DefaultSettings.resourceParametersFileName;
  final String resourceFWFileName = DefaultSettings.resourceFWFileName;
  final String watchpatDirFWFileName = DefaultSettings.watchpatDirFWFileName;

  final String watchpatDirAFEFileName = DefaultSettings.watchpatDirAFEFileName;
  final String resourceDirAFEFileName = DefaultSettings.resourceAFEFileName;
  final String watchpatDirACCFileName = DefaultSettings.watchpatDirACCFileName;
  final String resourceDirACCFileName = DefaultSettings.resourceACCFileName;
  final String watchpatDirEEPROMFileName = DefaultSettings.watchpatDirEEPROMFileName;
  final String resourceDirEEPROMFileName = DefaultSettings.resourceEEPROMFileName;
  final String deviceLogFileName = DefaultSettings.deviceLogFileName;
  final String configFileName = DefaultSettings.configFileName;

  Future<String> get localPath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> get localDataFile async {
    final path = await localPath;
    return File('$path/$localDataFileName');
  }

  Future<File> get logMainFile async {
    final path = await localPath;
    return File('$path/$logMainFileName');
  }

  Future<List<File>> getAllLogFiles() async {
    Directory dir = await getApplicationDocumentsDirectory();
    List<File> files = [];
    StreamSubscription sub = dir.list(recursive: true, followLinks: false).listen((FileSystemEntity entity) async {
      if (entity.path.contains("ioslog")) {
        files.add(File(entity.path));
      }
    });
    await Future.delayed(Duration(seconds: 2));
    sub.cancel();
    return files;
  }

  Future<File> getAllLogFilesArchived() async {
    ZipFileEncoder encoder = ZipFileEncoder();
    Directory dir = await getApplicationDocumentsDirectory();
    final String archivePath = '${dir.path}/logs.zip';
    List<File> files = await getAllLogFiles();
    encoder.create(archivePath);
    files.forEach((File f) {
      encoder.addFile(f);
    });
    encoder.close();
    return File(archivePath);
  }

  String get logMainFileName {
    if (_logFileName == null) {
      _logFileName = '${DefaultSettings.logMainFileName}_${TimeUtils.getFullDateStringFromTimeStamp(DateTime.now())}.txt';
    }
    return _logFileName;
  }

  Future<void> createMainLogFile() async {
    try {
      File mainLogFile = await logMainFile;
      await mainLogFile.create();
      Log.info(TAG, 'MAIN_LOG_FILE CREATED');
    } catch (e) {
      Log.shout(TAG, "Failed to create main log file, ${e.toString()}");
    }
  }

  Future<File> get logInputFile async {
    final path = await localPath;
    return File('$path/$logInputFileName');
  }

  Future<File> get logOutputFile async {
    final path = await localPath;
    return File('$path/$logOutputFileName');
  }

  Future<File> get watchpatDirParametersFile async {
    final path = await localPath;
    return File('$path/$parametersFileName');
  }

  Future<File> get resourceParametersFile async {
    final path = await localPath;
    final ByteData bytes = await rootBundle.load('assets/raw/$parametersFileName');
    final buffer = bytes.buffer;
    return File('$path/$resourceParameterFileName').writeAsBytes(buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
  }

  Future<File> get resourceFWFile async {
    final path = await localPath;
    final ByteData bytes = await rootBundle.load('assets/raw/$resourceFWFileName');
    final buffer = bytes.buffer;
    return File('$path/$resourceFWFileName').writeAsBytes(buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes), flush: true);
  }

  Future<File> get watchpatDirFWFile async {
    final path = await localPath;
    return File('$path/$watchpatDirFWFileName');
  }

  Future<File> get testInformationFile async {
    final path = await localPath;
    return File('$path/${DefaultSettings.serverInfoFileName}');
  }

  Future<bool> get resourceFWFileExists async {
    try {
      final ByteData bytes = await rootBundle.load('assets/raw/$resourceFWFileName');
      return bytes.elementSizeInBytes != 0;
    } catch (e) {
      Log.shout(TAG, "fw upgrade file not found in resources, ${e.toString()}");
      return false;
    }
  }

  Future<File> get watchpatDirAFEFile async {
    final path = await localPath;
    return File('$path/$watchpatDirAFEFileName');
  }

  Future<File> get resourceAFEFile async {
    final path = await localPath;
    final ByteData bytes = await rootBundle.load('assets/raw/$resourceDirAFEFileName');
    final buffer = bytes.buffer;
    File f = await File('$path/$resourceDirAFEFileName').create();
    return f.writeAsBytes(buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes), flush: true);
  }

  Future<File> get watchpatDirACCFile async {
    final path = await localPath;
    return File('$path/$watchpatDirACCFileName');
  }

  Future<File> get resourceACCFile async {
    final path = await localPath;
    final ByteData bytes = await rootBundle.load('assets/raw/$resourceDirACCFileName');
    final buffer = bytes.buffer;
    File f = await File('$path/$resourceDirACCFileName').create();
    return f.writeAsBytes(buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes), flush: true);
  }

  Future<File> get watchpatDirEEPROMFile async {
    final path = await localPath;
    return File('$path/$watchpatDirEEPROMFileName');
  }

  Future<File> get resourceEEPROMFile async {
    final path = await localPath;
    final ByteData bytes = await rootBundle.load('assets/raw/$resourceDirEEPROMFileName');
    final buffer = bytes.buffer;
    File f = await File('$path/$resourceDirEEPROMFileName').create();
    return f.writeAsBytes(buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes), flush: true);
  }

  Future<File> get deviceLogFile async {
    final path = await localPath;
    return File('$path/$deviceLogFileName');
  }

  Future<File> get configFile async {
    final path = await localPath;
    return File('$path/$configFileName');
  }

  Future<Response> allocateSpace() async {
    if (sl<SystemStateManager>().testState == TestStates.NOT_STARTED) {
      archiveOldSleepFile();

      Log.info(TAG, 'checking sufficient local storage space...,');

      try {
        final int spaceToAllocate = GlobalSettings.minStorageSpaceMB;
        final int freeSpace = await TransactionManager.platformChannel.invokeMethod('getFreeSpace');
        Log.info(TAG, 'Checking available free space, required: $spaceToAllocate MB, have: $freeSpace MB');
        if (freeSpace > spaceToAllocate) {
          return Response(success: true);
        } else {
          Log.shout(TAG, "Not enough free space on the phone");
          return Response(success: false, error: "Not enough free space on the phone");
        }
      } catch (e) {
        Log.shout(TAG, 'SPACE ALLOCATION FAILED $e');
        return Response(success: false, error: e.toString());
      }
    } else {
      return Response(success: true);
    }
  }

  Future<Response> init() async {
    TestStates testState = sl<SystemStateManager>().testState;
    try {
      await createMainLogFile();
      // create new data files in case of first app launch
      if (testState == TestStates.NOT_STARTED) {
        _createSleepFile();
      }

      // delete files previously received from device
      File paramFile = await watchpatDirParametersFile;
      if (paramFile.existsSync()) paramFile.deleteSync();
      File afeFile = await watchpatDirAFEFile;
      if (afeFile.existsSync()) afeFile.deleteSync();
      File accFile = await watchpatDirACCFile;
      if (accFile.existsSync()) accFile.deleteSync();
      File eepromFile = await watchpatDirEEPROMFile;
      if (eepromFile.existsSync()) eepromFile.deleteSync();
      Log.info(TAG, "Deleted stored config files previously received from device");

      return Response(success: true);
    } catch (e) {
      Log.warning(TAG, 'FILES PREPARATION ERROR: ${e.toString()}');
      return Response(success: false, error: e.toString());
    }
  }

  Future<void> _createSleepFile() async {
    File file = await localDataFile;
    if (await file.exists()) {
      await archiveOldSleepFile();
    }
    await file.create();
    Log.info(TAG, 'LOCAL_DATA_FILE CREATED');
  }

  void initParameterFile() async {
    Log.info(TAG, 'Attempt to create parameter file...');
    try {
      File paramFile = await watchpatDirParametersFile;
      if (paramFile.existsSync()) paramFile.deleteSync();
      paramFile.createSync();
      Log.info(TAG, 'Parameter file created');
    } catch (e) {
      Log.warning(TAG, 'Parameter file creation error: ${e.toString()}');
    }
  }

  void initLogFile() async {
    Log.info(TAG, 'Attempt to create device log file...');
    try {
      File logFile = await watchpatDirParametersFile;
      if (logFile.existsSync()) logFile.deleteSync();
      logFile.createSync();
      Log.info(TAG, 'Device log file created');
    } catch (e) {
      Log.warning(TAG, 'Device log file creation error: ${e.toString()}');
    }
  }

  Future<Response> clear() async {
    try {
      File logInFile = await logInputFile;
      if (logInFile.existsSync()) logInFile.deleteSync();
      File logOutFile = await logInputFile;
      if (logOutFile.existsSync()) logOutFile.deleteSync();
      Log.info(TAG, 'LOG FILES CLEARED');
      return Response(success: true);
    } catch (e) {
      Log.warning(TAG, 'FILES CLEAR ERROR: ${e.toString()}');
      return Response(success: false, error: e.toString());
    }
  }

  Future<void> deleteConfigFile() async {
    File file = await configFile;
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> archiveOldSleepFile() async {
    File file = await localDataFile;
    if (await file.exists()) {
      Log.info(TAG, "Found local data file from previous session");
      if (await file.length() > 0) {
        final String path = await localPath;
        await file.rename('$path/${localDataFileName}_${TimeUtils.getFullDateStringFromTimeStamp(DateTime.now())}');
        Log.info(TAG, "Local data file renamed");
      } else {
        await file.delete();
        Log.info(TAG, "Local data file deleted");
      }
    } else {
      Log.info(TAG, "Local data file does not exist");
    }
  }
}

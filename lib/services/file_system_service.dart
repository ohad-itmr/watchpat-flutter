import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/services/services.dart';
import 'package:my_pat/utils/log/log.dart';
import 'package:path_provider/path_provider.dart';
import 'package:my_pat/config/default_settings.dart';

import 'package:my_pat/domain_model/response_model.dart';

class FileSystemService {
  static const String TAG = 'FileSystemService';

  final String localDataFileName = DefaultSettings.dataFileName;
  final String logInputFileName = DefaultSettings.logInputFileName;
  final String logMainFileName = DefaultSettings.logMainFileName;
  final String logOutputFileName = DefaultSettings.logOutputFileName;
  final String parametersFileName = DefaultSettings.parametersFileName;
  final String resourceParameterFileName =
      DefaultSettings.resourceParametersFileName;
  final String resourceFWFileName = DefaultSettings.resourceFWFileName;

  final String watchpatDirAFEFileName = DefaultSettings.watchpatDirAFEFileName;
  final String resourceDirAFEFileName = DefaultSettings.resourceAFEFileName;
  final String watchpatDirACCFileName = DefaultSettings.watchpatDirACCFileName;
  final String resourceDirACCFileName = DefaultSettings.resourceACCFileName;
  final String watchpatDirEEPROMFileName = DefaultSettings.watchpatDirEEPROMFileName;
  final String resourceDirEEPROMFileName = DefaultSettings.resourceEEPROMFileName;

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
    final ByteData bytes =
        await rootBundle.load('assets/raw/$parametersFileName');
    final buffer = bytes.buffer;
    return File('$path/$resourceParameterFileName').writeAsBytes(
        buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
  }

  Future<File> get resourceFWFile async {
    final path = await localPath;
    final ByteData bytes =
        await rootBundle.load('assets/raw/$resourceFWFileName');
    final buffer = bytes.buffer;
    return File('$path/$resourceFWFileName').writeAsBytes(
        buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
        flush: true);
  }

  Future<bool> get resourceFWFileExists async {
    try {
      final ByteData bytes =
          await rootBundle.load('assets/raw/$resourceFWFileName');
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
    final ByteData bytes =
        await rootBundle.load('assets/raw/$resourceDirAFEFileName');
    final buffer = bytes.buffer;
    File f = await File('$path/$resourceDirAFEFileName').create();
    return f.writeAsBytes(
        buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
        flush: true);
  }

  Future<File> get watchpatDirACCFile async {
    final path = await localPath;
    return File('$path/$watchpatDirACCFileName');
  }

  Future<File> get resourceACCFile async {
    final path = await localPath;
    final ByteData bytes =
    await rootBundle.load('assets/raw/$resourceDirACCFileName');
    final buffer = bytes.buffer;
    File f = await File('$path/$resourceDirACCFileName').create();
    return f.writeAsBytes(
        buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
        flush: true);
  }

  Future<File> get watchpatDirEEPROMFile async {
    final path = await localPath;
    return File('$path/$watchpatDirEEPROMFileName');
  }

  Future<File> get resourceEEPROMFile async {
    final path = await localPath;
    final ByteData bytes =
    await rootBundle.load('assets/raw/$resourceDirEEPROMFileName');
    final buffer = bytes.buffer;
    File f = await File('$path/$resourceDirEEPROMFileName').create();
    return f.writeAsBytes(
        buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
        flush: true);
  }

  Future<Response> allocateSpace() async {
    File localFile = await localDataFile;
    TestStates testState = sl<SystemStateManager>().testState;

    if (testState == TestStates.NOT_STARTED) {
      if (await localFile.exists()) {
        Log.info(TAG, "data file from previous session is found, deleting...");
        try {
          await localFile.delete();
        } catch (e) {
          Log.shout(TAG, 'data file delete failed $e');
        }
      }
      Log.info(TAG, 'checking sufficient local storage space...,');

      try {
        var spaceToAllocate = GlobalSettings.minStorageSpaceMB * 1024 * 1000;
        Log.info(TAG, 'Free storage space: $spaceToAllocate required');
        RandomAccessFile file = await localFile.open(mode: FileMode.write);
        file.truncateSync(spaceToAllocate);
        file.closeSync();
        return Response(success: true);
      } catch (e) {
        Log.shout(TAG, 'SPACE ALLOCATION FAILED $e');
        return Response(success: false, error: e.toString());
      }
    } else {
      return Response(success: true);
    }
  }

  Future<Response> init() async {
    try {
      Log.info(TAG, 'Attempt to prepare initial files...');
      File mainLogFile = await logMainFile;
      await mainLogFile.create();
      Log.info(TAG, 'MAIN_LOG_FILE CREATED');
      File localFile = await localDataFile;
      await localFile.create();
      Log.info(TAG, 'LOCAL_DATA_FILE CREATED');
      File logInFile = await logInputFile;
      logInFile.create();
      Log.info(TAG, 'LOG_INBOUND_FILE CREATED');
      File logOutFile = await logInputFile;
      logOutFile.create();
      Log.info(TAG, 'LOG_OUTBOUND_FILE CREATED');

      // delete filed previously received from device
      File paramFile = await watchpatDirParametersFile;
      if (paramFile.existsSync()) paramFile.deleteSync();
      File afeFile = await watchpatDirAFEFile;
      if (afeFile.existsSync()) afeFile.deleteSync();
      File accFile = await watchpatDirACCFile;
      if (accFile.existsSync()) accFile.deleteSync();
      File eepromFile = await watchpatDirEEPROMFile;
      if (eepromFile.existsSync()) eepromFile.deleteSync();
      Log.info(TAG, "Deleted stored files previously received form device");

      return Response(success: true);
    } catch (e) {
      Log.warning(TAG, 'FILES PREPARATION ERROR: ${e.toString()}');
      return Response(success: false, error: e.toString());
    }
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

  Future<Response> clear() async {
    try {
      File localFile = await localDataFile;
      await localFile.delete();
      File logInFile = await logInputFile;
      logInFile.delete();
      File logOutFile = await logInputFile;
      logOutFile.delete();
      Log.info(TAG, 'FILES CLEARED');
      return Response(success: true);
    } catch (e) {
      Log.warning(TAG, 'FILES CLEAR ERROR: ${e.toString()}');
      return Response(success: false, error: e.toString());
    }
  }
}

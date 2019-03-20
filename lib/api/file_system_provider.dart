import 'dart:io';
import 'dart:async';
import 'package:my_pat/utility/log/log.dart';
import 'package:path_provider/path_provider.dart';
import 'package:my_pat/config/settings.dart';

import 'package:my_pat/models/response_model.dart';

class FileSystemProvider {
  final String localDataFileName = Settings.dataFileName;
  final String logInputFileName = Settings.logInputFileName;
  final String logMainFileName = Settings.logMainFileName;
  final String logOutputFileName = Settings.logOutputFileName;

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

  Future<Response> allocateSpace() async {
    File localFile = await localDataFile;
    if (await localFile.exists()) {
      Log.info("data file from previous session is found, deleting...");
      try {
        await localFile.delete();
      } catch (e) {
        Log.shout('data file delete failed $e');
      }
    }
    Log.info('checking sufficient local storage space...,');

    try {
      var spaceToAllocate = Settings.minStorageSpaceMb * 1024;
      Log.info('Free storage space: $spaceToAllocate required');
      RandomAccessFile file = await localFile.open(mode: FileMode.write);
      file.truncateSync(spaceToAllocate);
      file.closeSync();
      return Response(success: true);
    } catch (e) {
      Log.shout('SPACE ALLOCATION FAILED $e');
      return Response(success: false, error: e.toString());
    }
  }

  Future<Response> init() async {

    try {
      Log.info('Attempt to create initial files...');
      File mainLogFile = await logMainFile;
      await mainLogFile.create();
      Log.info('MAIN_LOG_FILE CREATED');
      File localFile = await localDataFile;
      await localFile.create();
      Log.info('LOCAL_DATA_FILE CREATED');
      File logInFile = await logInputFile;
      logInFile.create();
      Log.info('LOG_INBOUND_FILE CREATED');
      File logOutFile = await logInputFile;
      logOutFile.create();
      Log.info('LOG_OUTBOUND_FILE CREATED');
      return Response(success: true);
    } catch (e) {
      Log.warning('FILES CREATION ERROR: ${e.toString()}');
      return Response(success: false, error: e.toString());
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
      Log.info('FILES CLEARED');
      return Response(success: true);
    } catch (e) {
      Log.warning('FILES CLEAR ERROR: ${e.toString()}');
      return Response(success: false, error: e.toString());
    }
  }
}

FileSystemProvider fileSystemProvider = FileSystemProvider();

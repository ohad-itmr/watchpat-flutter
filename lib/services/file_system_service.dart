import 'dart:io';
import 'dart:async';
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
      Log.info(TAG,"data file from previous session is found, deleting...");
      try {
        await localFile.delete();
      } catch (e) {
        Log.shout(TAG,'data file delete failed $e');
      }
    }
    Log.info(TAG,'checking sufficient local storage space...,');

    try {
      var spaceToAllocate = GlobalSettings.minStorageSpaceMB * 1024;
      Log.info(TAG,'Free storage space: $spaceToAllocate required');
      RandomAccessFile file = await localFile.open(mode: FileMode.write);
      file.truncateSync(spaceToAllocate);
      file.truncateSync(0);
      file.closeSync();
      return Response(success: true);
    } catch (e) {
      Log.shout(TAG,'SPACE ALLOCATION FAILED $e');
      return Response(success: false, error: e.toString());
    }
  }

  Future<Response> init() async {

    try {
      Log.info(TAG,'Attempt to create initial files...');
      File mainLogFile = await logMainFile;
      await mainLogFile.create();
      Log.info(TAG,'MAIN_LOG_FILE CREATED');
      File localFile = await localDataFile;
      await localFile.create();
      Log.info(TAG,'LOCAL_DATA_FILE CREATED');
      File logInFile = await logInputFile;
      logInFile.create();
      Log.info(TAG,'LOG_INBOUND_FILE CREATED');
      File logOutFile = await logInputFile;
      logOutFile.create();
      Log.info(TAG,'LOG_OUTBOUND_FILE CREATED');
      return Response(success: true);
    } catch (e) {
      Log.warning(TAG,'FILES CREATION ERROR: ${e.toString()}');
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
      Log.info(TAG,'FILES CLEARED');
      return Response(success: true);
    } catch (e) {
      Log.warning(TAG,'FILES CLEAR ERROR: ${e.toString()}');
      return Response(success: false, error: e.toString());
    }
  }
}


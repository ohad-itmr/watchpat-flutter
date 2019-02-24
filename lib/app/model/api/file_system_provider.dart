import 'dart:io';
import 'dart:async';
import 'package:my_pat/utility/log/log.dart';
import 'package:path_provider/path_provider.dart';
import 'package:my_pat/config/settings.dart';

class FileSystemProvider {
  final String localDataFileName = Settings.dataFileName;
  final String logInputFileName = Settings.logInputFileName;
  final String logOutputFileName = Settings.logOutputFileName;

  Future<String> get localPath async {
    final dir = await getApplicationDocumentsDirectory();
    print('DIR ${dir.path}');
    return dir.path;
  }

  Future<File> get localDataFile async {
    final path = await localPath;
    return File('$path/$localDataFileName');
  }

  Future<File> get logInputFile async {
    final path = await localPath;
    return File('$path/$logInputFileName');
  }

  Future<File> get logOutputFile async {
    final path = await localPath;
    return File('$path/$logOutputFileName');
  }

  Future<void> allocateSpace() async {
    File localFile = await localDataFile;

    try {
      RandomAccessFile file = await localFile.open(mode: FileMode.write);
      file.truncateSync(Settings.spaceToAllocate);
      file.closeSync();
      Log.info('ALLOCATION SUCCESSFULL');
    } catch (e) {
      Log.warning('ALLOCATE SPACE ERROR: ${e.toString()}');
    }
  }

  Future<void> init() async {
    try {
      File localFile = await localDataFile;
      await localFile.create();
      File logInFile = await logInputFile;
      logInFile.create();
      File logOutFile = await logInputFile;
      logOutFile.create();
      Log.info('FILES CREATED');
    } catch (e) {
      Log.warning('FILES CREATION ERROR: ${e.toString()}');
    }
  }

  Future<void> clear() async {
    try {
      File localFile = await localDataFile;
      await localFile.delete();
      File logInFile = await logInputFile;
      logInFile.delete();
      File logOutFile = await logInputFile;
      logOutFile.delete();
      Log.info('FILES CLEARED');
    } catch (e) {
      Log.warning('FILES CLEAR ERROR: ${e.toString()}');
    }
  }
}

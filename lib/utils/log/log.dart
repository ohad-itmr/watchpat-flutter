import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:my_pat/service_locator.dart';

class Log{
  static const String _NAME = 'Logger';
  static Logger _instance;
  static IOSink _logFileSink;

  static Future<void> init() async {
    Logger.root.onRecord.listen((record) {
      final String logEntry = '${record.level.name}: ${record.time}: ${record.message}';
      print(logEntry);
      writeLogToFile(logEntry);
    });
    _instance = Logger(_NAME);
    await _initLogFile();
  }

  static Future<void> _initLogFile() async {
    final File logFile = await sl<FileSystemService>().logMainFile;
    _logFileSink = logFile.openWrite();
  }

  static void writeLogToFile(String entry) {
    if (_logFileSink != null) {
      _logFileSink.write('$entry\n');
    }
  }

  static void setLevel(Level level){
    Logger.root.level = level;
  }

  static void info(String tag,String message, [Object error, StackTrace stackTrace]){
    _instance.info('$tag - $message', error, stackTrace);
  }

  static void warning(String tag,String message, [Object error, StackTrace stackTrace]){
    _instance.warning('$tag - $message', error, stackTrace);
  }

  static void config(String tag,String message, [Object error, StackTrace stackTrace]){
    _instance.config('$tag - $message', error, stackTrace);
  }

  static void fine(String tag,String message, [Object error, StackTrace stackTrace]){
    _instance.fine('$tag - $message', error, stackTrace);
  }

  static void finer(String tag,String message, [Object error, StackTrace stackTrace]){
    _instance.finer('$tag - $message', error, stackTrace);
  }

  static void finest(String tag,String message, [Object error, StackTrace stackTrace]){
    _instance.finest('$tag - $message', error, stackTrace);
  }

  static void severe(String tag,String message, [Object error, StackTrace stackTrace]){
    _instance.severe('$tag - $message', error, stackTrace);
  }

  static void shout(String tag,String message, [Object error, StackTrace stackTrace]){
    _instance.shout('$tag - $message', error, stackTrace);
  }

  static void dispose() {
    _logFileSink.close();
  }
}

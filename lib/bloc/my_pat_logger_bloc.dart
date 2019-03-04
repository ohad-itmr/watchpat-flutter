import 'package:date_format/date_format.dart';
import 'package:my_pat/api/file_system_provider.dart';
import 'package:my_pat/utility/log/log.dart';
import 'dart:io';

class MyPatLoggerBloc {
  final _filesProvider = FileSystemProvider();


  _saveLogMessage(String tag, String sender, String message) async {
    try {
      var now = formatDate(
          DateTime.now(), [dd, '.', mm, '.', yyyy,' ', HH, ':', mm, ':', ss, '.', SSS]);
      var longMessage = '\r\n $now $tag /$sender:$message';
      File logMainFile = await _filesProvider.logMainFile;
      Log.info('[SAVE TO MAIN LOG] $longMessage');
      await logMainFile.writeAsString(longMessage, mode: FileMode.append);
    } catch (e) {
      Log.shout('[SAVE TO MAIN LOG ERROR], $e');
    }
  }

  void i(String sender, String message) {
    _saveLogMessage('INFO', sender, message);
  }

  void e(String sender, String message) {
    _saveLogMessage('ERROR', sender, message);
  }

  void clearLog() async {
    File logMainFile = await _filesProvider.logMainFile;
    await logMainFile.delete();
  }
}

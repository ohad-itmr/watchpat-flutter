import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/log/log.dart';

class EmailSenderService {
  static const String SMTP_HOST = "smtp.gmail.com";
  static const String SMTP_USERNAME = "itamar.medical.development@gmail.com";
  static const String SMTP_PASSWORD = "itamar1234";

  static const String TAG = "EmailSenderSerivce";

  Future<bool> sendSftpFailureEmail({@required String error}) async {
    final message = Message()
      ..from = Address(SMTP_USERNAME, 'Itamar Medical')
      ..recipients.add(PrefsProvider.loadServiceEmail())
//      ..recipients.add("wp1@itamar-medical.com")
//      ..recipients.add("m.derzhavets@emg-soft.com")
      ..subject = 'SFTP server connection failed'
      ..text = 'Connection to SFTP server was failed.\n\n' +
          'Host: ${sl<UserAuthenticationService>().sftpHost}\n' +
          'Reason: $error\n' +
          'Time: ${DateTime.now().toIso8601String()}\n' +
          'Device s/n: ${PrefsProvider.loadDeviceSerial()}';

    return await _sendMessage(message);
  }

  Future<bool> sendLogFile() async {
    File logFile = await sl<FileSystemService>().logMainFile;
    final message = Message()
      ..from = Address(SMTP_USERNAME, 'Itamar Medical')
      ..recipients.add(PrefsProvider.loadServiceEmail())
      ..subject = 'Application log file'
      ..text = 'Received log file exported from WatchPAT application.\n\n' +
          'Time: ${DateTime.now().toIso8601String()}\n' +
          'Device s/n: ${PrefsProvider.loadDeviceSerial()}'
      ..attachments = [FileAttachment(logFile)];

    return await _sendMessage(message);
  }

  Future<bool> sendAllLogFiles() async {
    List<File> files = await sl<FileSystemService>().getAllLogFiles();
    List<Attachment> attachment = files.map((File f) => FileAttachment(f)).toList();
    final message = Message()
      ..from = Address(SMTP_USERNAME, 'Itamar Medical')
      ..recipients.add("wp1@itamar-medical.com")
//      ..recipients.add("m.derzhavets@emg-soft.com")
      ..subject = 'Study log files'
      ..text = 'Received log files exported from WatchPAT application.\n\n' +
          'Time: ${DateTime.now().toIso8601String()}\n' +
          'Device s/n: ${PrefsProvider.loadDeviceSerial()}'
      ..attachments = attachment;

    return await _sendMessage(message);
  }

  Future<bool> _sendMessage(Message msg) async {
    try {
      final SmtpServer server =
          SmtpServer(SMTP_HOST, username: SMTP_USERNAME, password: SMTP_PASSWORD);
      Log.info(TAG, "Trying to send mail: ($SMTP_HOST, $SMTP_USERNAME, $SMTP_PASSWORD)");
      SendReport report = await send(msg, server);
      Log.info(TAG, "$report");
      return true;
    } catch (e) {
      Log.shout(TAG, "Email sending failed: ${e.toString()}");
      return false;
    }
  }

  // TEST
  Future<bool> sendTestMail() async {
    final message = Message()
      ..from = Address(SMTP_USERNAME, 'Itamar Medical')
      ..recipients.add('m.derzhavets@emg-soft.com')
      ..subject = 'This thing is alive!!'
      ..text = 'This is test message from background fetch';

    return await _sendMessage(message);
  }
}

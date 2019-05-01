import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:my_pat/service_locator.dart';

class EmailSenderService {
  static const String SMTP_HOST = "smtp.gmail.com";
  static const String SMTP_USERNAME = "itamar.medical.development@gmail.com";
  static const String SMTP_PASSWORD = "itamar1234";

  static const String TAG = "EmailSenderSerivce";

  final _smtpServer =
      SmtpServer(SMTP_HOST, username: SMTP_USERNAME, password: SMTP_PASSWORD);

  Future<void> sendSftpFailureEmail({@required String error}) async {
    final message = Message()
      ..from = Address(SMTP_USERNAME, 'Itamar Medical')
      ..recipients.add(GlobalSettings.serviceEmailAddress)
      ..subject = 'SFTP server connection failed'
      ..text = 'Connection to SFTP server was failed.\n\n' +
          'Host: ${sl<UserAuthenticationService>().sftpHost}\n' +
          'Reason: $error\n' +
          'Time: ${DateTime.now().toIso8601String()}\n' +
          'Device s/n: ${PrefsProvider.loadDeviceSerial()}';

    await send(message, _smtpServer);
  }
}

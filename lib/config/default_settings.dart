class DefaultSettings {
  static const appName = 'WatchPATApp';
  static final itamarUartName = 'ITAMAR_UART';
  static final itamarUartAddress = 'CD:FC:5C:DA:F0:AD';

  static final sftpHostName = 'myPAT.itamar-online.com';
  static final sftpUserName = 'mypat';
  static final sftpPassword = 'myPATtest17';
  static final sftpDataDir = 'myPAT_test_data';

  static final dataFileName = 'localData.dat';
  static final serverDataFileName = 'localData.dat';
  static final serverInfoFileName = 'TestInformation.txt';
  static final logMainFileName = 'mypat_main_log.txt';
  static final logInputFileName = 'mypat_log_input.txt';
  static final logOutputFileName = 'mypat_log_output.txt';

  static const String SERVICE_UID = '6e400001-b5a3-f393-e0a9-e50e24dcca9e';
  static const String TX_CHAR_UUID = '6e400003-b5a3-f393-e0a9-e50e24dcca9e';
  static const String RX_CHAR_UUID = '6e400002-b5a3-f393-e0a9-e50e24dcca9e';

  static final uploadDataChunkMaxSize = 5000;
  static final uploadDataAccumulationSize = 100000;
  static final minStorageSpaceMb = 80;
  static final minTestLengthHours = 7;
  static final maxTestLengthHours = 10;
  static final sessionTimeoutHours = 20;
  static final minBatteryRequiredLevel = 95;
  static final dispatcherLink = "https://wp1-we.itamar-online.com:3335";
  static final userPinCodeLength = 4;
  static final timeoutFtpSec = 80;
  static final timeoutBleSec = 10;
  static final timeoutTransactionSec = 20;
  static final emailService = "m.derzhavets@emg-soft.com";
  static final debugMode = true;

  static final demoUrl = "";
  static final dataTransferRate = 120.0;
  static var minBatteryAskedLevel = 95;
  static var minDataForUpload = 0.1;
  static var fwVersionsForUpgrade = [];
  static var btScanTimeout = 5000;
  static var dispatchersUrls = [];

  static Map<String, dynamic> settingsToMap() {
    return <String, dynamic>{
      'uploadDataChunkMaxSize': uploadDataChunkMaxSize,
      'uploadDataAccumulationSize': uploadDataAccumulationSize,
      'minStorageSpaceMb': minStorageSpaceMb,
      'minTestLengthHours': minTestLengthHours,
      'maxTestLengthHours': maxTestLengthHours,
      'sessionTimeoutHours': sessionTimeoutHours,
      'minBatteryLevel': minBatteryRequiredLevel,
      'dispatcherLink': dispatcherLink,
      'userPinCodeLength': userPinCodeLength,
      'timeoutFtpSec': timeoutFtpSec,
      'timeoutBleSec': timeoutBleSec,
      'timeoutTransactionSec': timeoutTransactionSec,
      'emailService': emailService,
      'debugMode': debugMode,
    };
  }
}

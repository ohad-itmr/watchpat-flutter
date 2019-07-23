class DefaultSettings {
  static const appName = 'WatchPATApp';
  static final itamarUartName = 'ITAMAR_UART';
  static final itamarUartAddress = 'CD:FC:5C:DA:F0:AD';

  static final sftpHostName = 'myPAT.itamar-online.com';
  static final sftpUserName = 'mypat';
  static final sftpPassword = 'myPATtest17';
  static final sftpDataDir = 'myPAT_test_data';

  static final dataFileName = 'localData.dat';
  static final serverDataFileName = 'sleep.dat';
  static final serverInfoFileName = 'TestInformation.txt';
  static final logMainFileName = 'log';
  static final logInputFileName = 'mypat_log_input.txt';
  static final logOutputFileName = 'mypat_log_output.txt';
  static final parametersFileName = 'watchpat_params.ini';
  static final resourceParametersFileName = 'watchpat_params_resource.ini';
  static final resourceFWFileName = 'watchpat_resource.bin';
  static final watchpatDirFWFileName = 'watchpat.bin';

  static const String SERVICE_UID = '6e400001-b5a3-f393-e0a9-e50e24dcca9e';
  static const String TX_CHAR_UUID = '6e400003-b5a3-f393-e0a9-e50e24dcca9e';
  static const String RX_CHAR_UUID = '6e400002-b5a3-f393-e0a9-e50e24dcca9e';

  static final uploadDataChunkMaxSize = 5000;
  static final uploadDataAccumulationSize = 100000;
  static final minStorageSpaceMb = 80;
  static final double minTestLengthHours = 5;
  static final double maxTestLengthHours = 10;
  static final double sessionTimeoutHours = 20;
  static final minBatteryRequiredLevel = 95;
  static final dispatcherLink2 = "https://dispatcher.watchpat-one.com";
  static final dispatcherLink1 = "http://mypat.dev.valigar.co.il";
  static final userPinCodeLength = 4;
  static final timeoutFtpSec = 80;
  static final timeoutBleSec = 10;
  static final timeoutTransactionSec = 20;
  static final emailService = "not@working.com";
  static final debugMode = true;

  static final demoUrl = "";
  static final dataTransferRate = 60.0;
  static var minBatteryAskedLevel = 95;
  static var minDataForUpload = 0.1;
  static var fwVersionsForUpgrade = List<String>();
  static var btScanTimeout = 5000;
  static var dispatchersUrls = List<String>();

  static String watchpatDirAFEFileName = 'watchpat_aferegs.bin';
  static String resourceAFEFileName = 'watchpat_aferegs_resource.bin';
  static String watchpatDirACCFileName = "watchpat_accregs.bin";
  static String resourceACCFileName = "watchpat_accregs_resource.bin";
  static String watchpatDirEEPROMFileName = "watchpat_eeprom.bin";
  static String resourceEEPROMFileName = "watchpat_eeprom_resource.bin";
  static String deviceLogFileName = "main_device_log.txt";
  static String configFileName = 'watchpat_settings_ios.xml';


  static Map<String, dynamic> settingsToMap() {
    return <String, dynamic>{
      'uploadDataChunkMaxSize': uploadDataChunkMaxSize,
      'uploadDataAccumulationSize': uploadDataAccumulationSize,
      'minStorageSpaceMb': minStorageSpaceMb,
      'minTestLengthHours': minTestLengthHours,
      'maxTestLengthHours': maxTestLengthHours,
      'sessionTimeoutHours': sessionTimeoutHours,
      'minBatteryLevel': minBatteryRequiredLevel,
      'dispatchersUrls': [dispatcherLink1, dispatcherLink2],
      'fwVersionsForUpgrade': [],
      'userPinCodeLength': userPinCodeLength,
      'timeoutFtpSec': timeoutFtpSec,
      'timeoutBleSec': timeoutBleSec,
      'timeoutTransactionSec': timeoutTransactionSec,
      'supportEmail': emailService,
      'debugMode': debugMode,
    };
  }
}

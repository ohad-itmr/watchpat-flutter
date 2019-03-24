import 'package:flutter_blue/flutter_blue.dart';


class BleService {
  static const String SERVICE_UID = '6e400001-b5a3-f393-e0a9-e50e24dcca9e';
  static const String TX_CHAR_UUID = '6e400003-b5a3-f393-e0a9-e50e24dcca9e';
  static const String RX_CHAR_UUID = '6e400002-b5a3-f393-e0a9-e50e24dcca9e';

  static const int SEND_COMMANDS_DELAY = 10;
  static const int SEND_ACK_DELAY = 2000;
  static const int MAX_COMMAND_TIMEOUT = 10000;

  FlutterBlue flutterBlue = FlutterBlue.instance;
}







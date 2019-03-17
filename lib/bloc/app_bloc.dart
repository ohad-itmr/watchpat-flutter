import 'helpers/bloc_base.dart';
import 'package:my_pat/bloc/bloc_provider.dart';
import 'package:my_pat/generated/i18n.dart';

const int MEGABYTE = 1024 * 1024;

class AppBloc extends BlocBase {
  BleBloc bleBloc;
  BatteryBloc batteryBloc;
  MyPatLoggerBloc loggerBloc;
  WelcomeActivityBloc welcomeBloc;
  CommandTaskerBloc commandTaskerBloc;
  DeviceConfigBloc configBloc;
  SystemStateBloc systemStateBloc;
  IncomingPacketHandlerBloc incomingPacketHandler;

  S lang;

  AppBloc() {
    lang = S();
    batteryBloc = BatteryBloc(lang);
    loggerBloc = MyPatLoggerBloc();
    welcomeBloc = WelcomeActivityBloc(this);
    commandTaskerBloc = CommandTaskerBloc();
    configBloc = DeviceConfigBloc(this);
    systemStateBloc = SystemStateBloc(this);
    incomingPacketHandler = IncomingPacketHandlerBloc(this);
    bleBloc = BleBloc(lang, this);

  }

  @override
  void dispose() {
    batteryBloc.dispose();
    bleBloc.dispose();
    welcomeBloc.dispose();
    commandTaskerBloc.dispose();
    configBloc.dispose();
    systemStateBloc.dispose();
    incomingPacketHandler.dispose();
  }
}

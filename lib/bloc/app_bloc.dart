
import 'helpers/bloc_base.dart';
import 'package:my_pat/bloc/bloc_provider.dart';
import 'package:my_pat/generated/i18n.dart';

const int MEGABYTE = 1024 * 1024;

class AppBloc extends BlocBase {
  NetworkBloc networkBloc;
  FileBloc fileBloc;
  PinBloc pinBloc;
  BleBloc bleBloc;
  BatteryBloc batteryBloc;
  MyPatLoggerBloc loggerBloc;
  WelcomeActivityBloc welcomeBloc;
  S lang;

  AppBloc() {
    lang = S();
    networkBloc = NetworkBloc(lang);
    fileBloc = FileBloc(lang);
    bleBloc = BleBloc(lang);
    pinBloc = PinBloc(lang);
    batteryBloc = BatteryBloc(lang);
    loggerBloc = MyPatLoggerBloc(this);
    welcomeBloc = WelcomeActivityBloc(this);
  }

  @override
  void dispose() {
    networkBloc.dispose();
    fileBloc.dispose();
    pinBloc.dispose();
    batteryBloc.dispose();
    welcomeBloc.dispose();
  }
}

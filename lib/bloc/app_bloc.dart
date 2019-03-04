import 'helpers/bloc_base.dart';
import 'package:my_pat/bloc/bloc_provider.dart';
import 'package:my_pat/generated/i18n.dart';

const int MEGABYTE = 1024 * 1024;

class AppBloc extends BlocBase {
  BleBloc bleBloc;
  BatteryBloc batteryBloc;
  MyPatLoggerBloc loggerBloc;
  WelcomeActivityBloc welcomeBloc;
  S lang;

  AppBloc() {
    lang = S();
    bleBloc = BleBloc(lang);
    batteryBloc = BatteryBloc(lang);
    loggerBloc = MyPatLoggerBloc();
    welcomeBloc = WelcomeActivityBloc(this);
  }

  @override
  void dispose() {
    batteryBloc.dispose();
    bleBloc.dispose();
    welcomeBloc.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/rendering.dart';
import 'helpers/localizations.dart';
import 'blocs/pin_bloc_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/battery_screen.dart';
import 'screens/chest_sensor_screen.dart';
import 'screens/end_screen.dart';
import 'screens/finger_probe_screen.dart';
import 'screens/recording_screen.dart';
import 'screens/remove_jewelry_screen.dart';
import 'screens/start_recording_screen.dart';
import 'screens/strap_wrist_screen.dart';
import 'screens/uploading_screen.dart';
import 'screens/pin_screen.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PinBlocProvider(
      child: MaterialApp(
        localizationsDelegates: [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        supportedLocales: [
          Locale('en', ''),
          Locale('es', ''),
        ],
        title: 'WatchPAT ONE',
        theme: ThemeData(
          primaryColor: Color.fromARGB(255, 96, 164, 155),
          accentColor: Color.fromARGB(255, 96, 154, 197),
          buttonTheme: ButtonThemeData(
            minWidth: 140.0,
            height: 40.0,
          ),
          textTheme: TextTheme(
            title: TextStyle(
              color: Color.fromARGB(255, 0, 73, 114),
            ),
            body1: TextStyle(
              color: Color.fromARGB(255, 0, 73, 114),
              letterSpacing: 0.07,
            ),
          ),
        ),
        onGenerateRoute: routes,
      ),
    );
  }

  Route routes(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (BuildContext context) {
            return WelcomeScreen();
          },
        );
      case '/battery':
        return MaterialPageRoute(
          builder: (BuildContext context) {
            return BatteryScreen();
          },
        );
      case '/pin':
        return MaterialPageRoute(
          builder: (BuildContext context) {
            final PinBloc pinBloc = PinBlocProvider.of(context);
            pinBloc.resetPin();
            return PinScreen();
          },
        );

      case '/prepare1':
        return MaterialPageRoute(
          builder: (BuildContext context) {
            return RemoveJewelryScreen();
          },
        );
      case '/prepare2':
        return MaterialPageRoute(
          builder: (BuildContext context) {
            return StrapWristScreen();
          },
        );
      case '/prepare3':
        return MaterialPageRoute(
          builder: (BuildContext context) {
            return ChestSensorScreen();
          },
        );
      case '/prepare4':
        return MaterialPageRoute(
          builder: (BuildContext context) {
            return FingerProbeScreen();
          },
        );
      case '/start':
        return MaterialPageRoute(
          builder: (BuildContext context) {
            return StartRecordingScreen();
          },
        );
      case '/recording':
        return MaterialPageRoute(
          builder: (BuildContext context) {
            return RecordingScreen();
          },
        );
      case '/uploading':
        return MaterialPageRoute(
          builder: (BuildContext context) {
            return UploadingScreen();
          },
        );
      case '/end':
        return MaterialPageRoute(
          builder: (BuildContext context) {
            return EndScreen();
          },
        );
      default:
        return MaterialPageRoute(
          builder: (BuildContext context) {
            return WelcomeScreen();
          },
        );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/rendering.dart';
import 'helpers/localizations.dart';
import 'screens/welcome_screen.dart';
import 'screens/battery_screen.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      initialRoute: '/',
      routes: {
        '/': (BuildContext context) => WelcomeScreen(),
        '/battery':(BuildContext context) => BatteryScreen()
      },
    );
  }
}

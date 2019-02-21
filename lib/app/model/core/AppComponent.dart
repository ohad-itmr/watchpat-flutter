import 'package:fluro/fluro.dart';
import 'package:MyPAT/bloc/pin_bloc_provider.dart';
import 'package:MyPAT/config/Env.dart';
import 'package:flutter/material.dart';
import 'AppProvider.dart';
import 'AppStoreApplication.dart';
import 'package:MyPAT/generated/i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppComponent extends StatefulWidget {
  final AppStoreApplication _application;

  AppComponent(this._application);

  @override
  State createState() {
    return new AppComponentState(_application);
  }
}

class AppComponentState extends State<AppComponent> {
  final AppStoreApplication _application;

  AppComponentState(this._application);

  @override
  Widget build(BuildContext context) {
    final app = PinBlocProvider(
      child: MaterialApp(
        title: Env.appName,
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        supportedLocales: S.delegate.supportedLocales,
        debugShowCheckedModeBanner: false,
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
        onGenerateRoute: _application.router.generator,
      ),
    );

    final appProvider = AppProvider(child: app, application: _application);
    return appProvider;
  }
}

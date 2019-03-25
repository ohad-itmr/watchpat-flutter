import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logging/logging.dart';
import 'package:my_pat/app/app_routes.dart';
import 'package:my_pat/config/app_theme.dart';
import 'package:my_pat/config/default_settings.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/log/log.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  PrefsService.prefs = await SharedPreferences.getInstance();
  Log.init();
  Log.setLevel(Level.INFO);
  setUpServiceLocator();

  runApp(AppComponent());
}

class AppComponent extends StatefulWidget {
  AppComponent({Key key}) : super(key: key);

  @override
  State createState() => _AppComponentState();
}

class _AppComponentState extends State<AppComponent> {
  Router router;

  void _initLog() {
//    Log.init();
//    Log.setLevel(Level.INFO);
  }

  void _initRouter() {
    router = new Router();
    AppRoutes.configureRoutes(router);
  }

  @override
  void initState() {
    super.initState();
    _initLog();
    _initRouter();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: DefaultSettings.appName,
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: S.delegate.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      onGenerateRoute: router.generator,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}


import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_pat/app/app_routes.dart';
import 'package:my_pat/config/app_theme.dart';
import 'package:my_pat/config/default_settings.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/service_locator.dart' as prefix0;
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  PrefsService.prefs = await SharedPreferences.getInstance();
  await setupServices();

  // todo for development purpose only
  await PrefsProvider.setTestStarted(false);


  runApp(AppComponent());
}

class AppComponent extends StatefulWidget {
  AppComponent({Key key}) : super(key: key);

  @override
  State createState() => _AppComponentState();
}

class _AppComponentState extends State<AppComponent> {
  Router router;

  void _initRouter() {
    router = new Router();
    AppRoutes.configureRoutes(router);
  }

  @override
  void initState() {
    super.initState();
    _initRouter();

    // todo for development only

    PrefsProvider.setIgnoreDeviceErrors(true);
    PrefsProvider.setFirstDeviceConnection(state: true);
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

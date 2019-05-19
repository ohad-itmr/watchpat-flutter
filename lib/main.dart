import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_pat/app/app_routes.dart';
import 'package:my_pat/config/app_theme.dart';
import 'package:my_pat/config/default_settings.dart';
import 'package:my_pat/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  PrefsService.prefs = await SharedPreferences.getInstance();

  // todo for development purpose only
  await PrefsProvider.setTestStarted(false);
  PrefsProvider.setIsFirstDeviceConnection(true);
  PrefsProvider.setIgnoreDeviceErrors(true);


  await setupServices();

  runApp(AppComponent());
}

class AppComponent extends StatefulWidget {
  AppComponent({Key key}) : super(key: key);

  @override
  State createState() => _AppComponentState();

  static void setLocale(BuildContext context, Locale newLocale) async {
    await PrefsProvider.saveLocale(newLocale);
    _AppComponentState state =
        context.ancestorStateOfType(TypeMatcher<_AppComponentState>());
    state.changeLocale();
  }
}

class _AppComponentState extends State<AppComponent> {
  Router router;
  Locale _locale = PrefsProvider.loadLocale();

  void _initRouter() {
    router = new Router();
    AppRoutes.configureRoutes(router);
  }

  void changeLocale() {
    setState(() => _locale = PrefsProvider.loadLocale());
  }

  @override
  void initState() {
    super.initState();
    _initRouter();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: DefaultSettings.appName,
      locale: _locale,
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

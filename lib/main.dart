import 'package:background_fetch/background_fetch.dart';
import 'package:connectivity/connectivity.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_pat/app/app_routes.dart';
import 'package:my_pat/config/app_theme.dart';
import 'package:my_pat/config/default_settings.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/log/log.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  PrefsService.prefs = await SharedPreferences.getInstance();

  await setupServices();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(AppComponent());
}

class AppComponent extends StatefulWidget {
  AppComponent({Key key}) : super(key: key);

  @override
  State createState() => _AppComponentState();

  static void setLocale(BuildContext context, Locale newLocale) async {
    await PrefsProvider.saveLocale(newLocale);
    _AppComponentState state = context.ancestorStateOfType(TypeMatcher<_AppComponentState>());
    state.changeLocale();
  }
}

class _AppComponentState extends State<AppComponent> {
  final String TAG = "AppComponent";
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
    _initBackgroundFetch();
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

  _initBackgroundFetch() {
    BackgroundFetch.configure(BackgroundFetchConfig(minimumFetchInterval: 15), _backgroundFetchTask)
        .then((int status) {
      Log.info(TAG, "Register background fetch SUCCESS $status");
    }).catchError((e) {
      Log.info(TAG, "Register background fetch FAILED $e");
    });
  }

  // Fetch-event callback.
  void _backgroundFetchTask() async {
    Log.info(TAG, "[BACKGROUND] Received background fetch event");
    sl<EmailSenderService>().sendTestMail();
    if (sl<SystemStateManager>().isTestActive) {
      Log.info(TAG, "[BACKGROUND]: Test in progress, checking session timeout");
      if (sl<TestingManager>().checkForSessionTimeout()) {
        // todo request additional background time
      } else {
        Log.info(TAG, "[BACKGROUND]: Session is still active, finishing task");
        BackgroundFetch.finish();
      }
    } else if (PrefsProvider.getDataUploadingIncomplete()) {
      Log.info(TAG, "[BACKGROUND]: SFTP uploading incomplete, checking internet connection");
      final Connectivity _connectivity = Connectivity();
      _connectivity.checkConnectivity().then((ConnectivityResult res) {
        if (res != ConnectivityResult.none) {
          //todo  request additional background time
          sl<SystemStateManager>().setDataTransferState(DataTransferState.ENDED);
        } else {
          Log.info(TAG, "[BACKGROUND]: Internet connection unavailable, finishing task");
          BackgroundFetch.finish();
        }
      });
    } else {
      Log.info(TAG, "[BACKGROUND]: App state is clean, finishing task");
      BackgroundFetch.finish();
    }
  }
}

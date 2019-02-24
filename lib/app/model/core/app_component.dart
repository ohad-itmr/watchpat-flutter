import 'package:flutter/material.dart';
import 'package:my_pat/bloc/pin_bloc_provider.dart';
import 'package:my_pat/bloc/file_bloc_provider.dart';
import 'package:my_pat/config/Env.dart';
import 'app_provider.dart';
import 'package:my_pat/config/app_theme.dart';
import 'app_store_application.dart';
import 'package:my_pat/generated/i18n.dart';
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
  final AppStoreApplication application;

  AppComponentState(this.application);

  @override
  Widget build(BuildContext context) {
    final app = FileBlocProvider(
      child: PinBlocProvider(
        child: MaterialApp(
          title: Env.appName,
          localizationsDelegates: [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate
          ],
          supportedLocales: S.delegate.supportedLocales,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          onGenerateRoute: application.router.generator,
        ),
      ),
    );

    final appProvider = AppProvider(child: app, application: application);
    return appProvider;
  }
}

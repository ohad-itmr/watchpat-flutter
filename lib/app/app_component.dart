import 'package:flutter/material.dart';
import 'package:my_pat/config/Env.dart';
import 'package:my_pat/app/app_provider.dart';
import 'package:my_pat/config/app_theme.dart';
import 'package:my_pat/app/app_store_application.dart';
import 'package:my_pat/generated/i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_pat/bloc/bloc_provider.dart';

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
  AppBloc appBloc;

  AppComponentState(this.application);

  @override
  void initState() {
    super.initState();
    print('[INIT_STATE]');
    appBloc = AppBloc();
  }

  @override
  Widget build(BuildContext context) {
    final app = BlocProviderTree(
      blocProviders: [
        BlocProvider<AppBloc>(bloc: appBloc),
        BlocProvider<NetworkBloc>(bloc: appBloc.networkBloc),
        BlocProvider<FileBloc>(bloc: appBloc.fileBloc),
        BlocProvider<PinBloc>(bloc: appBloc.pinBloc),
        BlocProvider<WelcomeActivityBloc>(bloc: appBloc.welcomeBloc),
      ],
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
    );

    final appProvider = AppProvider(child: app, application: application);
    return appProvider;
  }

  @override
  void dispose() {
    appBloc.dispose();
    super.dispose();
  }
}

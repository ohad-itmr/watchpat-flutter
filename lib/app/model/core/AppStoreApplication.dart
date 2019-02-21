import 'package:fluro/fluro.dart';
import 'AppRoutes.dart';
import 'dart:async';
import 'package:MyPAT/config/Env.dart';
import 'package:MyPAT/utility/framework/Application.dart';
import 'package:MyPAT/utility/log/Log.dart';
import 'package:logging/logging.dart';

class AppStoreApplication implements Application {
  Router router;

  @override
  Future<void> onCreate() async {
    _initLog();
    _initRouter();
  }

  void _initLog() {
    Log.init();

    switch (Env.environmentType) {
      case EnvType.TESTING:
      case EnvType.DEVELOPMENT:
      case EnvType.STAGING:
        {
          Log.setLevel(Level.ALL);
          break;
        }
      case EnvType.PRODUCTION:
        {
          Log.setLevel(Level.INFO);
          break;
        }
    }
  }

  void _initRouter() {
    router = new Router();
    AppRoutes.configureRoutes(router);
  }
}

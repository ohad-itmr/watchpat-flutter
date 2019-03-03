import 'package:fluro/fluro.dart';
import 'package:my_pat/app/app_routes.dart';
import 'dart:async';
import 'package:my_pat/config/Env.dart';
import 'package:my_pat/utility/framework/Application.dart';
import 'package:my_pat/utility/log/log.dart';
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

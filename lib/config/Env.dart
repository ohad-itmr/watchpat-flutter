import 'package:flutter/material.dart';
import 'package:MyPAT/app/model/core/AppComponent.dart';
import 'package:MyPAT/app/model/core/AppStoreApplication.dart';

enum EnvType { DEVELOPMENT, STAGING, PRODUCTION, TESTING }

class Env {

  static String appName = "MyPAT";
  static String baseUrl = 'https://api.dev.website.org';
  static EnvType environmentType=EnvType.DEVELOPMENT;

  // Database Config



//  void _init() async {
//    var application = AppStoreApplication();
//    await application.onCreate();
//    runApp(AppComponent(application));
//  }
}

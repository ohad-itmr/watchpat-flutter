import 'package:flutter/material.dart';
import 'package:MyPAT/app/model/core/AppComponent.dart';
import 'package:MyPAT/app/model/core/AppStoreApplication.dart';

void main() async {
//  debugPaintSizeEnabled = true;
  var application = AppStoreApplication();
  await application.onCreate();
  runApp(AppComponent(application));
}

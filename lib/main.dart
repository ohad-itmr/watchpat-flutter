import 'package:flutter/material.dart';
import 'package:my_pat/app/app_component.dart';
import 'package:my_pat/app/app_store_application.dart';

void main() async {
//  debugPaintSizeEnabled = true;
  var application = AppStoreApplication();
  await application.onCreate();
  runApp(AppComponent(application));
}

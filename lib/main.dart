import 'package:flutter/material.dart';
import 'package:my_pat/app/model/core/app_component.dart';
import 'package:my_pat/app/model/core/app_store_application.dart';

void main() async {
//  debugPaintSizeEnabled = true;
  var application = AppStoreApplication();
  await application.onCreate();
  runApp(AppComponent(application));
}

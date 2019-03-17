import 'package:flutter/material.dart';
import 'package:my_pat/app/app_component.dart';
import 'package:my_pat/app/app_store_application.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_pat/api/prefs_provider.dart';

void main() async {
//  debugPaintSizeEnabled = true;
  PrefsSingleton.prefs = await SharedPreferences.getInstance();

  var application = AppStoreApplication();
  await application.onCreate();
  runApp(AppComponent(application));
}

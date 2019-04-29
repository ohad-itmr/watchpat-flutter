import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationsService {
  static const String TAG = 'NotificationsService';

  FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  NotificationsService() {
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocationLocation);
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    _localNotifications.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) async {}

  Future onDidReceiveLocationLocation(_,__,___,____) async {}

  Future<void> showLocalNotification(String msg) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'mypat_notification_channel', 'MyPAT', 'MyPAT application',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await _localNotifications.show(
        0, 'MyPAT', msg, platformChannelSpecifics,
        payload: 'item id 1');
  }
}
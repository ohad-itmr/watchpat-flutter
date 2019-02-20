import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/messages_all.dart';

/*
1. After strings update run:
flutter pub pub run intl_translation:extract_to_arb --output-dir=lib/src/l10n lib/src/helpers/localizations.dart

2. After translations edit run:
flutter pub pub run intl_translation:generate_from_arb --output-dir=lib/src/l10n --no-use-deferred-loading lib/src/helpers/localizations.dart lib/src/l10n/intl_*.arb
*/

class AppLocalizations {
  static Future<AppLocalizations> load(Locale locale) {
    print(locale);
    final String name =
        locale.countryCode == null ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((bool _) {
      Intl.defaultLocale = localeName;
      return new AppLocalizations();
    });
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  String get stepperOf {
    return Intl.message(
      'of',
      name: 'stepperOf',
    );
  }

  String get stepperStep {
    return Intl.message(
      'Step',
      name: 'stepperStep',
    );
  }

  //#region Welcome
  String get welcomeTitle {
    return Intl.message(
      'WELCOME',
      name: 'welcomeTitle',
    );
  }

  String get welcomeContent {
    return Intl.message(
      '''
You are using an Application that works with the WatchPAT® device in collecting your sleep data for your physician. 
You are about to start a few minutes of pre-sleep setup activities, after which the WatchPAT  will start its role, and you can start you good night sleep.
''',
      name: 'welcomeContent',
    );
  }

  //#endregion Welcome

  //#region Battery

  String get batteryTitle {
    return Intl.message(
      'INSERT BATTERY',
      name: 'batteryTitle',
    );
  }

  String get batteryContent_1 {
    return Intl.message(
      '''
Open the battery door on the bottom side of  the WatchPAT™ and insert the provided battery.
''',
      name: 'batteryContent_1',
    );
  }

  String get batteryContent_2 {
    return Intl.message(
      '''
The flat side of the battery  goes to where the MINUS sign is depicted.
''',
      name: 'batteryContent_2',
    );
  }

  //#endregion Battery

  //#region Prepare
  String get removeJewelryTitle {
    return Intl.message(
      'REMOVE JEWELRY',
      name: 'removeJewelryTitle',
    );
  }

  String get removeJewelryContent {
    return Intl.message(
      '''
Remove tight cloths, watches and jewelry.
Ensure that the finger nail is trimmed.
Remove artificial nail or colored nail polish from the monitored finger.
Use the MORE button to see more details.
''',
      name: 'removeJewelryContent',
    );
  }

  String get strapWristTitle {
    return Intl.message(
      'STRAP WRIST DEVICE',
      name: 'strapWristTitle',
    );
  }

  String get strapWristContent {
    return Intl.message(
      '''
You will be putting the WatchPAT on your non-dominant hand. 
Place the WatchPAT on a flat surface. 
Insert your hand and close the strap, making sure its snug but not too  tight.
''',
      name: 'strapWristContent',
    );
  }

  String get chestSensorTitle {
    return Intl.message(
      'ATTACH CHEST SENSOR',
      name: 'chestSensorTitle',
    );
  }

  String get chestSensorContent {
    return Intl.message(
      '''
Pull the Chest Sensor along your non dominant hand, and up to the neck opening. 
Peel the white paper from the back of the sensor. Stick the sensor to the center of your upper chest bone, just below the front of neck.
''',
      name: 'chestSensorContent',
    );
  }

  String get fingerProbeTitle {
    return Intl.message(
      'WEAR FINGER PROBE',
      name: 'fingerProbeTitle',
    );
  }

  String get fingerProbeContent {
    return Intl.message(
      '''
Insert any finger, except your thumb, all the way into the probe.  
The sticker marked TOP should be on the top of your finger. Hold the probe against a hard surface (like a table) and pull the TOP tab toward you to remove it from the probe.
''',
      name: 'fingerProbeContent',
    );
  }

  //#endregion Prepare

  //#region PIN
  String get pinTitle {
    return Intl.message(
      'ENTER PIN',
      name: 'pinTitle',
    );
  }

  String get pinContent {
    return Intl.message(
      '''
Enter your assigned four digits PIN 
(personal identification number) and tap enter
''',
      name: 'pinContent',
    );
  }
  //#endregion PIN

  //#region Start Recording
  String get startRecordingTitle {
    return Intl.message(
      'START RECORDING',
      name: 'startRecordingTitle',
    );
  }

  String get startRecordingContent {
    return Intl.message(
      '''
Once the device has been properly put on, the WatchPAT™ is ready to start recording. Have a good night sleep.
If you need to get up during the night, do not remove the device or sensors.
Do leave the phone behind, connected  to the charger.
''',
      name: 'startRecordingContent',
    );
  }
  //#endregion Start Recording

  //#region Recording
  String get recordingTitle {
    return Intl.message(
      'GOOD NIGHT',
      name: 'recordingTitle',
    );
  }
  //#endregion Recording

  //#region Uploading
  String get pleaseWait {
    return Intl.message(
      'Please wait',
      name: 'pleaseWait',
    );
  }

  String get uploadingTitle {
    return Intl.message(
      'GOOD MORNING',
      name: 'uploadingTitle',
    );
  }

  String get uploadingContent {
    return Intl.message(
      '''
Please do not close the application while the data is being uploaded.
The data transmission will be over in several minutes.
''',
      name: 'uploadingContent',
    );
  }
  //#endregion Uploading


  //#region Thank You
  String get thankYouTitle {
    return Intl.message(
      'THANK YOU',
      name: 'thankYouTitle',
    );
  }

  String get thankYouContent {
    return Intl.message(
      '''
The data has been successfully uploaded and the test is over.
Please dispose the product by your local guidances.
''',
      name: 'thankYouContent',
    );
  }
  //#endregion Thank You

  //#region Buttons

  String get btnCloseApp {
    return Intl.message(
      'CLOSE APP',
      name: 'btnCloseApp',
    );
  }

  String get btnEndRecording {
    return Intl.message(
      'END RECORDING',
      name: 'btnEndRecording',
    );
  }

  String get btnEnter {
    return Intl.message(
      'ENTER',
      name: 'btnEnter',
    );
  }

  String get btnMore {
    return Intl.message(
      'MORE',
      name: 'btnMore',
    );
  }

  String get btnNext {
    return Intl.message(
      'NEXT',
      name: 'btnNext',
    );
  }

  String get btnPreview {
    return Intl.message(
      'PREVIEW',
      name: 'btnPreview',
    );
  }

  String get btnReady {
    return Intl.message(
      'READY',
      name: 'btnReady',
    );
  }

  String get btnReturnToApp {
    return Intl.message(
      'RETURN TO APP',
      name: 'btnReturnToApp',
    );
  }

  String get btnStartRecording {
    return Intl.message(
      'START RECORDING',
      name: 'btnStartRecording',
    );
  }
//#endregion Buttons

}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return AppLocalizations.load(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/messages_all.dart';

/*
1. After strings update run:
flutter pub pub run intl_translation:extract_to_arb --output-dir=lib/src/l10n lib/src/helpers/localizations.dart

2. After translations edit run:
flutter pub pub run intl_translation:generate_from_arb --output-dir=lib/src/l10n --no-use-deferred-loading lib/src/helpers/localizations.dart lib/src/l10n/intl_*.arb*/

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

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ignore_for_file: non_constant_identifier_names
// ignore_for_file: camel_case_types
// ignore_for_file: prefer_single_quotes

// This file is automatically generated. DO NOT EDIT, all your changes would be lost.
class S implements WidgetsLocalizations {
  const S();

  static const GeneratedLocalizationsDelegate delegate =
    GeneratedLocalizationsDelegate();

  static S of(BuildContext context) => Localizations.of<S>(context, S);

  @override
  TextDirection get textDirection => TextDirection.ltr;

  String get batteryContent_1 => "Open the battery door on the bottom side of  the WatchPAT™ and insert the provided battery.";
  String get batteryContent_2 => "The flat side of the battery  goes to where the MINUS sign is depicted.";
  String get batteryTitle => "Insert Battery";
  String get btnCloseApp => "Close App";
  String get btnEndRecording => "End Recording";
  String get btnEnter => "Enter";
  String get btnMore => "More";
  String get btnNext => "Next";
  String get btnPreview => "Preview";
  String get btnReady => "Ready";
  String get btnReturnToApp => "Return To App";
  String get btnStartRecording => "Start Recording";
  String get chestSensorContent => "Pull the Chest Sensor along your non dominant hand, and up to the neck opening. \nPeel the white paper from the back of the sensor. Stick the sensor to the center of your upper chest bone, just below the front of neck.";
  String get chestSensorTitle => "Attach Chest Sensor";
  String get fingerProbeContent => "Insert any finger, except your thumb, all the way into the probe.  \nThe sticker marked TOP should be on the top of your finger. Hold the probe against a hard surface (like a table) and pull the TOP tab toward you to remove it from the probe.";
  String get fingerProbeTitle => "Wear Finger Probe";
  String get pinContent => "Enter your assigned four digits PIN \n(personal identification number) and tap enter";
  String get pinTitle => "Enter Pin";
  String get pleaseWait => "Please Wait";
  String get recordingTitle => "Good Night";
  String get removeJewelryContent => "Remove tight cloths, watches and jewelry.\nEnsure that the finger nail is trimmed.\nRemove artificial nail or colored nail polish from the monitored finger.\nUse the MORE button to see more details.";
  String get removeJewelryTitle => "Remove Jewelry";
  String get startRecordingContent => "Once the device has been properly put on, the WatchPAT™ is ready to start recording. Have a good night sleep.\nIf you need to get up during the night, do not remove the device or sensors.\nDo leave the phone behind, connected  to the charger.";
  String get startRecordingTitle => "Start Recording";
  String get stepperOf => "of";
  String get stepperStep => "Step";
  String get strapWristContent => "You will be putting the WatchPAT on your non-dominant hand. \nPlace the WatchPAT on a flat surface. \nInsert your hand and close the strap, making sure its snug but not too  tight.";
  String get strapWristTitle => "Strap Wrist Device";
  String get thankYouContent => "The data has been successfully uploaded and the test is over.\nPlease dispose the product by your local guidance's.";
  String get thankYouTitle => "Thank You";
  String get uploadingContent => "Please do not close the application while the data is being uploaded.\nThe data transmission will be over in several minutes.";
  String get uploadingTitle => "Good Morning";
  String get welcomeContent => "You are using an Application that works with the WatchPAT® device in collecting your sleep data for your physician.\nYou are about to start a few minutes of pre-sleep setup activities, after which the WatchPAT  will start its role, and you can start you good night sleep.";
  String get welcomeTitle => "Welcome";
  String stepper(String step, String total) => "Step $step of $total";
}

class $en extends S {
  const $en();
}

class GeneratedLocalizationsDelegate extends LocalizationsDelegate<S> {
  const GeneratedLocalizationsDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale("en", ""),
    ];
  }

  LocaleListResolutionCallback listResolution({Locale fallback, bool withCountry = true}) {
    return (List<Locale> locales, Iterable<Locale> supported) {
      if (locales == null || locales.isEmpty) {
        return fallback ?? supported.first;
      } else {
        return _resolve(locales.first, fallback, supported, withCountry);
      }
    };
  }

  LocaleResolutionCallback resolution({Locale fallback, bool withCountry = true}) {
    return (Locale locale, Iterable<Locale> supported) {
      return _resolve(locale, fallback, supported, withCountry);
    };
  }

  @override
  Future<S> load(Locale locale) {
    final String lang = getLang(locale);
    if (lang != null) {
      switch (lang) {
        case "en":
          return SynchronousFuture<S>(const $en());
        default:
          // NO-OP.
      }
    }
    return SynchronousFuture<S>(const S());
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale, true);

  @override
  bool shouldReload(GeneratedLocalizationsDelegate old) => false;

  ///
  /// Internal method to resolve a locale from a list of locales.
  ///
  Locale _resolve(Locale locale, Locale fallback, Iterable<Locale> supported, bool withCountry) {
    if (locale == null || !_isSupported(locale, withCountry)) {
      return fallback ?? supported.first;
    }

    final Locale languageLocale = Locale(locale.languageCode, "");
    if (supported.contains(locale)) {
      return locale;
    } else if (supported.contains(languageLocale)) {
      return languageLocale;
    } else {
      final Locale fallbackLocale = fallback ?? supported.first;
      return fallbackLocale;
    }
  }

  ///
  /// Returns true if the specified locale is supported, false otherwise.
  ///
  bool _isSupported(Locale locale, bool withCountry) {
    if (locale != null) {
      for (Locale supportedLocale in supportedLocales) {
        // Language must always match both locales.
        if (supportedLocale.languageCode != locale.languageCode) {
          continue;
        }

        // If country code matches, return this locale.
        if (supportedLocale.countryCode == locale.countryCode) {
          return true;
        }

        // If no country requirement is requested, check if this locale has no country.
        if (true != withCountry && (supportedLocale.countryCode == null || supportedLocale.countryCode.isEmpty)) {
          return true;
        }
      }
    }
    return false;
  }
}

String getLang(Locale l) => l == null
  ? null
  : l.countryCode != null && l.countryCode.isEmpty
    ? l.languageCode
    : l.toString();

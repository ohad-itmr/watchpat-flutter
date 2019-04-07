enum ErrorScreenError { BATTERY_LOW_LEVEL_NOT_CHARGING }

class ErrorScreenErrors {
  static String getTextFromEnumStringValue(String value) {
    final ErrorScreenError en =
        ErrorScreenError.values.firstWhere((v) => v.toString() == value);
    return _errorTexts[en];
  }

  static const Map<ErrorScreenError, String> _errorTexts = {
    ErrorScreenError.BATTERY_LOW_LEVEL_NOT_CHARGING:
        "Your phone has battery level below 95% and not connected to a charger. Please connect a charger to start test."
  };
}

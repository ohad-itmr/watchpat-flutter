class PatientPolicyModel {
  String _errorHandler;
  int _numberOfRetries;
  String _pinType;
  bool _dataTimeLogging;
  double _timeTillTheEnd;

  String get errorHandler => _errorHandler;

  int get numberOfRetries => _numberOfRetries;

  String get pinType => _pinType;

  bool get dataTimeLogging => _dataTimeLogging;

  double get timeTillTheEnd => _timeTillTheEnd;

  PatientPolicyModel.fromJson(Map<String, dynamic> json)
      : _errorHandler = json['errorHandler'],
        _numberOfRetries = json['numberOfRetries'],
        _pinType = json['pinTipe'],
        _dataTimeLogging = json['dataTimeLogging'],
        _timeTillTheEnd = json['timeTillTheEnd'];
}

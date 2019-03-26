class PatientPolicyModel {
  String _errorHandler;
  int _numberOfRetries;
  String _pinType;

  String get errorHandler => _errorHandler;

  int get numberOfRetries => _numberOfRetries;

  String get pinType => _pinType;

  PatientPolicyModel.fromJson(Map<String, dynamic> json)
      : _errorHandler = json['errorHandler'],
        _numberOfRetries = json['numberOfRetries'],
        _pinType = json['pinTipe'];
}

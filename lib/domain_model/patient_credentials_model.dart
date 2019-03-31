class PatientCredentialsModel {
  String _root;
  String _host;
  int _port;
  String _username;
  String _password;

  String get host => _host;

  String get root => _root;

  String get username => _username;

  String get password => _password;

  int get port => _port;

  PatientCredentialsModel.fromJson(Map<String, dynamic> json)
      : _host = json['host'],
        _root = json['root'],
        _port = int.parse(json['port']),
        _username = json['username'],
        _password = json['password'];
}

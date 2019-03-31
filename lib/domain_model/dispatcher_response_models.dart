import 'package:my_pat/domain_model/patient_credentials_model.dart';
import 'package:my_pat/domain_model/patient_policy_model.dart';

abstract class DispatcherResponse {
  bool error;
  String message;
}

class GetConfigurationResponseModel extends DispatcherResponse {
  PatientPolicyModel policy;
  bool error;
  String message;

  GetConfigurationResponseModel.fromJson(Map<String, dynamic> json)
      : error = json['error'],
        message = json['message'] ?? '',
        policy = !json['error'] ? PatientPolicyModel.fromJson(json['policy']) : null;
}

class AuthenticateUserResponseModel extends DispatcherResponse {
  bool error;
  String message;
  PatientCredentialsModel credentials;

  AuthenticateUserResponseModel.fromJson(Map<String, dynamic> json)
      : error = json['error'],
        message = json['message'] ?? '',
        credentials = !json['error']
            ? PatientCredentialsModel.fromJson(json['credentials'])
            : null;
}

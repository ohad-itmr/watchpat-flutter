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

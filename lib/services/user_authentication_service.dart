import 'package:my_pat/domain_model/dispatcher_response_models.dart';
import 'package:my_pat/domain_model/patient_policy_model.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/log/log.dart';
import 'package:my_pat/domain_model/patient_credentials_model.dart';

enum AuthErrors { NoError, TryAgain, AuthFailed, SftpCommError }

class UserAuthenticationService {
  static const TAG = 'UserAuthenticationService';

  PatientPolicyModel _patientPolicy;

  AuthErrors _sftpAuthError = AuthErrors.NoError;

  String get pinType => _patientPolicy.pinType;

  String get errorHandler => _patientPolicy.errorHandler;

  int get retryNumber => _patientPolicy.numberOfRetries;

  AuthErrors get sftpAuthError => _sftpAuthError;

  String get sftpHost => PrefsProvider.loadSftpHost();

  int get sftpPort => PrefsProvider.loadSftpPort();

  String get sftpUserName => PrefsProvider.loadSftpUsername();

  String get sftpPassword => PrefsProvider.loadSftpPassword();

  String get sftPath => PrefsProvider.loadSftpPath();

  void setPatientPolicy(Map<String, dynamic> response) {
    if (!response['error']) {
      _patientPolicy = PatientPolicyModel.fromJson(response['policy']);
      Log.info(TAG, 'Patient policy successfully set up');
    } else {
      Log.shout(TAG, "Failed to get patient policy: ${response['message']}");
    }
  }

  void setSftpParams(PatientCredentialsModel credentials) {
    Log.info(TAG, "setting sftp params");
    PrefsProvider.saveSftpHost(credentials.host);
    PrefsProvider.saveSftpPort(credentials.port);
    PrefsProvider.saveSftpPassword(credentials.password);
    PrefsProvider.saveSftpUsername(credentials.username);
    PrefsProvider.saveSftpPath(credentials.root);

//    Log.info(
//        TAG,
//        "SFTP PARAMS \n -------------------- \n"
//        "HOST: ${credentials.host} \n"
//        "PORT: ${credentials.port} \n"
//        "USERNAME: ${credentials.username} \n"
//        "PASSWORD: ${credentials.password} \n"
//        "ROOT: ${credentials.root}");
  }
}

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:my_pat/domain_model/dispatcher_response_models.dart';
import 'package:my_pat/domain_model/patient_credentials_model.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/http/http_exception.dart';
import 'package:my_pat/utils/log/dio_logger.dart';

class DispatcherService {
  static const String TAG = 'DispatcherService';

  Dio _dio = new Dio();

  DispatcherService() {
    _dio.interceptors
        .add(InterceptorsWrapper(onRequest: (RequestOptions options) async {
      DioLogger.onSend(TAG, options);
      return options;
    }, onResponse: (Response response) {
      DioLogger.onSuccess(TAG, response);
      return response;
    }, onError: (DioError error) {
      DioLogger.onError(TAG, error);
      return _dio.resolve({"error": true, "message": error.message});
    }));
  }

  static final String _dispatcherUrl = GlobalSettings.dispatcherLink;
  final String _testEndpoint = '$_dispatcherUrl/test';
  final String _checkExternalConfigEndpoint = '$_dispatcherUrl/watchpat/isConfigEnabled';
  final String _getDefaultConfigEndpoint = '$_dispatcherUrl/watchpat/getDefaultConfig';
  final String _getConfigEndpoint = '$_dispatcherUrl/api/getConfiguration';
  final String _authenticationEndPoint = '$_dispatcherUrl/api/authentication';
  final String _testCompleteEndpoint = '$_dispatcherUrl/test/done';

  Future<bool> checkDispatcherAlive() async {
    Response response = await _dio.get(_testEndpoint);
    return response.data['test'] == 'ok';
  }

  Future<bool> checkExternalConfig() async {
    Response response = await _dio.post(_checkExternalConfigEndpoint,
        data: {"client": "WatchPAT", "version": "0.0.1"});
    return ExternalConfigEnabledModel.fromJson(response.data).enabled;
  }

  Future<Map<String, dynamic>> getExternalConfig() async {
    Response response = await _dio.post(_getDefaultConfigEndpoint,
        data: {"client": "WatchPAT", "version": "0.0.1"});
    return response.data;
  }

  void sendGetConfig(String serialNumber) async {
    Response response = await _dio.get('$_getConfigEndpoint/$serialNumber');
    sl<UserAuthenticationService>()
        .setConfigParams(GetConfigurationResponseModel.fromJson(response.data));
  }

  Future<AuthenticateUserResponseModel> sendAuthenticatePatient(
      String serialNumber, String pin) async {
    Response response = await _dio
        .post(_authenticationEndPoint, data: {"sn": serialNumber, "pin": pin});
    return AuthenticateUserResponseModel.fromJson(response.data);
  }

  void sendTestComplete(String serialNumber) async {
    await _dio.get('$_testCompleteEndpoint/$serialNumber');
  }
}

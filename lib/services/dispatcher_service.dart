import 'dart:async';
import 'package:dio/dio.dart';
import 'package:my_pat/domain_model/dispatcher_response_models.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/log/dio_logger.dart';

class DispatcherService {
  static const String TAG = 'DispatcherService';
  static const String DISPATCHER_ERROR_STATUS = "666";
  static const String SN_NOT_REGISTERED_ERROR_STATUS = "99";
  static const String NO_PIN_RETRIES = "2";
  static const int DIO_CONNECT_TIMEOUT = 10000;
  static const int DIO_RECEIVE_TIMEOUT = 5000;

  Dio _dio = new Dio(options);

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
      return _dio.resolve({"error": true, "message": DISPATCHER_ERROR_STATUS});
    }));
  }

  static final String _dispatcherUrl = GlobalSettings.dispatcherLink;
  final String _testEndpoint = '$_dispatcherUrl/test';
  final String _checkExternalConfigEndpoint =
      '$_dispatcherUrl/watchpat/isConfigEnabled';
  final String _getDefaultConfigEndpoint =
      '$_dispatcherUrl/watchpat/getDefaultConfig';
  final String _getPatientPolicy = '$_dispatcherUrl/watchpat/policy';
  final String _authenticationEndPoint =
      '$_dispatcherUrl/watchpat/authenticate';
  final String _testCompleteEndpoint = '$_dispatcherUrl/test/done';

  Future<bool> checkDispatcherAlive() async {
    Response response = await _dio.get(_testEndpoint);
    return response.data['test'] == 'ok';
  }

  Future<bool> checkExternalConfig() async {
    Response response = await _dio.post(_checkExternalConfigEndpoint,
        data: {"client": "iOS APP", "version": "1"});
    return ExternalConfigEnabledModel.fromJson(response.data).enabled;
  }

  Future<Map<String, dynamic>> getExternalConfig() async {
    Response response = await _dio.post(_getDefaultConfigEndpoint,
        data: {"client": "iOS APP", "version": "1"});
    return response.data;
  }

  Future<DispatcherResponse> getPatientPolicy(String serialNumber) async {
    Response response = await _dio.post('$_getPatientPolicy/$serialNumber',
        data: {"client": "iOS APP", "version": "1"});
    sl<UserAuthenticationService>().setPatientPolicy(response.data);
    return GeneralResponse.fromJson(response.data);
  }

  Future<AuthenticateUserResponseModel> sendAuthenticatePatient(
      String serialNumber, String pin) async {
    Response response = await _dio.post(
        "$_authenticationEndPoint/$serialNumber",
        data: {"pin": pin, "client": "iOS APP", "version": "1"});
    return AuthenticateUserResponseModel.fromJson(response.data);
  }

  void sendTestComplete(String serialNumber) async {
    await _dio.get('$_testCompleteEndpoint/$serialNumber');
  }

  static BaseOptions options = new BaseOptions(
      connectTimeout: DIO_CONNECT_TIMEOUT, receiveTimeout: DIO_RECEIVE_TIMEOUT);
}

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:my_pat/domain_model/dispatcher_response_models.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/log/dio_logger.dart';
import 'package:my_pat/utils/log/log.dart';

class DispatcherService {
  static const String TAG = 'DispatcherService';
  static const String DISPATCHER_ERROR_STATUS = "666";
  static const String SN_NOT_REGISTERED_ERROR_STATUS = "99";
  static const String NO_PIN_RETRIES = "2";
  static const int DIO_CONNECT_TIMEOUT = 10000;
  static const int DIO_RECEIVE_TIMEOUT = 5000;

  Dio _dio = new Dio(options);

  DispatcherService() {
    _dio.interceptors.add(InterceptorsWrapper(onRequest: (RequestOptions options) async {
      DioLogger.onSend(TAG, options);
      return options;
    }, onResponse: (Response response) {
      DioLogger.onSuccess(TAG, response);
      return response;
    }, onError: (DioError error) {
      DioLogger.onError(TAG, error);
      return _dio.reject(error);
    }));
    PrefsProvider.saveDispatcherUrlIndex(0);
  }

  static String get _dispatcherUrl =>
      GlobalSettings.getDispatcherLink(PrefsProvider.loadDispatcherUrlIndex());

  final String _checkExternalConfigEndpoint = '/watchpat/isConfigEnabled';
  final String _getDefaultConfigEndpoint = '/watchpat/getDefaultConfig';
  final String _getPatientPolicy = '/watchpat/policy';
  final String _authenticationEndPoint = '/watchpat/authenticate';
  final String _testCompleteEndpoint = '/test/done';

  // Generic method to send http request and try different dispatchers in case of failure
  Future<Response> _sendRequest(
      {@required String urlSuffix,
      @required RequestMethod method,
      Map<String, String> data}) async {
    try {
      if (method == RequestMethod.post) {
        return await _dio.post("$_dispatcherUrl$urlSuffix", data: data);
      } else if (method == RequestMethod.get) {
        return await _dio.get("$_dispatcherUrl$urlSuffix");
      } else {
        return null;
      }
    } catch (e) {
      Log.shout(TAG, "Failed to connect to dispatcher $_dispatcherUrl, ${e.toString()}");
      if (_moreDispatchersAvailable) {
        await PrefsProvider.incrementDispatcherUrlIndex();
        Log.info(TAG, "Reconnecting to another dispatcher $_dispatcherUrl");
        return await _sendRequest(urlSuffix: urlSuffix, method: method, data: data);
      } else {
        return _dio.resolve({"error": true, "message": DISPATCHER_ERROR_STATUS});
      }
    }
  }

  bool get _moreDispatchersAvailable =>
      PrefsProvider.loadDispatcherUrlIndex() < (GlobalSettings.dispatcherUrlsAmount - 1);

  Future<bool> checkExternalConfig() async {
    Response response = await _sendRequest(
        method: RequestMethod.post,
        urlSuffix: _checkExternalConfigEndpoint,
        data: {"client": "iOS APP", "version": "1"});
    return ExternalConfigEnabledModel.fromJson(response.data).enabled;
  }

  Future<Map<String, dynamic>> getExternalConfig() async {
    Response response = await _sendRequest(
        method: RequestMethod.post,
        urlSuffix: _getDefaultConfigEndpoint,
        data: {"client": "iOS APP", "version": "1"});
    return response.data;
  }

  Future<DispatcherResponse> getPatientPolicy(String serialNumber) async {
    Response response = await _sendRequest(
        urlSuffix: '$_getPatientPolicy/$serialNumber',
        method: RequestMethod.post,
        data: {"client": "iOS APP", "version": "1"});
    sl<UserAuthenticationService>().setPatientPolicy(response.data);
    return GeneralResponse.fromJson(response.data);
  }

  Future<AuthenticateUserResponseModel> sendAuthenticatePatient(
      String serialNumber, String pin) async {
    Response response = await _sendRequest(
        urlSuffix: "$_authenticationEndPoint/$serialNumber",
        method: RequestMethod.post,
        data: {"pin": pin, "client": "iOS APP", "version": "1"});
    return AuthenticateUserResponseModel.fromJson(response.data);
  }

  void sendTestComplete(String serialNumber) async {
    await _sendRequest(
        urlSuffix: '$_testCompleteEndpoint/$serialNumber', method: RequestMethod.get);
  }

  static BaseOptions options =
      new BaseOptions(connectTimeout: DIO_CONNECT_TIMEOUT, receiveTimeout: DIO_RECEIVE_TIMEOUT);
}

enum RequestMethod { get, post }

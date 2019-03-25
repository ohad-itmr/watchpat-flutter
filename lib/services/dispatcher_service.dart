import 'dart:async';
import 'package:dio/dio.dart';
import 'package:my_pat/services/services.dart';
import 'package:my_pat/utils/http/http_exception.dart';
import 'package:my_pat/utils/log/dio_logger.dart';

class DispatcherService {
  static const String TAG = 'DispatcherService';

  Dio _dio = new Dio();

  DispatcherService() {
    _dio.interceptors.add(InterceptorsWrapper(onRequest: (RequestOptions options) async {
      DioLogger.onSend(TAG, options);
      return options;
    }, onResponse: (Response response) {
      DioLogger.onSuccess(TAG, response);
      return response;
    }, onError: (DioError error) {
      DioLogger.onError(TAG, error);
      return error;
    }));
  }

  static final String _dispatcherUrl = GlobalSettings.dispatcherLink;
  final String _testEndpoint = '$_dispatcherUrl/test';

  Future<bool> checkDispatcherAlive() async {
    Response response = await _dio.get(_testEndpoint);
    throwIfNoSuccess(response);
    return response.data['test'] == 'ok';
  }

  void throwIfNoSuccess(Response response) {
    if (response.statusCode < 200 || response.statusCode > 299) {
      throw new HttpException(response);
    }
  }
}

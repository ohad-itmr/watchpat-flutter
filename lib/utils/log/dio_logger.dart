import 'package:dio/dio.dart';
import 'log.dart';

class DioLogger {
  static void onSend(String tag, RequestOptions options) {
    Log.info(tag, 'Request Path : [${options.method}] ${options.baseUrl}${options.path}');
    Log.info(tag, 'Request Data : ${options.data}');
  }

  static void onSuccess(String tag, Response response) {
    Log.info(tag,
        'Response Path : [${response.request.method}] ${response.request.baseUrl}${response.request.path} Request Data : ${response.request.data.toString()}');
    Log.info(tag, 'Response statusCode : ${response.statusCode}');
    Log.info(tag, 'Response data : ${_filterOutSensitiveData(response.data)}');
  }

  static void onError(String tag, DioError error) {
    if (null != error.response) {
      Log.info(tag,
          'Error Path : [${error.response.request.method}] ${error.response.request.baseUrl}${error.response.request.path} Request Data : ${error.response.request.data.toString()}');
      Log.info(tag, 'Error statusCode : ${error.response.statusCode}');
      Log.info(
          tag, 'Error data : ${null != error.response.data ? error.response.data.toString() : ''}');
    }
    Log.info(tag, 'Error Message : ${error.message}');
  }

  static String _filterOutSensitiveData(Map<String, dynamic> d) {
    final data = Map.from(d);
    if (data['credentials'] != null) {
      print("SFTP CREDENTIALS: ${data['credentials']}");
      data.remove('credentials');
    }
    return data.toString();
  }
}

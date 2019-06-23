import 'package:meta/meta.dart';

class Response {
  final bool success;
  final String message;
  final String error;

  Response({@required this.success, this.message, this.error});

  Response.fromJSON(Map<String, dynamic> json)
      : success = json['success'],
        message = json['message'],
        error = json['error'];
}

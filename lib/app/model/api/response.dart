import 'package:meta/meta.dart';

class Response {
  final bool success;
  final String message;
  final String error;

  Response({@required this.success, this.message, this.error});
}

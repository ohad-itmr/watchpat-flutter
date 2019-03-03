import 'dart:async';
import 'package:my_pat/utility/network/network_check.dart';

class NetworkProvider {
  final NetworkCheck _networkCheck = NetworkCheck();

  Future<bool> get internetExists async {
    return await _networkCheck.check();
  }
  
  
}

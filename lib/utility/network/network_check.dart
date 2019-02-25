import 'package:connectivity/connectivity.dart';
import 'dart:async';

class NetworkCheck {
  Future<bool> check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

  Future<bool> checkInternet(Function func) {
    return check().then((internet) => internet != null && internet);
  }
}

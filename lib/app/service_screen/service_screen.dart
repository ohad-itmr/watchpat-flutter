import 'package:flutter/material.dart';
import 'package:my_pat/widgets/widgets.dart';

class ServiceScreen extends StatefulWidget {
  static const String TAG = 'ServiceScreen';
  static const String PATH = '/service';

  @override
  _ServiceScreenState createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  @override
  Widget build(BuildContext context) {
    return MainTemplate(
      title: "Service mode",
      showBack: false,
    );
  }
}

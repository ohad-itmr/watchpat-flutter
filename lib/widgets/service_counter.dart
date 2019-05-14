import 'package:flutter/material.dart';
import 'package:my_pat/service_locator.dart';

class ServiceCounter extends StatelessWidget {
  final _manager = sl<ServiceScreenManager>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _manager.counter,
      initialData: "",
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(snapshot.data,
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }
}

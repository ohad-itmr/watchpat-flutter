import 'package:flutter/material.dart';
import 'package:my_pat/services/services.dart';

import '../service_locator.dart';

class MyPatProgressIndicator extends StatelessWidget {
  DataWritingService _dataWritingService = sl<DataWritingService>();

  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.of(context).size.width;
    return StreamBuilder(
      stream: _dataWritingService.remainingDataProgressStream,
      initialData: 0.0,
      builder: (context, AsyncSnapshot<double> snapshot) {
        return LinearProgressIndicator(
          value: snapshot.data,
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.15),
        );
      },
    );
  }
}

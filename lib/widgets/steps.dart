import 'package:flutter/material.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/generated/l10n.dart';

class Steps extends StatelessWidget {
  final int current;
  final int total;
  final bool showSteps;
  final S loc = sl<S>();

  Steps({this.current, this.total, this.showSteps});

  @override
  Widget build(BuildContext context) {
    final String str = '${loc.stepper('$current','$total')}';

    return Container(
      padding: EdgeInsets.symmetric(vertical: 7.0),
      child: showSteps?Text(str):Text(''),
    );
  }
}

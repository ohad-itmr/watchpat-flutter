import 'package:flutter/material.dart';
import '../../generated/i18n.dart';


class Steps extends StatelessWidget {
  final int current;
  final int total;
  final bool showSteps;

  Steps({this.current, this.total, this.showSteps});

  @override
  Widget build(BuildContext context) {
    final S loc = S.of(context);
    final String str = '${loc.stepper('$current','$total')}';

    return Container(
      padding: EdgeInsets.symmetric(vertical: 7.0),
      child: showSteps?Text(str):Text(''),
    );
  }
}

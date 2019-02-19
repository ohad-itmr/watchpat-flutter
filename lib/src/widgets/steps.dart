import 'package:flutter/material.dart';
import '../helpers/localizations.dart';

class Steps extends StatelessWidget {
  final int current;
  final int total;
  final bool showSteps;

  Steps({this.current, this.total, this.showSteps});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);
    final String str = '${loc.stepperStep} $current ${loc.stepperOf} $total';

    return Container(
      padding: EdgeInsets.symmetric(vertical: 7.0),
      child: showSteps?Text(str):Text(''),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/utils/FirmwareUpgrader.dart';
import 'package:my_pat/widgets/mypat_progress_indicator.dart';

class FirmwareUpgradeDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: StreamBuilder(
        stream: sl<FirmwareUpgrader>().updateProgressStream,
        initialData: 0.0,
        builder: (_, AsyncSnapshot<double> snapshot) {
          return Container(
            height: MediaQuery.of(context).size.width / 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(S.of(context).firmware_upgrading),
                CustomPaint(
                  size: Size(120, 16),
                  painter: ProgressPainter(
                      progress: snapshot.data,
                      color: Theme.of(context).accentColor),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

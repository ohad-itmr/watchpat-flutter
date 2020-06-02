import 'package:flutter/material.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/generated/l10n.dart';

class IgnoreDeviceErrorsDialog extends StatefulWidget {
  @override
  _IgnoreDeviceErrorsDialogState createState() => _IgnoreDeviceErrorsDialogState();
}

class _IgnoreDeviceErrorsDialogState extends State<IgnoreDeviceErrorsDialog> {
  final S _loc = sl<S>();
  bool _isIgnoring = PrefsProvider.getIgnoreDeviceErrors();

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text(_loc.ignore_device_errors),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RadioListTile(
                groupValue: true,
                value: _isIgnoring,
                onChanged: (bool val) => setState(() => _isIgnoring = !val),
                title: Text("ON"),
              ),
              RadioListTile(
                groupValue: true,
                value: !_isIgnoring,
                onChanged: (bool val) => setState(() => _isIgnoring = val),
                title: Text("OFF"),
              ),
            ],
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                PrefsProvider.setIgnoreDeviceErrors(_isIgnoring);
                Navigator.pop(context);
              },
              child: Text(_loc.ok.toUpperCase()),
            )
          ],
        );
      },
    );
  }
}

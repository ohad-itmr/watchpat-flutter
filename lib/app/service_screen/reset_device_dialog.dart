import 'package:flutter/material.dart';

import '../../service_locator.dart';

class ResetDeviceDialog extends StatefulWidget {
  @override
  _ResetDeviceDialogState createState() => _ResetDeviceDialogState();
}

class _ResetDeviceDialogState extends State<ResetDeviceDialog> {
  final _manager = sl<ServiceScreenManager>();
  final S _loc = sl<S>();
  ResetType _selectedType = ResetType.shut_reset;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        title: Text(_loc.select_reset_type),
        content: DropdownButton<ResetType>(
          value: _selectedType,
          onChanged: (ResetType type) => setState(() => _selectedType = type),
          items: _manager.resetOptions
              .map((ResetOption o) => DropdownMenuItem<ResetType>(
                    value: o.type,
                    child: Text(o.title),
                  ))
              .toList(),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_loc.cancel.toUpperCase()),
          ),
          FlatButton(
            onPressed: () {
              _manager.resetMainDevice(_selectedType);
              Navigator.pop(context);
            },
            child: Text(_loc.reset.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      );
    });
  }
}

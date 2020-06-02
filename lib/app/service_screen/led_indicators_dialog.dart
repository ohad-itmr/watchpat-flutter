import 'package:flutter/material.dart';
import '../../service_locator.dart';
import 'package:my_pat/generated/l10n.dart';

class LedIndicatorsDialog extends StatefulWidget {
  @override
  _LedIndicatorsDialogState createState() => _LedIndicatorsDialogState();
}

class _LedIndicatorsDialogState extends State<LedIndicatorsDialog> {
  final _manager = sl<ServiceScreenManager>();
  final S _loc = sl<S>();
  LedColorOption _selectedOption;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        title: Text(_loc.select_led_color),
        content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _manager.ledOptions
                .map((LedOption option) => RadioListTile(
                      title: Text(option.title),
                      value: _selectedOption == option.color,
                      onChanged: (_) =>
                          setState(() => _selectedOption = option.color),
                      groupValue: true,
                    ))
                .toList()),
        actions: <Widget>[
          FlatButton(
            child: Text(_loc.cancel.toUpperCase()),
            onPressed: () => Navigator.pop(context),
          ),
          FlatButton(
            child: Text(_loc.set.toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: _selectedOption != null
                ? () => _selectColor(_selectedOption)
                : null,
          )
        ],
      );
    });
  }

  void _selectColor(LedColorOption o) {
    _manager.setLedColor(o);
    Navigator.pop(context);
  }
}

import 'dart:io';

import 'package:flutter/material.dart';

import '../../service_locator.dart';

class SelectDispatcherDialog extends StatefulWidget {
  @override
  _SelectDispatcherDialog createState() => _SelectDispatcherDialog();
}

class _SelectDispatcherDialog extends State<SelectDispatcherDialog> {
  final S _loc = sl<S>();
  String _selectedUrl = PrefsProvider.loadDispatcherURL();

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        title: Text(_loc.select_dispatcher_title),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_loc.select_dispatcher_text),
          ...GlobalSettings.dispatchersUrls
              .map((String url) => RadioListTile(
                    title: Text(url),
                    value: _selectedUrl == url,
                    onChanged: (_) => setState(() => _selectedUrl = url),
                    groupValue: true,
                  ))
              .toList(),
        ]),
        actions: <Widget>[
          FlatButton(
            child: Text(_loc.cancel.toUpperCase()),
            onPressed: () => Navigator.pop(context),
          ),
          FlatButton(
            child: Text(_loc.set_and_close.toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed:
                _selectedUrl != null ? () => _selectColor(_selectedUrl) : null,
          )
        ],
      );
    });
  }

  void _selectColor(String url) async {
    await PrefsProvider.saveDispatcherURL(url);
    exit(0);
  }
}

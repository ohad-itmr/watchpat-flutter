import 'dart:io';

import 'package:flutter/material.dart';

import '../../service_locator.dart';

class SelectDispatcherDialog extends StatefulWidget {
  @override
  _SelectDispatcherDialog createState() => _SelectDispatcherDialog();
}

class _SelectDispatcherDialog extends State<SelectDispatcherDialog> {
  final S _loc = sl<S>();
  int _selectedUrlIndex = PrefsProvider.loadDispatcherUrlIndex();

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        title: Text(_loc.select_dispatcher_title),
        content: Column(
            mainAxisSize: MainAxisSize.min,
            children: GlobalSettings.dispatchersUrls
                .map((String url) => RadioListTile(
                      title: Text(url),
                      value: url ==
                          GlobalSettings.getDispatcherLink(_selectedUrlIndex),
                      onChanged: (_) => setState(() {
                            _selectedUrlIndex =
                                GlobalSettings.dispatchersUrls.indexOf(url);
                            PrefsProvider.saveDispatcherUrlIndex(
                                _selectedUrlIndex);
                          }),
                      groupValue: true,
                    ))
                .toList()),
        actions: <Widget>[
          FlatButton(
            child: Text(_loc.close_app.toUpperCase()),
            onPressed: () => exit(0),
          )
        ],
      );
    });
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import '../../service_locator.dart';
import 'package:my_pat/generated/l10n.dart';

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
                .asMap()
                .map((int index, String url) => MapEntry(
                    index,
                    RadioListTile(
                        title: Text(url),
                        value: _selectedUrlIndex == index,
                        onChanged: (_) => setState(() => _selectedUrlIndex = index),
                        groupValue: true)))
                .values
                .toList()),
        actions: <Widget>[
          FlatButton(
            child: Text(S.of(context).cancel.toUpperCase()),
            onPressed: () => Navigator.pop(context),
          ),
          FlatButton(
            child: Text(_loc.btnChangeAndRestart.toUpperCase()),
            onPressed: () async {
              await PrefsProvider.saveDispatcherUrlIndex(_selectedUrlIndex);
              exit(0);
            },
          )
        ],
      );
    });
  }
}

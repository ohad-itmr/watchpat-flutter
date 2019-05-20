import 'package:flutter/material.dart';
import 'package:my_pat/app/service_screen/service_screen.dart';
import 'package:my_pat/service_locator.dart';

class ServicePasswordPrompt extends StatefulWidget {
  @override
  _ServicePasswordPromptState createState() => _ServicePasswordPromptState();
}

class _ServicePasswordPromptState extends State<ServicePasswordPrompt> {
  final _formKey = GlobalKey<FormState>();
  bool _showPasswordSelected = false;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text("Enter service password"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Form(
                key: _formKey,
                child: TextFormField(
                  obscureText: !_showPasswordSelected,
                  autofocus: true,
                  keyboardType: TextInputType.number,
//                        validator: (value) {
//                          if (value != "12345678") {
//                            _formKey.currentState.reset();
//                            return 'Password invalid';
//                          }
//                        },
                ),
              ),
              CheckboxListTile(
                title: Text("Show password"),
                controlAffinity: ListTileControlAffinity.leading,
                value: _showPasswordSelected,
                onChanged: (bool val) {
                  setState(() {
                    _showPasswordSelected = val;
                  });
                },
              )
            ],
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  sl<SystemStateManager>().setAppMode(AppModes.TECH);
                  sl<SystemStateManager>().changeState.add(StateChangeActions.APP_MODE_CHANGED);
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) =>
                          ServiceScreen(mode: ServiceMode.technician)));
                }
              },
              child: Text(S.of(context).ok.toUpperCase()),
            ),
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(S.of(context).cancel.toUpperCase()),
            )
          ],
        );
      },
    );
  }
}

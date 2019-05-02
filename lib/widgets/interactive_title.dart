import 'package:flutter/material.dart';
import 'package:my_pat/app/service_screen/service_screen.dart';
import 'package:my_pat/service_locator.dart';

class InteractiveTitle extends StatefulWidget {
  final String title;

  const InteractiveTitle({Key key, this.title}) : super(key: key);

  @override
  _InteractiveTitleState createState() => _InteractiveTitleState();
}

class _InteractiveTitleState extends State<InteractiveTitle> {
  final _manager = sl<ServiceScreenManager>();
  final _formKey = GlobalKey<FormState>();
  bool _showPasswordSelected = false;

  @override
  void initState() {
    super.initState();
    _manager.serviceModesStream.listen((mode) {
      switch (mode) {
        case ServiceMode.customer:
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ServiceScreen(mode: mode)));
          break;
        case ServiceMode.technician:
          _showPasswordPrompt();
          break;
        default:
      }
    });
  }

  void _showPasswordPrompt() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
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
                        validator: (value) {
                          if (value != "12345678") {
                            _formKey.currentState.reset();
                            return 'Password invalid';
                          }
                        },
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
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) =>
                                ServiceScreen(mode: ServiceMode.technician)));
                      }
                    },
                    child: Text("OK"),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("CANCEL"),
                  )
                ],
              );
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _manager.onTitleTap(),
      child: Text(widget.title),
    );
  }
}

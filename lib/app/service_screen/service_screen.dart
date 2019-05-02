import 'package:flutter/material.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/widgets/appbar_decoration.dart';

class ServiceScreen extends StatefulWidget {
  static const String TAG = 'ServiceScreen';
  static const String PATH = '/service';

  final ServiceMode mode;

  const ServiceScreen({Key key, @required this.mode}) : super(key: key);

  @override
  _ServiceScreenState createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  final _manager = sl<ServiceScreenManager>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.mode.toString()),
          flexibleSpace: AppBarDecoration(),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () => Navigator.pop(context),
            )
          ],
          leading: Container(),
        ),
        body: ListView.separated(
          itemCount: _manager.serviceOptions[widget.mode].length,
          padding: EdgeInsets.all(16.0),
          itemBuilder: _buildOptionTile,
          separatorBuilder: (_,__) => Divider(),
        ));
  }

  Widget _buildOptionTile(BuildContext context, int i) {
    ServiceOption option = _manager.serviceOptions[widget.mode][i];
    return ListTile(
      title: Text(option.title),
      trailing: Icon(Icons.keyboard_arrow_right),
    );
  }
}

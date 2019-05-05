import 'package:flutter/material.dart';
import 'package:my_pat/app/service_screen/perform_bit_screen.dart';
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

  Map<ServiceMode, List<ServiceOption>> _serviceOptions;
  List<ServiceOption> _customerServiceOptions;
  List<ServiceOption> _technicianServiceOptions;

  @override
  void initState() {
    _initServiceOptions();

    super.initState();
  }

  void _showServiceDialog(ServiceDialog dialog) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: dialog.title,
            content: dialog.content,
            actions: dialog.actions,
          );
        });
  }

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
          itemCount: _serviceOptions[widget.mode].length,
          itemBuilder: _buildOptionTile,
          separatorBuilder: (_, __) => Divider(),
        ));
  }

  Widget _buildOptionTile(BuildContext context, int i) {
    ServiceOption option = _serviceOptions[widget.mode][i];
    return ListTile(
      title: Text(option.title),
      trailing: Icon(Icons.keyboard_arrow_right),
      onTap: () => option.action(),
    );
  }

  Widget _buildPopButton(String text) {
    return FlatButton(
      child: Text(text),
      onPressed: () => Navigator.pop(context),
    );
  }

  Widget _buildActionButton({String text, Function action}) {
    return FlatButton(
      child: Text(text),
      onPressed: () => action(),
    );
  }

  // Show dialog with firmware version
  _showFirmwareDialog() async {
    final String version = await _manager.getFirmwareVersion();
    _showServiceDialog(ServiceDialog(
        title: Text("Firmware version"),
        content: Text(version),
        actions: [_buildPopButton("OK")]));
  }

  _retrieveStoredData() {
    _showServiceDialog(ServiceDialog(
        title: Text("Retrieve stored data"),
        content: Text("Retrieve stored data from main device?"),
        actions: [
          _buildPopButton("CANCEL"),
          _buildActionButton(
            text: "OK",
            action: _manager.retrieveAndUploadStoredData
          )
        ]));
  }

  // go to Perform BIT screen
  _showBitScreen() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => PerformBitScreen()));
  }

  _initServiceOptions() {
    _customerServiceOptions = [
      ServiceOption(
          title: "Main device FW version", action: _showFirmwareDialog),
      ServiceOption(
          title: "Retrieve test data from device and upload it to server",
          action: _retrieveStoredData),
      ServiceOption(title: "Perform BIT", action: _showBitScreen),
      ServiceOption(title: "Upgrade main device firmware", action: null),
      ServiceOption(title: "Handle parameters file", action: null)
    ];

    _technicianServiceOptions = [
      ServiceOption(title: "Handle AFE registers", action: null),
      ServiceOption(title: "Handle ACC registers", action: null),
      ServiceOption(title: "Handle main devide EEPROM", action: null),
      ServiceOption(title: "Set device serial", action: null),
      ServiceOption(title: "Sel LED indication", action: null),
      ServiceOption(title: "Get technical status", action: null),
      ServiceOption(title: "Export log file by email", action: null),
      ServiceOption(title: "Extract log file from device", action: null),
      ServiceOption(title: "Reset main device", action: null),
      ServiceOption(title: "Ignore device errors", action: null),
    ];
    _serviceOptions = {
      ServiceMode.customer: _customerServiceOptions,
      ServiceMode.technician: [
        ..._customerServiceOptions,
        ..._technicianServiceOptions
      ]
    };
  }
}

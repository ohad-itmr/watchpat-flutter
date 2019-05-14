import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_pat/app/service_screen/perform_bit_screen.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/widgets/appbar_decoration.dart';
import 'package:my_pat/widgets/mypat_toast.dart';

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
  final S _loc = sl<S>();

  Map<ServiceMode, List<ServiceOption>> _serviceOptions;
  List<ServiceOption> _customerServiceOptions;
  List<ServiceOption> _technicianServiceOptions;

  StreamSubscription _toastSub;
  StreamSubscription _progressSub;
  double _screenWidth;
  bool _progressBarShowing = false;
  bool _operationInProgress = false;

  @override
  void initState() {
    _toastSub =
        _manager.toasts.listen((String msg) => MyPatToast.show(msg, context));
    _progressSub =
        _manager.progressBar.listen((String msg) => _handleProgressBar(msg));
    _initServiceOptions();
    super.initState();
  }

  @override
  void deactivate() {
    _toastSub.cancel();
    _progressSub.cancel();
    super.deactivate();
  }

  void _handleProgressBar(String msg) {
    if (_progressBarShowing && msg == "") {
      _progressBarShowing = false;
      Navigator.pop(context);
    } else if (!_progressBarShowing && msg != "") {
      _progressBarShowing = true;
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(msg),
              content: Container(
                  height: _screenWidth / 5,
                  child: Center(child: CircularProgressIndicator())),
            );
          });
    }
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
    _screenWidth = MediaQuery.of(context).size.width;
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
          leading: _operationInProgress
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.white)))
              : Container(),
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
      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
      onPressed: () => action(),
    );
  }

  // Show dialog with firmware version
  _showFirmwareVersionDialog() async {
    final String version = await _manager.getFirmwareVersion();
    _showServiceDialog(ServiceDialog(
        title: Text(_loc.firmware_version),
        content: Text(version),
        actions: [_buildPopButton(_loc.ok.toUpperCase())]));
  }

  // Retrieve stored data and upload to server dialog
  _showRetrieveStoredDataDialog() {
    _showServiceDialog(ServiceDialog(
        title: Text(_loc.retrieve_stored_data),
        content: Text(_loc.retrieve_stored_data_from_device),
        actions: [
          _buildPopButton(_loc.cancel.toUpperCase()),
          _buildActionButton(
              text: _loc.ok.toUpperCase(),
              action: () {
                _manager.retrieveAndUploadStoredData();
                Navigator.pop(context);
              })
        ]));
  }

  // handle parameters file dialog
  _showParametersFileDialog() {
    _showServiceDialog(ServiceDialog(
      title: Text(_loc.parameters_file_title),
      actions: [
        _buildPopButton(_loc.cancel.toUpperCase()),
        Container(width: _screenWidth / 15),
        _buildActionButton(
            text: _loc.get.toUpperCase(),
            action: () {
              _manager.getParametersFile();
              Navigator.pop(context);
            }),
        _buildActionButton(
            text: _loc.set.toUpperCase(),
            action: () {
              _manager.setParametersFile();
              Navigator.pop(context);
            })
      ],
    ));
  }

  // go to Perform BIT screen
  _showBitScreen() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => PerformBitScreen()));
  }

  // Send application log file by email
  _showLogSendingDialog() {
    _showServiceDialog(ServiceDialog(
      title: Text(S.of(context).app_log_file_title),
      content: Text(
          "${S.of(context).app_log_file_text} ${GlobalSettings.serviceEmailAddress}?"),
      actions: [
        _buildPopButton(_loc.cancel.toUpperCase()),
        _buildActionButton(
            text: S.of(context).send.toUpperCase(),
            action: () => _sendLogFileByEmail())
      ],
    ));
  }

  _sendLogFileByEmail() async {
    Navigator.pop(context);
    setState(() => _operationInProgress = true);
    final result = await sl<EmailSenderService>().sendLogFile();
    MyPatToast.show(
        "Log file sending: ${result ? 'SUCCESS' : 'FAILED'}", context);
    setState(() => _operationInProgress = false);
  }

  _showBadThing() {
    MyPatToast.show("We are not quite here yet...", context);
  }

  _initServiceOptions() {
    _customerServiceOptions = [
      ServiceOption(
          title: "Main device FW version", action: _showFirmwareVersionDialog),
      ServiceOption(
          title: "Retrieve test data from device and upload it to server",
          action: _showRetrieveStoredDataDialog),
      ServiceOption(title: "Perform BIT", action: _showBitScreen),
      ServiceOption(
          title: "Upgrade main device firmware", action: _showBadThing),
      ServiceOption(
          title: "Handle parameters file", action: _showParametersFileDialog)
    ];

    _technicianServiceOptions = [
      ServiceOption(title: "Handle AFE registers", action: null),
      ServiceOption(title: "Handle ACC registers", action: null),
      ServiceOption(title: "Handle main devide EEPROM", action: null),
      ServiceOption(title: "Set device serial", action: null),
      ServiceOption(title: "Sel LED indication", action: null),
      ServiceOption(title: "Get technical status", action: null),
      ServiceOption(
          title: "Export log file by email", action: _showLogSendingDialog),
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

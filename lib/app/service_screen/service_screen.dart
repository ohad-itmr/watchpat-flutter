import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_pat/app/service_screen/ignore_errors_dialog.dart';
import 'package:my_pat/app/service_screen/led_indicators_dialog.dart';
import 'package:my_pat/app/service_screen/perform_bit_screen.dart';
import 'package:my_pat/app/service_screen/reset_device_dialog.dart';
import 'package:my_pat/app/welcome_sreen/welcome_screen.dart';
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
  StreamSubscription _deviceBtStateSub;
  double _screenWidth;
  bool _progressBarShowing = false;
  bool _operationInProgress = false;

  DeviceStates _deviceBtState;

  // device serial prompt
  final _serialFormKey = GlobalKey<FormState>();
  final _serialInputController = TextEditingController();

  @override
  void initState() {
    _toastSub =
        _manager.toasts.listen((String msg) => MyPatToast.show(msg, context));
    _progressSub =
        _manager.progressBar.listen((String msg) => _handleProgressBar(msg));
    _deviceBtStateSub = sl<SystemStateManager>()
        .deviceCommStateStream
        .listen(_handleBtStateChange);
    _initServiceOptions();
    super.initState();
  }

  @override
  void deactivate() {
    _toastSub.cancel();
    _progressSub.cancel();
    _deviceBtStateSub.cancel();
    super.deactivate();
  }

  void _handleBtStateChange(DeviceStates state) {
    setState(() => _deviceBtState = state);
    MyPatToast.show(
        "Main device ${state == DeviceStates.CONNECTED ? 'CONNECTED' : 'DISCONNECTED'}",
        context);
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
          title: Text(widget.mode == ServiceMode.customer
              ? "Customer service mode"
              : "Technician mode"),
          flexibleSpace: AppBarDecoration(),
          leading: IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => Navigator.pop(context),
          ),
          actions: <Widget>[
            _operationInProgress
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(
                        valueColor:
                            new AlwaysStoppedAnimation<Color>(Colors.white)))
                : Container()
          ]),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/gears_primary.png'),
            colorFilter: ColorFilter.mode(
                Color.fromRGBO(255, 255, 255, 0.2), BlendMode.modulate),
          ),
        ),
        child: ListView.separated(
          itemCount: _serviceOptions[widget.mode].length,
          itemBuilder: _buildOptionTile,
          separatorBuilder: (_, __) => Divider(),
        ),
      ),
      resizeToAvoidBottomPadding: false,
    );
  }

  Widget _buildOptionTile(BuildContext context, int i) {
    ServiceOption option = _serviceOptions[widget.mode][i];
    return ListTile(
      title: Text(option.title),
      trailing: Icon(Icons.keyboard_arrow_right),
      onTap: _deviceBtState == DeviceStates.CONNECTED || option.action == _showResetApplicationDialog
          ? () => option.action()
          : () => MyPatToast.show("Main device disconnected", context),
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

  // Send log file by email
  _sendLogFileByEmail() async {
    Navigator.pop(context);
    setState(() => _operationInProgress = true);
    final result = await sl<EmailSenderService>().sendLogFile();
    MyPatToast.show(
        "Log file sending: ${result ? 'SUCCESS' : 'FAILED'}", context);
    setState(() => _operationInProgress = false);
  }

  // Handle AFE registers
  _showAfeRegistersDialog() {
    _showServiceDialog(ServiceDialog(
      title: Text(_loc.afe_registers_description),
      actions: [
        _buildPopButton(_loc.cancel.toUpperCase()),
        Container(width: _screenWidth / 15),
        _buildActionButton(
            text: _loc.get.toUpperCase(),
            action: () {
              _manager.getAfeRegisters();
              Navigator.pop(context);
            }),
        _buildActionButton(
            text: _loc.set.toUpperCase(),
            action: () {
              _manager.setAfeRegisters();
              Navigator.pop(context);
            })
      ],
    ));
  }

  // Handle ACC registers
  _showAccRegistersDialog() {
    _showServiceDialog(ServiceDialog(
      title: Text(_loc.acc_registers),
      actions: [
        _buildPopButton(_loc.cancel.toUpperCase()),
        Container(width: _screenWidth / 15),
        _buildActionButton(
            text: _loc.get.toUpperCase(),
            action: () {
              _manager.getAccRegisters();
              Navigator.pop(context);
            }),
        _buildActionButton(
            text: _loc.set.toUpperCase(),
            action: () {
              _manager.setAccRegisters();
              Navigator.pop(context);
            })
      ],
    ));
  }

  // Hanlde device EEPROM
  _showEepromDialog() {
    _showServiceDialog(ServiceDialog(
      title: Text(_loc.upat_eeprom),
      actions: [
        _buildPopButton(_loc.cancel.toUpperCase()),
        Container(width: _screenWidth / 15),
        _buildActionButton(
            text: _loc.get.toUpperCase(),
            action: () {
              _manager.getEEPROMvalues();
              Navigator.pop(context);
            }),
        _buildActionButton(
            text: _loc.set.toUpperCase(),
            action: () {
              _manager.setEEPROMValues();
              Navigator.pop(context);
            })
      ],
    ));
  }

  // Set device serial
  _showDeviceSerialDialog() {
    _showServiceDialog(ServiceDialog(
        title: Text(_loc.set_serial),
        content: Form(
          key: _serialFormKey,
          child: TextFormField(
            controller: _serialInputController,
            autofocus: true,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value.length != 9) {
                _serialFormKey.currentState.reset();
                return 'Serial should contain 9 digits';
              }
            },
          ),
        ),
        actions: [
          _buildPopButton(_loc.cancel.toUpperCase()),
          _buildActionButton(
              text: _loc.set.toUpperCase(),
              action: () {
                if (_serialFormKey.currentState.validate()) {
                  _manager.setDeviceSerial(_serialInputController.value.text);
                  _serialInputController.clear();
                  Navigator.pop(context);
                }
              }),
        ]));
  }

  // Set LED indicators
  _showSetLedDialog() {
    showDialog(context: context, builder: (_) => LedIndicatorsDialog());
  }

  // Tech status report
  _performTechStatusReport() async {
    final String res = await _manager.techStatusReport();
    _showServiceDialog(ServiceDialog(
        content: Text(res), actions: [_buildPopButton(_loc.ok.toUpperCase())]));
  }

  // Reset main device
  _showResetDeviceDialog() {
    showDialog(context: context, builder: (_) => ResetDeviceDialog());
  }

  // Ignore device errors
  _showIgnoreDeviceErrorsDialog() {
    showDialog(context: context, builder: (_) => IgnoreDeviceErrorsDialog());
  }

  // Firmware upgrade from documents directory
  _showFWUpgradeDialog() {
    _showServiceDialog(ServiceDialog(
        content: Text(
            S.of(context).make_sure_watchpat_bin_is_placed_in_watchpat_dir),
        actions: [
          _buildPopButton(S.of(context).cancel.toUpperCase()),
          _buildActionButton(
              text: S.of(context).upgrade.toUpperCase(),
              action: () {
                _manager.upgradeFirmware();
                Navigator.pop(context);
              })
        ]));
  }

  _showResetApplicationDialog() {
    _showServiceDialog(ServiceDialog(
        title: Text(S.of(context).reset_application_title),
        content: Text(S.of(context).reset_application_prompt),
        actions: [
          _buildPopButton(S.of(context).cancel.toUpperCase()),
          _buildActionButton(
              text: S.of(context).reset.toUpperCase(),
              action: () {
                _manager.resetApplication();
                Navigator.popUntil(
                    context, (Route<dynamic> route) => route.isFirst);
                Navigator.of(context).pushNamed(WelcomeScreen.PATH);
              })
        ]));
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
          title: "Upgrade main device firmware", action: _showFWUpgradeDialog),
      ServiceOption(
          title: "Handle parameters file", action: _showParametersFileDialog)
    ];

    _technicianServiceOptions = [
      ServiceOption(
          title: "Handle AFE registers", action: _showAfeRegistersDialog),
      ServiceOption(
          title: "Handle ACC registers", action: _showAccRegistersDialog),
      ServiceOption(
          title: "Handle main devide EEPROM", action: _showEepromDialog),
      ServiceOption(
          title: "Set device serial", action: _showDeviceSerialDialog),
      ServiceOption(title: "Sel LED indication", action: _showSetLedDialog),
      ServiceOption(
          title: "Get technical status", action: _performTechStatusReport),
      ServiceOption(
          title: "Export log file by email", action: _showLogSendingDialog),
      ServiceOption(
          title: "Extract log file from device",
          action: _manager.getLogFileFromDevice),
      ServiceOption(title: "Reset main device", action: _showResetDeviceDialog),
      ServiceOption(
          title: "Ignore device errors", action: _showIgnoreDeviceErrorsDialog),
      ServiceOption(
          title: "Reset application", action: _showResetApplicationDialog),
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

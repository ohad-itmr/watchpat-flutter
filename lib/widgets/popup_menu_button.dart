import 'package:flutter/material.dart';
import 'package:my_pat/main.dart';
import '../service_locator.dart';
import 'package:my_pat/generated/l10n.dart';

enum PopupOption { language, email, forget, kill, log, cancel_sftp, send_logs }

class MypatPopupMenuButton extends StatefulWidget {
  @override
  _MypatPopupMenuButtonState createState() => _MypatPopupMenuButtonState();
}

class _MypatPopupMenuButtonState extends State<MypatPopupMenuButton> {
  String _selectedLanguage;

  List<PopupMenuEntry<PopupOption>> _popupOptions = [];

  @override
  void initState() {
    initItems();
    super.initState();
  }

  initItems() async {
    sl<WelcomeActivityManager>().configFinished.firstWhere((done) => done).then((_) {
      _popupOptions = [
        PopupMenuItem(
          value: PopupOption.language,
          child: Text(S.of(context).select_language),
        ),
        PopupMenuItem(
          value: PopupOption.send_logs,
          child: Text(S.of(context).send_logs),
        ),
        PopupMenuItem(
          value: PopupOption.forget,
          child: Text(S.of(context).forget_device),
        ), //        _killAppOption(),
//        _sftpOption()
      ];
    });
  }

  _getPopupOptions() {
    return [
      PopupMenuItem(
        value: PopupOption.language,
        child: Text(S.of(context).select_language),
      ),
      PopupMenuItem(
        value: PopupOption.send_logs,
        child: Text(S.of(context).send_logs),
      ),
      PopupMenuItem(
        value: PopupOption.forget,
        child: Text(S.of(context).forget_device),
      ), //        _killAppOption(),
//        _sftpOption()
    ];
  }

  static Widget _killAppOption() {
    if (GlobalSettings.isDebugMode) {
      return PopupMenuItem(
        value: PopupOption.kill,
        child: Text("Kill app"),
      );
    } else {
      return null;
    }
  }

  static Widget _logOption() {
    if (GlobalSettings.isDebugMode) {
      return PopupMenuItem(
        value: PopupOption.log,
        child: Text("Extract system log"),
      );
    } else {
      return null;
    }
  }

  static Widget _sftpOption() {
    if (GlobalSettings.isDebugMode) {
      return PopupMenuItem(
        value: PopupOption.log,
        child: Text("Cancel sftp upload"),
      );
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<PopupOption>(
      icon: Icon(Icons.menu),
      tooltip: 'Main Menu',
      onSelected: _handlePopupOption,
      itemBuilder: (BuildContext context) {
        return _getPopupOptions();
      },
    );
  }

  void _handlePopupOption(PopupOption option) {
    if (option == PopupOption.language) {
      _showLanguageSelectDialog();
    } else if (option == PopupOption.forget) {
      _forgetConnectedDevice();
    } else if (option == PopupOption.kill) {
      _killApplication();
    } else if (option == PopupOption.cancel_sftp) {
      _cancelSftpUploading();
    } else if (option == PopupOption.send_logs) {
      _sendLogs();
    }
  }

  void _showLanguageSelectDialog() {
    _selectedLanguage = PrefsProvider.loadLocale().toString();
    showDialog(
        context: context,
        builder: (_) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text(S.of(context).select_language),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  RadioListTile(
                    value: _selectedLanguage == "en_",
                    groupValue: true,
                    onChanged: (_) {
                      setState(() => _selectedLanguage = "en_");
                    },
                    title: Text(S.of(context).english),
                  ),
                  RadioListTile(
                    value: _selectedLanguage == "fr_",
                    groupValue: true,
                    onChanged: (_) {
                      setState(() => _selectedLanguage = "fr_");
                    },
                    title: Text(S.of(context).french),
                  ),
                  RadioListTile(
                    value: _selectedLanguage == "de_",
                    groupValue: true,
                    onChanged: (_) {
                      setState(() => _selectedLanguage = "de_");
                    },
                    title: Text(S.of(context).german),
                  ),
                  RadioListTile(
                    value: _selectedLanguage == "it_",
                    groupValue: true,
                    onChanged: (_) {
                      setState(() => _selectedLanguage = "it_");
                    },
                    title: Text(S.of(context).italian),
                  )
                ],
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(S.of(context).cancel),
                ),
                FlatButton(
                  onPressed: () {
                    AppComponent.setLocale(context, Locale(_selectedLanguage.replaceAll("_", "")));
                    Navigator.of(context).pop();
                  },
                  child: Text(S.of(context).ok),
                )
              ],
            );
          });
        });
  }

  void _forgetConnectedDevice() {
    PrefsProvider.clearDeviceName();
  }

  void _killApplication() {
    TransactionManager.platformChannel.invokeMethod("crashApplication");
  }

  void _cancelSftpUploading() {
    sl<SftpService>().cancelUpload();
  }

  void _sendLogs() async {
    if (SystemStateManager.emailSending) return;
    SystemStateManager.emailSending = true;
    sl<SystemStateManager>().sendToastMessage("Sending logs...");
    final bool success = await sl<EmailSenderService>().sendLogsArchive();
    final String msg = success ? 'Sending logs success' : 'Sending logs failed';
    sl<SystemStateManager>().sendToastMessage(msg);
    SystemStateManager.emailSending = false;
  }
}

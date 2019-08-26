import 'package:flutter/material.dart';
import 'package:my_pat/generated/i18n.dart';
import 'package:my_pat/main.dart';

import '../service_locator.dart';

enum PopupOption { language, email, forget, kill, log }

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
//    PopupMenuItem(
//      value: PopupOption.language,
//      child: Text("Select language"),
//    ),
        PopupMenuItem(
          value: PopupOption.forget,
          child: Text("Forget device"),
        ),
        _killAppOption(),
        _logOption()
      ];
    });
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

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<PopupOption>(
      icon: Icon(Icons.menu),
      tooltip: 'Main Menu',
      onSelected: _handlePopupOption,
      itemBuilder: (BuildContext context) {
        return _popupOptions;
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
    } else if (option == PopupOption.log) {
      _extractSystemLog();
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
//    TransactionManager.platformChannel.invokeMethod("crashApplication");
    sl<BleService>().disconnectFromStoredDevice();
  }

  void _extractSystemLog() {
    TransactionManager.platformChannel.invokeMethod("extractSystemLog");
  }
}

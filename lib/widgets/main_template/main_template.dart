import 'package:flutter/material.dart';
import 'package:my_pat/widgets/appbar_decoration.dart';
import 'package:my_pat/widgets/connection_indicators_ver.dart';
import 'package:my_pat/widgets/interactive_title.dart';
import 'package:my_pat/widgets/popup_menu_button.dart';
import 'package:my_pat/widgets/service_counter.dart';

class MainTemplate extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showBack;
  final bool showMenu;
  final Color backgroundColor;

  MainTemplate(
      {this.body,
      this.showBack = true,
      this.showMenu = false,
      this.backgroundColor,
      this.title = 'WatchPAT\u2122  ONE'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: InteractiveTitle(title: title),
        elevation: 0,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            showBack
                ? IconButton(
                    icon: Icon(Icons.arrow_back),
                    tooltip: 'Back',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                : Container(width: 0.0, height: 0.0),
            showMenu
                ? MypatPopupMenuButton()
                : Container(width: 0.0, height: 0.0)
          ],
        ),
        actions: <Widget>[
          ServiceCounter(),
          AppbarConnectionIndicators()
        ],
        flexibleSpace: AppBarDecoration(),
      ),
      body: body,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomPadding: false,
    );
  }
}

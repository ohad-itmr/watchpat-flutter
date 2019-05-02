import 'package:flutter/material.dart';
import 'package:my_pat/widgets/appbar_decoration.dart';
import 'package:my_pat/widgets/interactive_title.dart';
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
      this.title = 'WatchPAT\u1d40\u1d39  ONE'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InteractiveTitle(title: title),
        elevation: 0,
        leading: showBack
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                tooltip: 'Back',
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            : Container(),
        actions: <Widget>[
          ServiceCounter(),
          showMenu
              ? IconButton(
                  icon: Icon(Icons.menu),
                  tooltip: 'Main Menu',
                  onPressed: () {},
                )
              : Container(height: 0.0, width: 0.0)
        ],
        flexibleSpace: AppBarDecoration(),
      ),
      body: body,
      backgroundColor: backgroundColor,
    );
  }
}

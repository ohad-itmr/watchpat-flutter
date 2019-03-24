import 'package:flutter/material.dart';

class MainTemplate extends StatelessWidget {
  final String title = 'WatchPAT\u1d40\u1d39  ONE';
  final Widget body;
  final bool showBack;
  final bool showMenu;

  MainTemplate({this.body, this.showBack = true, this.showMenu = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
        actions: showMenu
            ? <Widget>[
                IconButton(
                  icon: Icon(Icons.menu),
                  tooltip: 'Main Menu',
                  onPressed: () {},
                ),
              ]
            : null,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).accentColor,
                Theme.of(context).primaryColor,
              ],
            ),
          ),
        ),
      ),
      body: body,
    );
  }
}

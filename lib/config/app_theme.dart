import 'package:flutter/material.dart';

class AppTheme {
  static final theme = ThemeData(
    primaryColor: Color.fromARGB(255, 96, 164, 155),
    accentColor: Color.fromARGB(255, 96, 154, 197),
    buttonTheme: ButtonThemeData(
      minWidth: 140.0,
      height: 40.0,
    ),
    textTheme: TextTheme(
      title: TextStyle(
        color: Color.fromARGB(255, 0, 73, 114),
      ),
      body1: TextStyle(
        color: Color.fromARGB(255, 0, 73, 114),
        letterSpacing: 0.07,
      ),
    ),
  );
}

import 'package:flutter/material.dart';

class ThemeConfig {
  // Add theme related configurations here
  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
    useMaterial3: true,
  );

  static final ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.blueGrey,
    brightness: Brightness.dark,
    useMaterial3: true,
  );
}

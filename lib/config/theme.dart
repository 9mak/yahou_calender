import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      primarySwatch: Colors.blue,
      brightness: Brightness.light,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 2,
      ),
      cardTheme: const CardTheme(
        elevation: 1,
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      primarySwatch: Colors.blue,
      brightness: Brightness.dark,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 2,
      ),
      cardTheme: const CardTheme(
        elevation: 1,
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static const String keyThemeMode = 'themeMode';
  static const String keyStartWeekday = 'startWeekday';
  static const String keyDefaultView = 'defaultView';

  static Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyThemeMode, mode.index);
  }

  static Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(keyThemeMode) ?? ThemeMode.system.index;
    return ThemeMode.values[index];
  }

  static Future<void> saveStartWeekday(int weekday) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyStartWeekday, weekday);
  }

  static Future<int> loadStartWeekday() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyStartWeekday) ?? DateTime.monday;
  }

  static Future<void> saveDefaultView(String view) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyDefaultView, view);
  }

  static Future<String> loadDefaultView() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyDefaultView) ?? "月";
  }
}

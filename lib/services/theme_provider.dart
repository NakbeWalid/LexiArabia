import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider permettant de gérer le thème clair/sombre de l'application.
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'is_dark_mode';

  bool _isDarkMode = true;

  ThemeProvider() {
    _loadSavedTheme();
  }

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> toggleDarkMode(bool value) async {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
  }

  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedValue = prefs.getBool(_themeKey);
    if (savedValue == null) return;

    _isDarkMode = savedValue;
    notifyListeners();
  }
}

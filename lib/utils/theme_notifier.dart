import 'package:flutter/material.dart';
import '../services/prefs_service.dart';

class ThemeNotifier extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;

  ThemeNotifier() {
    loadTheme();
  }

  void loadTheme() async {
    _isDark = await PrefsService.instance.isDarkMode();
    notifyListeners();
  }

  void setDark(bool value) async {
    _isDark = value;
    await PrefsService.instance.setThemeMode(value);
    notifyListeners();
  }
} 
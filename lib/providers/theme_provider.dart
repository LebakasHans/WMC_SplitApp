import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeProvider extends ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider() {
    loadThemePreference();
  }

  ThemeMode get themeMode => _themeMode;

  Future<void> loadThemePreference() async {
    final themeString = await _secureStorage.read(key: 'themeMode');
    setThemeMode(themeString ?? 'system');
    notifyListeners();
  }

  void setThemeMode(String themeMode) {
    switch (themeMode) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      case 'system':
      default:
        _themeMode = ThemeMode.system;
    }
    _secureStorage.write(key: 'themeMode', value: themeMode);
    notifyListeners();
  }

  String themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}

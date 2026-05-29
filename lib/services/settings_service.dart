import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide preferences (theme mode, font size, autosave) persisted with
/// shared_preferences.
class SettingsService extends ChangeNotifier {
  static const _kThemeMode = 'theme_mode';
  static const _kEditorFontScale = 'editor_font_scale';
  static const _kAutosave = 'autosave';
  static const _kUserName = 'user_name';

  late SharedPreferences _prefs;

  ThemeMode _themeMode = ThemeMode.light;
  double _editorFontScale = 1.0;
  bool _autosave = true;
  String _userName = 'Word Master User';

  ThemeMode get themeMode => _themeMode;
  double get editorFontScale => _editorFontScale;
  bool get autosave => _autosave;
  String get userName => _userName;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final tm = _prefs.getString(_kThemeMode) ?? 'light';
    _themeMode = switch (tm) {
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.light,
    };
    _editorFontScale = _prefs.getDouble(_kEditorFontScale) ?? 1.0;
    _autosave = _prefs.getBool(_kAutosave) ?? true;
    _userName = _prefs.getString(_kUserName) ?? 'Word Master User';
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final value = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
      _ => 'light',
    };
    await _prefs.setString(_kThemeMode, value);
    notifyListeners();
  }

  Future<void> setEditorFontScale(double scale) async {
    _editorFontScale = scale;
    await _prefs.setDouble(_kEditorFontScale, scale);
    notifyListeners();
  }

  Future<void> setAutosave(bool value) async {
    _autosave = value;
    await _prefs.setBool(_kAutosave, value);
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    await _prefs.setString(_kUserName, name);
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/strings.dart';

/// App-wide preferences (theme mode, font size, autosave) persisted with
/// shared_preferences.
class SettingsService extends ChangeNotifier {
  static const _kThemeMode = 'theme_mode';
  static const _kEditorFontScale = 'editor_font_scale';
  static const _kAutosave = 'autosave';
  static const _kUserName = 'user_name';
  static const _kDailyGoal = 'daily_goal';
  static const _kAccentColor = 'accent_color';
  static const _kAppLockPin = 'app_lock_pin';

  /// The palette of accent colors the user can choose from.
  static const List<Color> accentPalette = [
    Color(0xFF2E7CF6), // blue (default)
    Color(0xFF7C4DFF), // purple
    Color(0xFFD81B8C), // magenta
    Color(0xFF00B0FF), // cyan
    Color(0xFF22C55E), // green
    Color(0xFFEF8A1B), // orange
    Color(0xFFEF4444), // red
    Color(0xFF0EA5A4), // teal
  ];

  late SharedPreferences _prefs;

  ThemeMode _themeMode = ThemeMode.light;
  double _editorFontScale = 1.0;
  bool _autosave = true;
  String _userName = AppStrings.defaultUserName;
  int _dailyGoal = 300;
  int _accentIndex = 0;
  String _appLockPin = '';

  ThemeMode get themeMode => _themeMode;
  double get editorFontScale => _editorFontScale;
  bool get autosave => _autosave;
  String get userName => _userName;
  int get dailyGoal => _dailyGoal;
  int get accentIndex => _accentIndex;
  Color get accentColor => accentPalette[_accentIndex];

  /// Whether the whole app is protected by a launch PIN.
  bool get appLockEnabled => _appLockPin.isNotEmpty;
  String get appLockPin => _appLockPin;

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
    _userName = _prefs.getString(_kUserName) ?? AppStrings.defaultUserName;
    _dailyGoal = _prefs.getInt(_kDailyGoal) ?? 300;
    _accentIndex =
        (_prefs.getInt(_kAccentColor) ?? 0).clamp(0, accentPalette.length - 1);
    _appLockPin = _prefs.getString(_kAppLockPin) ?? '';
    notifyListeners();
  }

  Future<void> setAccentIndex(int index) async {
    _accentIndex = index.clamp(0, accentPalette.length - 1);
    await _prefs.setInt(_kAccentColor, _accentIndex);
    notifyListeners();
  }

  Future<void> setAppLockPin(String pin) async {
    _appLockPin = pin;
    await _prefs.setString(_kAppLockPin, pin);
    notifyListeners();
  }

  Future<void> disableAppLock() async {
    _appLockPin = '';
    await _prefs.remove(_kAppLockPin);
    notifyListeners();
  }

  bool verifyAppLockPin(String pin) => _appLockPin == pin;

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

  Future<void> setDailyGoal(int goal) async {
    _dailyGoal = goal.clamp(50, 5000);
    await _prefs.setInt(_kDailyGoal, _dailyGoal);
    notifyListeners();
  }
}

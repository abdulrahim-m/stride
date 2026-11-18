import 'package:flutter/material.dart';
import 'package:mobile_client/core/rust/api.dart';
import 'package:mobile_client/core/settings/app_settings.dart';
import 'package:mobile_client/core/theme/themes/base.dart';
import 'package:mobile_client/core/theme/themes/theme_registry.dart';
import 'package:mobile_client/shared/utils/api_guard.dart';

/// The app's settings, kept in the core's database. The one source of truth
/// for theme, language and text size: `MyApp` listens to it, so a change
/// shows everywhere at once. Registered in GetIt, so non-widget code (task
/// logic, ...) can read e.g. [resetHour] too.
class SettingsController extends ChangeNotifier with ApiGuard {
  SettingsController(this._core);

  final NoteCore _core;
  Map<String, String> _raw = {};
  bool _disposed = false;

  /// Reads every setting from the core.
  Future<void> load() async {
    final ok = await guard(() async => _raw = await _core.getSettings());
    if (ok) notifyListeners();
  }

  T get<T>(Setting<T> s) => s.read(_raw);

  /// Applies right away, then saves; puts the old value back if saving fails.
  Future<void> set<T>(Setting<T> s, T value) async {
    final encoded = s.encode(s.clean(value));
    if (_raw[s.key] == encoded) return;
    final previous = _raw;
    _raw = {..._raw, s.key: encoded};
    notifyListeners();
    final ok = await guard(
      () => _core.setSetting(key: s.key, value: encoded),
    );
    if (!ok) {
      _raw = previous;
      notifyListeners();
    }
  }

  /// Puts every setting back to its default.
  Future<void> resetAll() async {
    if (await guard(_core.resetSettings)) await load();
  }

  // ------------------------------------------------------ typed shortcuts
  String get language => get(AppSettings.language);
  int get resetHour => get(AppSettings.resetHour);
  int get fontSize => get(AppSettings.fontSize);

  /// null = follow the device.
  Locale? get locale {
    final l = language;
    return l == 'default' ? null : Locale(l);
  }

  /// Light / dark / follow the device.
  ThemeMode get themeMode => switch (get(AppSettings.themeColor)) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  /// Whether the app is dark right now, [deviceBrightness] decides when the
  /// setting is `default`.
  bool isDark(Brightness deviceBrightness) => switch (themeMode) {
    ThemeMode.light => false,
    ThemeMode.dark => true,
    ThemeMode.system => deviceBrightness == Brightness.dark,
  };

  /// The menu button: flips to the opposite of what is showing, always an
  /// explicit light or dark (never `default`).
  Future<void> toggleBrightness(Brightness deviceBrightness) => set(
    AppSettings.themeColor,
    isDark(deviceBrightness) ? 'light' : 'dark',
  );

  AppThemeOption get themeOption => themeById(get(AppSettings.theme));
  AppColors get themeColors => themeOption.colors;

  /// Multiplier that turns the design text size (14) into [fontSize].
  double get textScale => fontSize / AppSettings.fontSizeDesign;

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

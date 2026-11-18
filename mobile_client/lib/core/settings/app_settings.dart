/// One persisted setting: its key in the core's settings table, how its
/// string value is read / written, a default, and an optional clean-up.
///
/// To add a setting: declare it in [AppSettings], then add a tile for it in
/// the settings page. Nothing else needs to change.
class Setting<T> {
  const Setting({
    required this.key,
    required this.defaultValue,
    required this.decode,
    required this.encode,
    this.normalize,
  });

  final String key;
  final T defaultValue;
  final T Function(String raw) decode;
  final String Function(T value) encode;

  /// Keeps a value valid (e.g. clamps it into a range).
  final T Function(T value)? normalize;

  T clean(T value) => normalize == null ? value : normalize!(value);

  /// The setting's value in the raw `key -> string` map from the core;
  /// the default when it is missing or unreadable.
  T read(Map<String, String> raw) {
    final v = raw[key];
    if (v == null) return defaultValue;
    try {
      return clean(decode(v));
    } catch (_) {
      return defaultValue;
    }
  }
}

String _same(String v) => v;
String _str(int v) => '$v';
int _int(String v) => int.tryParse(v) ?? double.parse(v).round();
int _hour(int v) => v < 0 ? 0 : (v > 23 ? 23 : v);
int _font(int v) => v < AppSettings.fontSizeMin
    ? AppSettings.fontSizeMin
    : (v > AppSettings.fontSizeMax ? AppSettings.fontSizeMax : v);

/// Every setting of the app, with the keys the core stores them under.
abstract final class AppSettings {
  /// `default` (device) / `en` / `ar`.
  static const language = Setting<String>(
    key: 'language',
    defaultValue: 'default',
    decode: _same,
    encode: _same,
  );
  static const languages = ['default', 'en', 'ar'];

  /// A theme id from the theme registry, or `default` (= the default theme).
  static const theme = Setting<String>(
    key: 'theme',
    defaultValue: 'default',
    decode: _same,
    encode: _same,
  );

  /// `default` (follow the device) / `light` / `dark`. The menu button only
  /// ever sets light or dark; `default` is chosen in the settings page.
  static const themeColor = Setting<String>(
    key: 'theme_color',
    defaultValue: 'default',
    decode: _same,
    encode: _same,
  );
  static const themeColorOptions = ['default', 'light', 'dark'];

  /// Hour of the day (0-23) at which tasks reset.
  static const resetHour = Setting<int>(
    key: 'reset_time',
    defaultValue: 0,
    decode: _int,
    encode: _str,
    normalize: _hour,
  );

  /// Base text size; 14 is the design size.
  static const fontSize = Setting<int>(
    key: 'font_size',
    defaultValue: 14,
    decode: _int,
    encode: _str,
    normalize: _font,
  );
  static const fontSizeMin = 12;
  static const fontSizeMax = 24;
  static const fontSizeDesign = 14;
}

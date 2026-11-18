import 'package:flutter/material.dart';
import 'package:mobile_client/core/di/injection.dart';
import 'package:mobile_client/core/settings/app_settings.dart';
import 'package:mobile_client/core/settings/settings_controller.dart';
import 'package:mobile_client/features/settings/presentation/widgets/choice_setting_tile.dart';
import 'package:mobile_client/features/settings/presentation/widgets/settings_section.dart';
import 'package:mobile_client/features/settings/presentation/widgets/slider_setting_tile.dart';
import 'package:mobile_client/features/settings/presentation/widgets/theme_setting_tile.dart';
import 'package:mobile_client/l10n/app_localizations.dart';
import 'package:mobile_client/shared/dialogs/dialogs.dart';

/// Settings screen: a list of [SettingsSection]s.
///
/// To add a setting: declare it in `AppSettings`, then add one tile to a
/// section below (`ChoiceSettingTile` for a list of options,
/// `SliderSettingTile` for a number, or any widget of your own that calls
/// `settings.set(...)`). To add a group, add another `SettingsSection`.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _settings = getIt<SettingsController>();

  @override
  void initState() {
    super.initState();
    _settings.onError = _showMessage;
  }

  @override
  void dispose() {
    if (_settings.onError == _showMessage) _settings.onError = null;
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _resetAll() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showConfirmDialog(
      context,
      title: l10n.settings_reset_title,
      message: l10n.settings_reset_body,
      confirmLabel: l10n.settings_reset_action,
      destructive: true,
    );
    if (ok) await _settings.resetAll();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings_title)),
      body: ListenableBuilder(
        listenable: _settings,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            SettingsSection(
              title: l10n.settings_appearance,
              children: [
                ChoiceSettingTile<String>(
                  setting: AppSettings.themeColor,
                  title: l10n.settings_theme_mode,
                  icon: Icons.brightness_6_outlined,
                  options: AppSettings.themeColorOptions,
                  labelOf: (context, v) => switch (v) {
                    'light' => l10n.settings_theme_mode_light,
                    'dark' => l10n.settings_theme_mode_dark,
                    _ => l10n.settings_theme_mode_default,
                  },
                ),
                ThemeSettingTile(
                  setting: AppSettings.theme,
                  title: l10n.settings_theme,
                ),
                SliderSettingTile(
                  setting: AppSettings.fontSize,
                  title: l10n.settings_font_size,
                  icon: Icons.format_size,
                  min: AppSettings.fontSizeMin,
                  max: AppSettings.fontSizeMax,
                  previewText: l10n.settings_font_preview,
                ),
              ],
            ),
            SettingsSection(
              title: l10n.settings_general,
              children: [
                ChoiceSettingTile<String>(
                  setting: AppSettings.language,
                  title: l10n.settings_language,
                  icon: Icons.language,
                  options: AppSettings.languages,
                  labelOf: (context, v) => switch (v) {
                    'en' => 'English',
                    'ar' => 'العربية',
                    _ => l10n.settings_language_default,
                  },
                ),
                ChoiceSettingTile<int>(
                  setting: AppSettings.resetHour,
                  title: l10n.settings_reset_time,
                  hint: l10n.settings_reset_time_hint,
                  icon: Icons.schedule,
                  options: List.generate(24, (h) => h),
                  labelOf: (context, h) =>
                      TimeOfDay(hour: h, minute: 0).format(context),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: OutlinedButton.icon(
                onPressed: _resetAll,
                icon: const Icon(Icons.restore),
                label: Text(l10n.settings_reset_defaults),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

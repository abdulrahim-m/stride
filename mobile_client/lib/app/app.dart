import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile_client/app/router.dart';
import 'package:mobile_client/core/di/injection.dart';
import 'package:mobile_client/core/settings/settings_controller.dart';
import 'package:mobile_client/core/theme/app_theme.dart';
import 'package:mobile_client/l10n/app_localizations.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = getIt<SettingsController>();

    // Rebuilds the whole app when a setting (theme, language, font size) changes.
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final colors = settings.themeColors;
        return MaterialApp.router(
          title: 'Stride',
          theme: AppTheme.getLightTheme(colors),
          darkTheme: AppTheme.getDarkTheme(colors),
          themeMode: ThemeMode.system,
          routerConfig: appRouter,

          locale: settings.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          localeResolutionCallback: (locale, supportedLocales) {
            if (locale == null) return const Locale('en');
            for (final supported in supportedLocales) {
              if (supported.languageCode == locale.languageCode) {
                return supported;
              }
            }
            return const Locale('en');
          },

          builder: (context, child) {
            final mq = MediaQuery.of(context);
            final system = mq.textScaler.scale(14) / 14;
            return MediaQuery(
              data: mq.copyWith(
                textScaler: TextScaler.linear(system * settings.textScale),
              ),
              child: child!,
            );
          },
        );
      },
    );
  }
}

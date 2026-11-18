import 'package:flutter/material.dart';
import 'package:mobile_client/core/theme/themes/base.dart';

class AquaThemeColors implements AppColors {
  // Brand (Shared)
  @override final Color primary = Color.fromRGBO(14, 165, 233, 1); // Vivid Sky Blue
  @override final Color primaryDark = Color.fromRGBO(2, 132, 199, 1); // Deeper Ocean Blue
  @override final Color secondary = Color.fromARGB(255, 71, 85, 105); // Professional Slate

  // Light Palette
  @override final Color lightBackground = Color(0xFFF0F9FF); // ice-blue tint (Sky-50)
  @override final Color lightSurface = Colors.white;
  @override final Color lightTextPrimary = Color.fromARGB(255, 15, 23, 42); // Deep slate for sharp contrast
  @override final Color lightTextSecondary = Color.fromARGB(255, 71, 85, 105);
  @override final Color lightTextMuted = Color(0xFF94A3B8);
  @override final Color lightBorder = Color(0xFFBAE6FD); // Defined aqua-tinted border

  // Dark Palette (Updated for high contrast & clear surface distinction)
  @override final Color darkBackground = Color(0xFF0B1120); // Deeper sea slate base
  @override final Color darkSurface = Color.fromARGB(255, 18, 28, 48); // Lifted surface color for clear card/badge distinction
  @override final Color darkTextPrimary = Color.fromARGB(255, 241, 245, 249);
  @override final Color darkTextSecondary = Color.fromARGB(255, 168, 182, 204); // Brighter secondary text
  @override final Color darkTextMuted = Color.fromARGB(255, 115, 132, 158);
  @override final Color darkBorder = Color.fromARGB(255, 51, 65, 85);

  // Status Colors (Shared)
  @override final Color error = Color(0xFFEF4444);
  @override final Color success = Color(0xFF10B981);
}
import 'package:flutter/material.dart';
import 'package:mobile_client/core/theme/themes/base.dart';

class ForestThemeColors implements AppColors {
  // Brand (Shared)
  @override final Color primary = Color.fromRGBO(46, 139, 87, 1); // Sea green
  @override final Color primaryDark = Color.fromRGBO(30, 100, 60, 1);
  @override final Color secondary = Color.fromARGB(255, 60, 90, 70);

  // Light Palette
  @override final Color lightBackground = Color(0xFFF3F8F4);
  @override final Color lightSurface = Colors.white;
  @override final Color lightTextPrimary = Color.fromARGB(255, 22, 40, 30);
  @override final Color lightTextSecondary = Color.fromARGB(255, 85, 110, 95);
  @override final Color lightTextMuted = Color(0xFF9DB3A5);
  @override final Color lightBorder = Color(0xFFD3E4D9);

  // Dark Palette (Updated for high contrast)
  @override final Color darkBackground = Color(0xFF07100B);
  @override final Color darkSurface = Color.fromARGB(255, 16, 29, 21); // Distinct surface elevation
  @override final Color darkTextPrimary = Color.fromARGB(255, 232, 244, 236);
  @override final Color darkTextSecondary = Color.fromARGB(255, 170, 194, 178); // Brighter readability
  @override final Color darkTextMuted = Color.fromARGB(255, 120, 146, 128);
  @override final Color darkBorder = Color.fromARGB(255, 46, 74, 56); // Sharper outline boundaries

  // Status Colors (Shared)
  @override final Color error = Color(0xFFEF5350);
  @override final Color success = Color(0xFF66BB6A);
}
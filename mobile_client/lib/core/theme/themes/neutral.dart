import 'package:flutter/material.dart';
import 'package:mobile_client/core/theme/themes/base.dart';

class NeutralThemeColors implements AppColors {
  // Brand (Shared) - Pure neutral gray
  @override final Color primary = Color.fromRGBO(110, 110, 110, 1);
  @override final Color primaryDark = Color.fromRGBO(75, 75, 75, 1);
  @override final Color secondary = Color.fromARGB(255, 120, 120, 120);

  // Light Palette
  @override final Color lightBackground = Color(0xFFF5F5F5);
  @override final Color lightSurface = Colors.white;
  @override final Color lightTextPrimary = Color.fromARGB(255, 33, 33, 33);
  @override final Color lightTextSecondary = Color.fromARGB(255, 117, 117, 117);
  @override final Color lightTextMuted = Color(0xFF9E9E9E);
  @override final Color lightBorder = Color(0xFFE0E0E0);

  // Dark Palette (Updated for high contrast)
  @override final Color darkBackground = Color(0xFF0E0E0E);
  @override final Color darkSurface = Color.fromARGB(255, 24, 24, 24); // Lifted surface for cards
  @override final Color darkTextPrimary = Color.fromARGB(255, 245, 245, 245);
  @override final Color darkTextSecondary = Color.fromARGB(255, 170, 170, 170); // Enhanced secondary text
  @override final Color darkTextMuted = Color.fromARGB(255, 128, 128, 128);
  @override final Color darkBorder = Color.fromARGB(255, 58, 58, 58); // Clearer border outline

  // Status Colors (Shared)
  @override final Color error = Color(0xFFEF4444);
  @override final Color success = Color(0xFF10B981);
}
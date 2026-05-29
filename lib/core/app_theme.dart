import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central design system for Word Master.
/// Colors are derived from the reference UI: a vivid pink/purple → cyan
/// gradient header, soft blue-grey background, and clean white surfaces.
class AppColors {
  AppColors._();

  // Brand gradient (header, FAB, highlights)
  static const Color gradientStart = Color(0xFFD81B8C); // magenta/pink
  static const Color gradientMid = Color(0xFF7C4DFF); // purple
  static const Color gradientEnd = Color(0xFF00B0FF); // cyan/blue

  static const LinearGradient brandGradient = LinearGradient(
    colors: [gradientStart, gradientMid, gradientEnd],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient fabGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Surfaces & backgrounds
  static const Color scaffoldBg = Color(0xFFEEF1F6);
  static const Color surface = Colors.white;
  static const Color cardBorder = Color(0xFFE6E9F0);

  // Accents
  static const Color primaryBlue = Color(0xFF2E7CF6);
  static const Color activeChipBg = Color(0xFFE3F0FF);
  static const Color toolbarIcon = Color(0xFF5B6472);
  static const Color toolbarActive = Color(0xFF2E7CF6);

  // Text
  static const Color textPrimary = Color(0xFF1B2330);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9AA3B2);

  // Highlight colors used in documents
  static const Color highlightBlue = Color(0xFFCFE6FF);
  static const Color highlightPurple = Color(0xFFE6D6FF);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color danger = Color(0xFFEF4444);
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.scaffoldBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.gradientMid,
        primary: AppColors.primaryBlue,
        brightness: Brightness.light,
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF11151C),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.gradientMid,
        primary: AppColors.primaryBlue,
        brightness: Brightness.dark,
      ),
    );
    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF1A2029),
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Color(0xFF1A2029),
      ),
    );
  }
}

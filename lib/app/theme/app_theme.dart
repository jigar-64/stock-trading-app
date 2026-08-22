import 'package:flutter/material.dart';

/// Modern Dark Theme Design System for 021 Trading App.
///
/// Palette Inspiration: Modern Robinhood / TradingView Dark Mode
/// - Deep Obsidian Background: `#0B0E17`
/// - Elevated Surface Card: `#151B28`
/// - Surface Border: `#222A3E`
/// - Vibrant Bullish Green: `#00E676` (Emerald Glow)
/// - Vibrant Bearish Red: `#FF3B30` (Neon Red Glow)
/// - Accent Indigo/Cyan: `#6366F1` (Electric Indigo)
class AppColors {
  AppColors._();

  // Background & Surfaces
  static const Color darkBackground = Color(0xFF0B0E17);
  static const Color surfaceBackground = Color(0xFF151B28);
  static const Color cardBackground = Color(0xFF192030);
  static const Color elevatedSurface = Color(0xFF20293D);

  // Borders & Dividers
  static const Color border = Color(0xFF252F45);
  static const Color divider = Color(0xFF1F2738);

  // Trading Financial Indicators
  static const Color priceUp = Color(0xFF00E676);     // Emerald Gain
  static const Color priceDown = Color(0xFFFF3B30);   // Neon Loss
  static const Color priceFlat = Color(0xFF94A3B8);   // Muted Slate

  // Flash Animation Backgrounds
  static const Color flashGreen = Color(0x3300E676);
  static const Color flashRed = Color(0x33FF3B30);

  // Typography Colors
  static const Color textPrimary = Color(0xFFF8FAFC);   // Crisp Off-White
  static const Color textSecondary = Color(0xFF94A3B8); // Cool Gray
  static const Color textMuted = Color(0xFF64748B);     // Muted Blue-Gray

  // Brand & Action Accents
  static const Color accentIndigo = Color(0xFF6366F1);  // Primary Accent
  static const Color accentBlue = Color(0xFF3B82F6);    // Secondary Blue
  static const Color accentCyan = Color(0xFF06B6D4);    // Cyan Highlight
  static const Color accentPurple = Color(0xFFA855F7);  // Holdings Accent
  static const Color buyGreen = Color(0xFF00E676);
  static const Color sellRed = Color(0xFFFF3B30);

  // Gradients
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1C2436), Color(0xFF151B28)],
  );

  static const LinearGradient summaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF3B82F6)],
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentIndigo,
        secondary: AppColors.accentBlue,
        surface: AppColors.surfaceBackground,
        onSurface: AppColors.textPrimary,
        error: AppColors.priceDown,
      ),
      fontFamily: 'Roboto',

      // AppBar Styling
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),

      // Card Styling
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),

      // Bottom Navigation Bar Styling
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceBackground,
        selectedItemColor: AppColors.accentIndigo,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),

      // TabBar Styling
      tabBarTheme: const TabBarThemeData(
        indicatorColor: AppColors.accentIndigo,
        labelColor: AppColors.accentIndigo,
        unselectedLabelColor: AppColors.textMuted,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 14,
        ),
      ),

      // Input Decoration (TextField) Styling
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentIndigo, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.priceDown),
        ),
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
      ),

      // Elevated Button Theme (Forces white text on non-white buttons)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppColors.accentIndigo,
          textStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentIndigo,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
    );
  }
}

/// Helper function providing the app's dark trading theme.
ThemeData buildAppTheme() => AppTheme.darkTheme;

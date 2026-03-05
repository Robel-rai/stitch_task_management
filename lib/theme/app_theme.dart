import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static const Color primary = Color(0xFF090966);
  static const Color backgroundDark = Color(0xFF101022);
  static const Color backgroundLight = Color(0xFFD4D4FF);
  static const Color surfaceDark = Color(0xFF0F172A); // slate-900
  static const Color surfaceVariantDark = Color(0xFF1E293B); // slate-800
  static const Color borderDark = Color(0xFF1E293B);
  static const Color textPrimary = Color(0xFFF1F5F9); // slate-100
  static const Color textSecondary = Color(0xFF94A3B8); // slate-400
  static const Color textTertiary = Color(0xFF64748B); // slate-500

  // Status colors
  static const Color emerald = Color(0xFF10B981);
  static const Color amber = Color(0xFFF59E0B);
  static const Color rose = Color(0xFFF43F5E);
  static const Color blue = Color(0xFF3B82F6);
  static const Color indigo = Color(0xFF6366F1);
  static const Color purple = Color(0xFFA855F7);
  static const Color sky = Color(0xFF38BDF8);
  static const Color orange = Color(0xFFF97316);

  // Category colors
  static const Map<String, Color> categoryColors = {
    'Development': primary,
    'Design': indigo,
    'Research': sky,
    'Marketing': purple,
    'Management': amber,
    'UI Design': primary,
    'Work': primary,
    'Study': blue,
    'Health': emerald,
    'Social': orange,
    'Admin': textTertiary,
  };

  static Color getCategoryColor(String category) {
    return categoryColors[category] ?? primary;
  }

  // Priority colors
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return rose;
      case 'medium':
        return amber;
      case 'low':
        return emerald;
      default:
        return textSecondary;
    }
  }

  // Status colors
  static Color getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return emerald;
      case 'In Progress':
        return blue;
      case 'Pending':
        return textSecondary;
      default:
        return textSecondary;
    }
  }

  static ThemeData get darkTheme {
    return ThemeData(
      extensions: [AppThemeColors.dark()],
      brightness: Brightness.dark,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: backgroundDark,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        surface: backgroundDark,
        onSurface: textPrimary,
        onPrimary: Colors.white,
        outline: borderDark,
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderDark),
        ),
        elevation: 0,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundDark.withValues(alpha: 0.8),
        elevation: 0,
        titleTextStyle: const TextStyle(
          fontFamily: 'Inter',
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        hintStyle: const TextStyle(color: textSecondary, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderDark,
        thickness: 1,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
        bodyLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: textPrimary),
        bodyMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: textSecondary),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: textTertiary),
        labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: textTertiary, letterSpacing: 1.2),
      ),
    );
  }

  // ─── Light Theme ───
  static const Color backgroundLight_ = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF1F5F9);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textPrimaryLight = Color(0xFF1E293B);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textTertiaryLight = Color(0xFF94A3B8);

  static ThemeData get lightTheme {
    return ThemeData(
      extensions: [AppThemeColors.light()],
      brightness: Brightness.light,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: backgroundLight_,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        surface: backgroundLight_,
        onSurface: textPrimaryLight,
        onPrimary: Colors.white,
        outline: borderLight,
      ),
      cardTheme: CardThemeData(
        color: surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderLight),
        ),
        elevation: 0,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundLight_.withValues(alpha: 0.95),
        elevation: 0,
        titleTextStyle: const TextStyle(
          fontFamily: 'Inter',
          color: textPrimaryLight,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariantLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        hintStyle: const TextStyle(color: textSecondaryLight, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderLight,
        thickness: 1,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: textPrimaryLight),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimaryLight),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPrimaryLight),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimaryLight),
        bodyLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: textPrimaryLight),
        bodyMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: textSecondaryLight),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: textTertiaryLight),
        labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: textTertiaryLight, letterSpacing: 1.2),
      ),
    );
  }
}


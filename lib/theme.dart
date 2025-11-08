import 'package:flutter/material.dart';

class AppTheme {
  // Text Colors
  static const Color text1 = Color(0xFFFFFFFF); // 100%
  static const Color text2 = Color(0xFFFFFFFF); // 72% opacity
  static const Color text3 = Color(0xFFFFFFFF); // 46% opacity
  static const Color text4 = Color(0xFFFFFFFF); // 24% opacity
  static const Color text5 = Color(0xFFFFFFFF); // 24% opacity

  // Base Colors
  static const Color base2Dark = Color(0xFF101010); // 100%
  static const Color base2Light = Color(0xFF151515); // 100%

  // Surface Colors
  static const Color surfaceWhite1 = Color(0xFFFFFFFF); // 2% opacity
  static const Color surfaceWhite2 = Color(0xFFFFFFFF); // 5% opacity
  static const Color surfaceBlack1 = Color(0xFF101010); // 90% opacity
  static const Color surfaceBlack2 = Color(0xFF101010); // 70% opacity
  static const Color surfaceBlack3 = Color(0xFF101010); // 50% opacity

  // Accent Colors
  static const Color primaryAccent = Color(0xFF9196FF);
  static const Color secondaryAccent = Color(0xFF5961FF);
  static const Color positive = Color(0xFFFE5DDB);
  static const Color negative = Color(0xFFC22743);

  // Border Colors
  static const Color border1 = Color(0xFFFFFFFF); // 8% opacity
  static const Color border2 = Color(0xFFFFFFFF); // 16% opacity
  static const Color border3 = Color(0xFFFFFFFF); // 24% opacity

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: base2Dark,
      primaryColor: primaryAccent,
      colorScheme: const ColorScheme.dark(
        primary: primaryAccent,
        secondary: secondaryAccent,
        surface: surfaceBlack1,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: text1,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: text1,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: text2),
        bodyMedium: TextStyle(fontSize: 14, color: text3),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite1.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border1.withOpacity(0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border1.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryAccent, width: 2),
        ),
      ),
    );
  }

  // Helper method to apply opacity to colors
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity / 100);
  }
}

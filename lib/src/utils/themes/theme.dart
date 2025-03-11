import 'package:flutter/material.dart';

class CS3AppTheme {
  CS3AppTheme._();
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.white,
      primary: const Color(0xFF1877F2),
    ),
    primaryColor: Color(0xFF1877F2),
    primarySwatch: MaterialColor(
      0xFF1877F2,
      <int, Color>{
        50: Color(0xFFe3f2fd),
        100: Color(0xFFbbdefb),
        200: Color(0xFF90caf9),
        300: Color(0xFF64b5f6),
        400: Color(0xFF42a5f5),
        500: Color(0xFF1877F2),
        600: Color(0xFF1e88e5),
        700: Color(0xFF1976d2),
        800: Color(0xFF1565c0),
        900: Color(0xFF0d47a1),
      },
    ),
    textTheme: const TextTheme(
      // Medium Title
      headlineMedium: TextStyle(
        color: Colors.black,
        fontSize: 26,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700),
      // Large Title Eduvate, Elevate
      headlineLarge: TextStyle(
        color: Color(0xFF1E1E1E),
        fontSize: 50,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
      ),
      // Title per group of cards
      titleSmall: TextStyle(
        color: Colors.black,
        fontSize: 13,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
      ),
      // General Text
      bodySmall: TextStyle(
        color: Color(0xFF666666),
        fontSize: 16,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: MaterialColor(
      0xFF1877F2,
      <int, Color>{
        50: Color(0xFFe3f2fd),
        100: Color(0xFFbbdefb),
        200: Color(0xFF90caf9),
        300: Color(0xFF64b5f6),
        400: Color(0xFF42a5f5),
        500: Color(0xFF1877F2),
        600: Color(0xFF1e88e5),
        700: Color(0xFF1976d2),
        800: Color(0xFF1565c0),
        900: Color(0xFF0d47a1),
      },
    ),
  );
}

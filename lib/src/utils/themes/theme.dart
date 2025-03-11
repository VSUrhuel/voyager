import 'package:flutter/material.dart';

class VoyagerTheme {
  VoyagerTheme._();

  static const Color primaryColor = Color(0xFF1877F2);
  static const ColorScheme lightColorScheme = ColorScheme.light(
    primary: primaryColor,
    onPrimary: Colors.white,
    secondary: primaryColor,
    onSecondary: Colors.white,
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: lightColorScheme,
    primaryColor: primaryColor,
    primarySwatch: MaterialColor(
      primaryColor.value,
      <int, Color>{
        50: Color(0xFFe3f2fd),
        100: Color(0xFFbbdefb),
        200: Color(0xFF90caf9),
        300: Color(0xFF64b5f6),
        400: Color(0xFF42a5f5),
        500: primaryColor,
        600: Color(0xFF1e88e5),
        700: Color(0xFF1976d2),
        800: Color(0xFF1565c0),
        900: Color(0xFF0d47a1),
      },
    ),
    textTheme: const TextTheme(
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
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: TextStyle(
        color: Color(0xFF1E1E1E),
        fontSize: 50,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
      ),
      titleSmall: TextStyle(
        color: Colors.black,
        fontSize: 13,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
      ),
      bodySmall: TextStyle(
        color: Color(0xFF666666),
        fontSize: 16,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
      ),
    ),
  );
}

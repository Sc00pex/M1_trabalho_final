import 'package:flutter/material.dart';

class AppTheme {
  static const verde = Color(0xFF295B46);
  static const fundo = Color(0xFFFAF8F3);

  static final claro = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: verde,
      primary: verde,
      surface: fundo,
    ),
    scaffoldBackgroundColor: fundo,
    appBarTheme: const AppBarTheme(
      backgroundColor: fundo,
      foregroundColor: Color(0xFF22362B),
      centerTitle: false,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      contentPadding: EdgeInsets.all(16),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(minimumSize: const Size(48, 52)),
    ),
  );
}

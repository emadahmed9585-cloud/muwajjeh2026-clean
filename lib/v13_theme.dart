import 'package:flutter/material.dart';

abstract final class MuwajjehPalette {
  static const navy = Color(0xFF183B56);
  static const teal = Color(0xFF1F7A74);
  static const tealSoft = Color(0xFFE7F3F1);
  static const sand = Color(0xFFF2B84B);
  static const ink = Color(0xFF17212B);
  static const muted = Color(0xFF667784);
  static const canvas = Color(0xFFF6F8F7);
  static const surface = Colors.white;
  static const border = Color(0xFFE3E9E7);
  static const success = Color(0xFF25805A);
  static const warning = Color(0xFFB96D16);
}

ThemeData buildMuwajjehTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: MuwajjehPalette.teal,
    brightness: Brightness.light,
  ).copyWith(
    primary: MuwajjehPalette.navy,
    onPrimary: Colors.white,
    secondary: MuwajjehPalette.teal,
    onSecondary: Colors.white,
    tertiary: MuwajjehPalette.sand,
    surface: MuwajjehPalette.surface,
    onSurface: MuwajjehPalette.ink,
    outline: MuwajjehPalette.border,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: MuwajjehPalette.canvas,
    visualDensity: VisualDensity.standard,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: MuwajjehPalette.canvas,
      foregroundColor: MuwajjehPalette.ink,
      titleTextStyle: TextStyle(
        color: MuwajjehPalette.ink,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
    ),
    cardTheme: CardThemeData(
      color: MuwajjehPalette.surface,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: MuwajjehPalette.border),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: MuwajjehPalette.border,
      thickness: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: MuwajjehPalette.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: MuwajjehPalette.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: MuwajjehPalette.teal, width: 1.6),
      ),
      labelStyle: const TextStyle(color: MuwajjehPalette.muted),
      hintStyle: const TextStyle(color: Color(0xFF93A0A7)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: MuwajjehPalette.navy,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: MuwajjehPalette.navy,
        side: const BorderSide(color: MuwajjehPalette.border),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      elevation: 0,
      backgroundColor: Colors.white,
      indicatorColor: MuwajjehPalette.tealSoft,
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        return TextStyle(
          color: states.contains(MaterialState.selected)
              ? MuwajjehPalette.teal
              : MuwajjehPalette.muted,
          fontSize: 11.5,
          fontWeight: states.contains(MaterialState.selected)
              ? FontWeight.w800
              : FontWeight.w600,
        );
      }),
      iconTheme: MaterialStateProperty.resolveWith((states) {
        return IconThemeData(
          color: states.contains(MaterialState.selected)
              ? MuwajjehPalette.teal
              : MuwajjehPalette.muted,
        );
      }),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFF1F5F4),
      side: const BorderSide(color: MuwajjehPalette.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontSize: 27, fontWeight: FontWeight.w900, color: MuwajjehPalette.ink, height: 1.25),
      headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: MuwajjehPalette.ink, height: 1.3),
      titleLarge: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: MuwajjehPalette.ink),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: MuwajjehPalette.ink),
      bodyLarge: TextStyle(fontSize: 16, color: MuwajjehPalette.ink, height: 1.65),
      bodyMedium: TextStyle(fontSize: 14, color: MuwajjehPalette.ink, height: 1.6),
    ),
  );
}

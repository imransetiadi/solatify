import 'package:flutter/material.dart';

class AppTheme {
  static const Color darkBg = Color(0xFF082E1D);
  static const Color darkCard = Color(0xFF103B28);
  static const Color darkSurface = Color(0xFF174D35);
  static const Color brown = Color(0xFF9A6A3A);
  static const Color brownDark = Color(0xFF21160F);
  static const Color brownSoft = Color(0xFFD09A5E);
  static const Color islamicGreen = Color(0xFF0E4D31);
  static const Color islamicGreenLight = Color(0xFF1B5E20);
  static const Color lightBg = Color(0xFFF3FBF6);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFE8F5E9);
  static const Color lightBorder = Color(0xFFCFE7D5);
  static const Color textLight = Color(0xFFF3FBF6);
  static const Color textDark = Color(0xFF241A12);
  static const Color textMuted = Color(0xFF756455);

  static RoundedRectangleBorder get _smallShape =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: brown,
      colorScheme: const ColorScheme.dark(
        primary: brown,
        secondary: islamicGreen,
        tertiary: brownSoft,
        surface: darkCard,
        surfaceContainerHighest: darkSurface,
        outline: Color(0xFF49372A),
        error: brownDark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textLight,
      ),
      fontFamily: 'Outfit',
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: textLight),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFF49372A), width: 1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkCard,
        selectedItemColor: brown,
        unselectedItemColor: Color(0xFFA99786),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 16,
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: darkBg,
        selectedIconTheme: IconThemeData(color: islamicGreen),
        selectedLabelTextStyle: TextStyle(
          color: islamicGreen,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        unselectedIconTheme: IconThemeData(color: Color(0xFFA99786)),
        unselectedLabelTextStyle: TextStyle(
          color: Color(0xFFA99786),
          fontSize: 12,
        ),
        indicatorColor: Color(0x260E4D31),
      ),
      tabBarTheme: const TabBarThemeData(
        indicatorColor: islamicGreen,
        labelColor: islamicGreen,
        unselectedLabelColor: Color(0xFFA99786),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? islamicGreen : textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? islamicGreen.withValues(alpha: 0.24)
              : darkSurface,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkSurface),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkSurface),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: brown, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brown,
          foregroundColor: const Color(0xFFFFFBF7),
          shape: _smallShape,
          minimumSize: const Size(48, 44),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: brown),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: darkSurface,
        contentTextStyle: TextStyle(color: textLight),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkCard,
        shape: _smallShape,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w800,
          color: textLight,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textLight,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textLight,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textLight,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textMuted,
        ),
      ),
    );
  }

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      primaryColor: brown,
      colorScheme: const ColorScheme.light(
        primary: brown,
        secondary: islamicGreen,
        tertiary: brownSoft,
        surface: lightCard,
        surfaceContainerHighest: lightSurface,
        outline: lightBorder,
        error: brownDark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textDark,
      ),
      fontFamily: 'Outfit',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: textDark),
      ),
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: lightBorder, width: 1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightCard,
        selectedItemColor: brown,
        unselectedItemColor: textMuted,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: lightBg,
        selectedIconTheme: IconThemeData(color: brown),
        selectedLabelTextStyle: TextStyle(
          color: brown,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        unselectedIconTheme: IconThemeData(color: textMuted),
        unselectedLabelTextStyle: TextStyle(color: textMuted, fontSize: 12),
        indicatorColor: Color(0x338B5A2B),
      ),
      tabBarTheme: const TabBarThemeData(
        indicatorColor: brownDark,
        labelColor: brownDark,
        unselectedLabelColor: textMuted,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? brown : textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? brown.withValues(alpha: 0.28)
              : lightBorder,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: brown, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brown,
          foregroundColor: Colors.white,
          shape: _smallShape,
          minimumSize: const Size(48, 44),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: brown),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: darkSurface,
        contentTextStyle: TextStyle(color: textLight),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: lightCard,
        shape: _smallShape,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w800,
          color: textDark,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textDark,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textMuted,
        ),
      ),
    );
  }
}

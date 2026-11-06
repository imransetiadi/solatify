import 'package:flutter/material.dart';

class AppTheme {
  static const Color darkBg = Color(0xFF082E1D);
  static const Color darkCard = Color(0xFF103B28);
  static const Color darkSurface = Color(0xFF174D35);
  static const Color brown = Color(0xFF9A6A3A);
  static const Color brownDark = Color(0xFF21160F);
  static const Color redAccent = Color(0xFFC0392B);
  static const Color redAccentDark = Color(0xFFE85D4F);
  static const Color islamicGreen = Color(0xFF0E4D31);
  static const Color islamicGreenLight = Color(0xFF1B5E20);
  static const Color lightBg = Color(0xFFF3FBF6);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFE8F5E9);
  static const Color lightBorder = Color(0xFFCFE7D5);
  static const Color textLight = Color(0xFFF3FBF6);
  static const Color textDark = Color(0xFF241A12);
  static const Color textMuted = Color(0xFF5D4E47);

  /// Muted text that stays readable (>= 4.5:1) on dark green surfaces.
  static const Color textMutedOnDark = Color(0xFFC7B3A1);

  /// Muted text that stays readable (>= 4.5:1) on light surfaces.
  static const Color textMutedOnLight = Color(0xFF6A5A4E);

  /// Positive state (completed prayers, success messages).
  static const Color success = Color(0xFF2E7D4F);
  static const Color successDark = Color(0xFF6FCF97);

  /// Cautionary state (warnings, pending actions).
  static const Color warning = Color(0xFFB26A00);
  static const Color warningDark = Color(0xFFF2B35B);

  static Color readableAccent(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? theme.colorScheme.tertiary
        : theme.colorScheme.secondary;
  }

  // Text color tokens untuk reusable di komponen
  static const Color darkModeText = Colors.white;
  static const Color darkModeTextSecondary = Color(0xFFB8A898);
  static const Color darkModeTextTertiary = Color(0xFF999999);
  static const Color darkModeTextHint = Color(0xFF8C8C8C);

  static const Color lightModeText = Color(0xFF241A12);
  static const Color lightModeTextSecondary = Color(0xFF5D4E47);
  static const Color lightModeTextTertiary = Color(0xFF5D4E47);
  static const Color lightModeTextHint = Color(0xFF85766A);

  static ThemeData get darkTheme => _build(
    const _Palette(
      brightness: Brightness.dark,
      background: darkBg,
      card: darkCard,
      surfaceHigh: darkSurface,
      accent: redAccentDark,
      text: textLight,
      muted: textMutedOnDark,
      border: Color(0xFF2A5A43),
      outline: Color(0xFF49372A),
      onAccent: Color(0xFFFFFBF7),
    ),
  );

  static ThemeData get lightTheme => _build(
    const _Palette(
      brightness: Brightness.light,
      background: lightBg,
      card: lightCard,
      surfaceHigh: lightSurface,
      accent: redAccent,
      text: textDark,
      muted: textMutedOnLight,
      border: lightBorder,
      outline: lightBorder,
      onAccent: Colors.white,
    ),
  );

  static ThemeData _build(_Palette p) {
    final isDark = p.brightness == Brightness.dark;
    const smallRadius = BorderRadius.all(Radius.circular(14));
    const largeRadius = BorderRadius.all(Radius.circular(24));

    final colorScheme = isDark
        ? ColorScheme.dark(
            primary: brown,
            secondary: islamicGreen,
            tertiary: p.accent,
            surface: p.card,
            surfaceContainerHighest: p.surfaceHigh,
            outline: p.outline,
            outlineVariant: p.border,
            error: p.accent,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onTertiary: p.onAccent,
            onSurface: p.text,
            onSurfaceVariant: p.muted,
          )
        : ColorScheme.light(
            primary: brown,
            secondary: islamicGreen,
            tertiary: p.accent,
            surface: p.card,
            surfaceContainerHighest: p.surfaceHigh,
            outline: p.outline,
            outlineVariant: p.border,
            error: p.accent,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onTertiary: p.onAccent,
            onSurface: p.text,
            onSurfaceVariant: p.muted,
          );

    final buttonTextStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.1,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      scaffoldBackgroundColor: p.background,
      primaryColor: brown,
      colorScheme: colorScheme,
      focusColor: p.accent.withValues(alpha: 0.16),
      highlightColor: p.accent.withValues(alpha: 0.08),
      splashColor: p.accent.withValues(alpha: 0.10),
      dividerColor: p.border,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? p.background : Colors.transparent,
        foregroundColor: p.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: p.text,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
        iconTheme: IconThemeData(color: p.text),
      ),
      cardTheme: CardThemeData(
        color: p.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: p.accent.withValues(alpha: isDark ? 0.12 : 0.10),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: p.border.withValues(alpha: isDark ? 0.7 : 1),
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(color: p.text),
      listTileTheme: ListTileThemeData(
        iconColor: p.accent,
        textColor: p.text,
        minVerticalPadding: 10,
        shape: const RoundedRectangleBorder(borderRadius: smallRadius),
        subtitleTextStyle: TextStyle(color: p.muted, fontSize: 12.5),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: p.card,
        selectedItemColor: p.accent,
        unselectedItemColor: p.muted,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: p.accent.withValues(alpha: isDark ? 0.18 : 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11.5,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected) ? p.accent : p.muted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? p.accent : p.muted,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: p.background,
        selectedIconTheme: IconThemeData(color: p.accent),
        selectedLabelTextStyle: TextStyle(
          color: p.accent,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        unselectedIconTheme: IconThemeData(color: p.muted),
        unselectedLabelTextStyle: TextStyle(color: p.muted, fontSize: 12),
        indicatorColor: p.accent.withValues(alpha: isDark ? 0.18 : 0.12),
      ),
      tabBarTheme: TabBarThemeData(
        indicatorColor: p.accent,
        labelColor: p.accent,
        unselectedLabelColor: p.muted,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.accent,
        linearTrackColor: p.accent.withValues(alpha: 0.14),
        circularTrackColor: p.accent.withValues(alpha: 0.10),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? p.onAccent : p.muted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? p.accent : p.surfaceHigh,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.transparent
              : p.muted.withValues(alpha: 0.5),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? p.accent : null,
        ),
        checkColor: WidgetStatePropertyAll(p.onAccent),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? p.accent : p.muted,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: p.accent,
        thumbColor: p.accent,
        inactiveTrackColor: p.accent.withValues(alpha: 0.18),
        overlayColor: p.accent.withValues(alpha: 0.12),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.card,
        selectedColor: p.accent.withValues(alpha: isDark ? 0.22 : 0.12),
        checkmarkColor: p.accent,
        side: BorderSide(color: p.border),
        labelStyle: TextStyle(
          color: p.text,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: TextStyle(
          color: p.accent,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: const StadiumBorder(),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? p.accent.withValues(alpha: isDark ? 0.22 : 0.12)
                : Colors.transparent,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) =>
                states.contains(WidgetState.selected) ? p.accent : p.text,
          ),
          side: WidgetStatePropertyAll(BorderSide(color: p.border)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.card,
        hintStyle: TextStyle(color: p.muted),
        prefixIconColor: p.muted,
        suffixIconColor: p.muted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: p.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: p.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: p.accent, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.accent,
          foregroundColor: p.onAccent,
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: smallRadius),
          minimumSize: const Size(48, 48),
          textStyle: buttonTextStyle,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.accent,
          foregroundColor: p.onAccent,
          disabledBackgroundColor: p.muted.withValues(alpha: 0.18),
          disabledForegroundColor: p.muted,
          shape: const RoundedRectangleBorder(borderRadius: smallRadius),
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textStyle: buttonTextStyle,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.accent,
          side: BorderSide(color: p.accent.withValues(alpha: 0.45)),
          shape: const RoundedRectangleBorder(borderRadius: smallRadius),
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textStyle: buttonTextStyle,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.accent,
          minimumSize: const Size(48, 44),
          textStyle: buttonTextStyle,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(44, 44)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.accent,
        foregroundColor: p.onAccent,
        elevation: 2,
        shape: const RoundedRectangleBorder(borderRadius: smallRadius),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? darkSurface : textDark,
        actionTextColor: isDark ? redAccentDark : const Color(0xFFFFB4A9),
        contentTextStyle: const TextStyle(color: textLight, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: smallRadius),
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.card,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: largeRadius),
        titleTextStyle: TextStyle(
          color: p.text,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
        contentTextStyle: TextStyle(color: p.muted, fontSize: 14, height: 1.45),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.card,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: p.muted.withValues(alpha: 0.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: p.card,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: smallRadius),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? darkSurface : textDark,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(color: textLight, fontSize: 12),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w800,
          color: p.text,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: p.text,
        ),
        headlineSmall: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: p.text,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: p.text,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: p.text,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: p.text,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: p.text,
          height: 1.45,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: p.muted,
          height: 1.4,
        ),
        bodySmall: TextStyle(fontSize: 12, color: p.muted, height: 1.35),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: p.text,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: p.muted,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: p.muted,
        ),
      ),
    );
  }
}

class _Palette {
  const _Palette({
    required this.brightness,
    required this.background,
    required this.card,
    required this.surfaceHigh,
    required this.accent,
    required this.text,
    required this.muted,
    required this.border,
    required this.outline,
    required this.onAccent,
  });

  final Brightness brightness;
  final Color background;
  final Color card;
  final Color surfaceHigh;
  final Color accent;
  final Color text;
  final Color muted;
  final Color border;
  final Color outline;
  final Color onAccent;
}

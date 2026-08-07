import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// RiderMate 2.0 — Material 3 Theme
/// Kinetic Precision design system
class AppTheme {
  AppTheme._();

  // ── Dark ColorScheme ────────────────────────────────────────
  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary:              AppColors.softOrange,
    onPrimary:            Color(0xFF561F00),
    primaryContainer:     AppColors.circuitOrange,
    onPrimaryContainer:   Color(0xFF572000),
    secondary:            AppColors.secondary,
    onSecondary:          AppColors.onSecondary,
    secondaryContainer:   AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.onSecondaryContainer,
    tertiary:             AppColors.tertiary,
    onTertiary:           AppColors.onTertiary,
    tertiaryContainer:    AppColors.tertiaryContainer,
    onTertiaryContainer:  Color(0xFF313131),
    error:                AppColors.error,
    onError:              AppColors.onError,
    errorContainer:       AppColors.errorContainer,
    onErrorContainer:     Color(0xFFFFDAD6),
    surface:              AppColors.surfaceDark,
    onSurface:            AppColors.onSurface,
    onSurfaceVariant:     AppColors.onSurfaceVariant,
    outline:              AppColors.outline,
    outlineVariant:       AppColors.outlineVariant,
    shadow:               Colors.black,
    scrim:                Colors.black,
    inverseSurface:       Color(0xFFE2E2E2),
    onInverseSurface:     Color(0xFF2F3131),
    inversePrimary:       Color(0xFFA04100),
    surfaceTint:          AppColors.softOrange,
  );

  // ── Light ColorScheme ────────────────────────────────────────
  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary:              AppColors.circuitOrange,
    onPrimary:            Colors.white,
    primaryContainer:     Color(0xFFFFDBCC),
    onPrimaryContainer:   Color(0xFF351000),
    secondary:            Color(0xFF625B71),
    onSecondary:          Colors.white,
    secondaryContainer:   Color(0xFFE8DEF8),
    onSecondaryContainer: Color(0xFF1E192B),
    tertiary:             Color(0xFF7D5260),
    onTertiary:           Colors.white,
    tertiaryContainer:    Color(0xFFFFD8E4),
    onTertiaryContainer:  Color(0xFF31111D),
    error:                Color(0xFFB3261E),
    onError:              Colors.white,
    errorContainer:       Color(0xFFF9DEDC),
    onErrorContainer:     Color(0xFF410E0B),
    surface:              Color(0xFFFFFBFE),
    onSurface:            Color(0xFF1C1B1F),
    onSurfaceVariant:     Color(0xFF49454F),
    outline:              Color(0xFF79747E),
    outlineVariant:       Color(0xFFCAC4D0),
    shadow:               Colors.black,
    scrim:                Colors.black,
    inverseSurface:       Color(0xFF313033),
    onInverseSurface:     Color(0xFFF4EFF4),
    inversePrimary:       AppColors.softOrange,
    surfaceTint:          AppColors.circuitOrange,
  );

  // ── Dark Theme ───────────────────────────────────────────────
  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: _darkColorScheme,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.surfaceContainerLowest,
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: AppColors.onSurface,
        displayColor: AppColors.onSurface,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.onSurface),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.glassBorder, width: 1),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.circuitOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.softOrange,
          side: const BorderSide(color: AppColors.glassBorder, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerHigh,
        hintStyle: GoogleFonts.inter(
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
          fontSize: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.circuitOrange, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.circuitOrange,
        unselectedItemColor: AppColors.onSurfaceVariant,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainerHigh,
        side: const BorderSide(color: AppColors.glassBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.glassBorder,
        thickness: 1,
        space: 0,
      ),

      iconTheme: const IconThemeData(
        color: AppColors.onSurfaceVariant,
        size: 24,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.circuitOrange;
          return AppColors.surfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.circuitOrange.withValues(alpha: 0.3);
          return AppColors.surfaceContainerHigh;
        }),
      ),
    );
  }

  // ── Light Theme ──────────────────────────────────────────────
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: _lightColorScheme,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: const Color(0xFF1C1B1F),
        displayColor: const Color(0xFF1C1B1F),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),

      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0x0D000000), width: 1),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.circuitOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0x1A000000)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0x1A000000)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.circuitOrange, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}

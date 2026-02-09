import 'package:flutter/material.dart';

import 'fidelux_colors.dart';
import 'fidelux_radius.dart';

/// Assembles the complete FideLux [ThemeData] using Material 3.
///
/// Uses an explicit [ColorScheme] for full control over the palette
/// (no `fromSeed`). All values come from `brand-guidelines.md`.
ThemeData get fideluxTheme {
  const colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: FideLuxColors.primary,
    onPrimary: FideLuxColors.onPrimary,
    primaryContainer: FideLuxColors.primaryContainer,
    onPrimaryContainer: FideLuxColors.onPrimaryContainer,
    secondary: FideLuxColors.secondary,
    onSecondary: FideLuxColors.onSecondary,
    secondaryContainer: FideLuxColors.secondaryContainer,
    onSecondaryContainer: FideLuxColors.onSecondaryContainer,
    tertiary: FideLuxColors.tertiary,
    error: FideLuxColors.error,
    onError: FideLuxColors.onError,
    errorContainer: FideLuxColors.errorContainer,
    surface: FideLuxColors.surface,
    onSurface: FideLuxColors.onSurface,
    surfaceContainerHighest: FideLuxColors.surfaceContainerHigh,
    outline: FideLuxColors.outline,
    outlineVariant: FideLuxColors.outlineVariant,
    shadow: FideLuxColors.shadow,
    scrim: FideLuxColors.scrim,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: FideLuxColors.background,

    // ── Typography ────────────────────────────────────────────────────
    // System fonts (Roboto / SF Pro) per brand-guidelines §6.
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400, height: 1.12),
      displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400, height: 1.16),
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w400, height: 1.25),
      headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w400, height: 1.29),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, height: 1.27),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.5),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.43),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.33),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.43),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.33),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, height: 1.45),
    ),

    // ── Input / TextField (Outlined — brand §5.2) ────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FideLuxRadius.sm),
        borderSide: const BorderSide(color: FideLuxColors.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FideLuxRadius.sm),
        borderSide: const BorderSide(color: FideLuxColors.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FideLuxRadius.sm),
        borderSide: const BorderSide(color: FideLuxColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FideLuxRadius.sm),
        borderSide: const BorderSide(color: FideLuxColors.error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FideLuxRadius.sm),
        borderSide: const BorderSide(color: FideLuxColors.error, width: 2),
      ),
      labelStyle: const TextStyle(color: FideLuxColors.onSurfaceVariant),
      helperStyle: const TextStyle(fontSize: 12, color: FideLuxColors.onSurfaceVariant),
      errorStyle: const TextStyle(fontSize: 12, color: FideLuxColors.error),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),

    // ── Card (Elevated — brand §5.3) ─────────────────────────────────
    cardTheme: CardThemeData(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FideLuxRadius.md),
      ),
      color: FideLuxColors.surface,
    ),

    // ── Navigation Bar (brand §5.7) ──────────────────────────────────
    navigationBarTheme: NavigationBarThemeData(
      height: 80,
      indicatorColor: FideLuxColors.primaryContainer,
      backgroundColor: FideLuxColors.surface,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: FideLuxColors.onPrimaryContainer,
          );
        }
        return const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: FideLuxColors.onSurfaceVariant,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(
            color: FideLuxColors.onPrimaryContainer,
            size: 24,
          );
        }
        return const IconThemeData(
          color: FideLuxColors.onSurfaceVariant,
          size: 24,
        );
      }),
    ),

    // ── FAB (SOS button — brand §5.9) ────────────────────────────────
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: FideLuxColors.alertSos,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FideLuxRadius.lg),
      ),
    ),

    // ── Dialog (brand §5.6) ──────────────────────────────────────────
    dialogTheme: DialogThemeData(
      backgroundColor: FideLuxColors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FideLuxRadius.xl),
      ),
      titleTextStyle: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: FideLuxColors.onSurface,
      ),
    ),
  );
}

/// Dedicated [TextStyle] for financial amounts (monospace).
///
/// Use in contexts where columnar alignment is required.
class FideLuxFinancialStyles {
  FideLuxFinancialStyles._();

  /// Transaction list amount (16px / 600).
  static const transactionAmount = TextStyle(
    fontFamily: 'monospace',
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  /// Transaction detail amount (24px / 700).
  static const detailAmount = TextStyle(
    fontFamily: 'monospace',
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  /// Dashboard KPI (34px / 700).
  static const kpiAmount = TextStyle(
    fontFamily: 'monospace',
    fontSize: 34,
    fontWeight: FontWeight.w700,
  );

  /// Account balance (28px / 600).
  static const balanceAmount = TextStyle(
    fontFamily: 'monospace',
    fontSize: 28,
    fontWeight: FontWeight.w600,
  );
}

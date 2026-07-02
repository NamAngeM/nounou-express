import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  // ─────────────────────────────────────────────────────────────── Light ────
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.accent,
      error: AppColors.danger,
      surface: AppColors.surface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimary,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: AppTypography.textTheme,

    // ── AppBar ────────────────────────────────────────────────────────────
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppTypography.h3,
      iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 22),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
      ),
    ),

    // ── NavigationBar (Material 3) ─────────────────────────────────────
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primarySurface,
      indicatorShape: const RoundedRectangleBorder(
        borderRadius: AppSpacing.chipBorderRadius,
      ),
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTypography.small.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          );
        }
        return AppTypography.small.copyWith(color: AppColors.textSecondary);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primary, size: 22);
        }
        return const IconThemeData(color: AppColors.textSecondary, size: 22);
      }),
    ),

    // ── Card ──────────────────────────────────────────────────────────────
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.cardBorderRadius,
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      margin: EdgeInsets.zero,
      shadowColor: Colors.transparent,
    ),

    // ── Input ─────────────────────────────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariant,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md + 2,
      ),
      border: OutlineInputBorder(
        borderRadius: AppSpacing.inputBorderRadius,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppSpacing.inputBorderRadius,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppSpacing.inputBorderRadius,
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppSpacing.inputBorderRadius,
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppSpacing.inputBorderRadius,
        borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
      ),
      hintStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.textTertiary,
      ),
      labelStyle: AppTypography.labelMd.copyWith(
        color: AppColors.textSecondary,
      ),
      floatingLabelStyle: AppTypography.labelMd.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w700,
      ),
      errorStyle: AppTypography.caption.copyWith(color: AppColors.danger),
      prefixIconColor: AppColors.textSecondary,
    ),

    // ── ElevatedButton ────────────────────────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(54),
        shape: const RoundedRectangleBorder(
          borderRadius: AppSpacing.buttonBorderRadius,
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
        textStyle: AppTypography.buttonLabel,
      ),
    ),

    // ── OutlinedButton ────────────────────────────────────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size.fromHeight(54),
        shape: const RoundedRectangleBorder(
          borderRadius: AppSpacing.buttonBorderRadius,
        ),
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        textStyle: AppTypography.buttonLabel.copyWith(color: AppColors.primary),
      ),
    ),

    // ── TextButton ────────────────────────────────────────────────────────
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppTypography.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ── Chip ──────────────────────────────────────────────────────────────
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceVariant,
      selectedColor: AppColors.primarySurface,
      labelStyle: AppTypography.caption,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: AppSpacing.chipBorderRadius,
      ),
      side: BorderSide.none,
      elevation: 0,
    ),

    // ── Divider ───────────────────────────────────────────────────────────
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 0,
    ),

    // ── Floating Action Button ────────────────────────────────────────────
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: CircleBorder(),
    ),
  );

  // ─────────────────────────────────────────────────────────────── Dark  ────
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      tertiary: AppColors.accent,
      error: AppColors.danger,
      surface: AppColors.darkSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.darkText,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    textTheme: AppTypography.darkTextTheme,

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.darkText,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppTypography.h3.copyWith(color: AppColors.darkText),
      iconTheme: const IconThemeData(color: AppColors.darkText, size: 22),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
      ),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      indicatorColor: AppColors.primary.withValues(alpha: 0.15),
      indicatorShape: const RoundedRectangleBorder(
        borderRadius: AppSpacing.chipBorderRadius,
      ),
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTypography.small.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          );
        }
        return AppTypography.small.copyWith(color: AppColors.darkTextSecondary);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primary, size: 22);
        }
        return const IconThemeData(
          color: AppColors.darkTextSecondary,
          size: 22,
        );
      }),
    ),

    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.cardBorderRadius,
        side: const BorderSide(color: AppColors.darkBorder, width: 1),
      ),
      margin: EdgeInsets.zero,
      shadowColor: Colors.transparent,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurfaceVariant,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md + 2,
      ),
      border: OutlineInputBorder(
        borderRadius: AppSpacing.inputBorderRadius,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppSpacing.inputBorderRadius,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppSpacing.inputBorderRadius,
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppSpacing.inputBorderRadius,
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppSpacing.inputBorderRadius,
        borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
      ),
      hintStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.darkTextSecondary,
      ),
      labelStyle: AppTypography.labelMd.copyWith(
        color: AppColors.darkTextSecondary,
      ),
      floatingLabelStyle: AppTypography.labelMd.copyWith(
        color: AppColors.primary,
      ),
      errorStyle: AppTypography.caption.copyWith(color: AppColors.danger),
      prefixIconColor: AppColors.darkTextSecondary,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(54),
        shape: const RoundedRectangleBorder(
          borderRadius: AppSpacing.buttonBorderRadius,
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
        textStyle: AppTypography.buttonLabel,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size.fromHeight(54),
        shape: const RoundedRectangleBorder(
          borderRadius: AppSpacing.buttonBorderRadius,
        ),
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        textStyle: AppTypography.buttonLabel.copyWith(color: AppColors.primary),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppTypography.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.darkBorder,
      thickness: 1,
      space: 0,
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: CircleBorder(),
    ),
  );
}

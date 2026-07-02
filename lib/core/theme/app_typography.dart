import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTypography {
  // ── Display ────────────────────────────────────────────────────────────────
  static TextStyle get display => GoogleFonts.poppins(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.1,
    letterSpacing: -1.0,
  );

  // ── Headings ───────────────────────────────────────────────────────────────
  static TextStyle get h1 => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static TextStyle get h2 => GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.25,
    letterSpacing: -0.3,
  );

  static TextStyle get h3 => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.35,
    letterSpacing: -0.2,
  );

  static TextStyle get h4 => GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // ── Body ───────────────────────────────────────────────────────────────────
  static TextStyle get bodyLarge => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.55,
  );

  static TextStyle get bodyMedium => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.55,
  );

  static TextStyle get bodySmall => GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // ── Labels ─────────────────────────────────────────────────────────────────
  static TextStyle get labelLg => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
    letterSpacing: 0.1,
  );

  static TextStyle get labelMd => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    height: 1.3,
    letterSpacing: 0.2,
  );

  static TextStyle get overline => GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
    height: 1.2,
    letterSpacing: 1.0,
  );

  // ── Caption / small ────────────────────────────────────────────────────────
  static TextStyle get caption => GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static TextStyle get small => GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // ── Button label ───────────────────────────────────────────────────────────
  static TextStyle get buttonLabel => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1,
    letterSpacing: 0.2,
  );

  static TextStyle get buttonLabelSm => GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1,
    letterSpacing: 0.1,
  );

  // ── Price ──────────────────────────────────────────────────────────────────
  static TextStyle get price => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
    height: 1,
    letterSpacing: -0.3,
  );

  static TextStyle get priceSm => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    height: 1,
  );

  // ── TextTheme for ThemeData ────────────────────────────────────────────────
  static TextTheme get textTheme => TextTheme(
    displayLarge: display,
    displayMedium: h1,
    displaySmall: h2,
    headlineMedium: h3,
    titleLarge: h3,
    titleMedium: h4,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: buttonLabel,
    labelMedium: labelMd,
    labelSmall: small,
  );

  static TextTheme get darkTextTheme => textTheme.apply(
    bodyColor: AppColors.darkText,
    displayColor: AppColors.darkText,
    decorationColor: AppColors.darkText,
  );
}

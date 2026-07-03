import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Primary — bleu indigo du logo ─────────────────────────────────────────
  static const Color primary = Color(0xFF2D3192);
  static const Color primaryDark = Color(0xFF1C226B);
  static const Color primaryLight = Color(0xFF5B63D3);
  static const Color primarySurface = Color(0xFFECEEFF);

  // ── Secondary — variante indigo sombre ────────────────────────────────────
  static const Color secondary = Color(0xFF1A1F5C);
  static const Color secondaryLight = Color(0xFF2D3192);

  // ── Accent — vert du logo ─────────────────────────────────────────────────
  static const Color accent = Color(0xFF3CAB50);
  static const Color accentDark = Color(0xFF2A8A3C);
  static const Color accentSurface = Color(0xFFEAF7EC);

  // ── Gold / Orange — cœur du logo ──────────────────────────────────────────
  static const Color gold = Color(0xFFF5871F);
  static const Color goldSurface = Color(0xFFFFF3E8);

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF3CAB50);
  static const Color successSurface = Color(0xFFEAF7EC);
  static const Color warning = Color(0xFFF5871F);
  static const Color warningSurface = Color(0xFFFFF3E8);
  static const Color danger = Color(0xFFE53935);
  static const Color dangerSurface = Color(0xFFFDECEC);

  // ── Surfaces (fond blanc légèrement bleuté) ────────────────────────────────
  static const Color background = Color(0xFFF5F7FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F2FF);
  static const Color border = Color(0xFFDDE1F5);
  static const Color borderStrong = Color(0xFFB8BEE8);

  // ── Texte ──────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1F5C);
  static const Color textSecondary = Color(0xFF6B72B0);
  static const Color textTertiary = Color(0xFFADB2D8);

  // ── Surfaces sombres ───────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0F1238);
  static const Color darkSurface = Color(0xFF1A1F5C);
  static const Color darkSurfaceVariant = Color(0xFF252B78);
  static const Color darkBorder = Color(0xFF353D9A);

  // ── Texte sombre ───────────────────────────────────────────────────────────
  static const Color darkText = Color(0xFFF5F7FF);
  static const Color darkTextSecondary = Color(0xFFADB2D8);

  // ── Gradients ──────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryDark, primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradientH = LinearGradient(
    colors: [primaryDark, primary],
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [secondary, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFF5F7FF), Color(0xFFECEEFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentDark, accent],
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFE06A10), gold],
  );

  // ── Shadows ────────────────────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF2D3192).withValues(alpha: 0.07),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: const Color(0xFF2D3192).withValues(alpha: 0.03),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get primaryShadow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.30),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: const Color(0xFF2D3192).withValues(alpha: 0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}

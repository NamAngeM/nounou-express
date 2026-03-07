import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Primary palette (coral-orange chaleureux) ──────────────────────────────
  static const Color primary = Color(0xFFE8552A);
  static const Color primaryDark = Color(0xFFC04420);
  static const Color primaryLight = Color(0xFFFF8C6B);
  static const Color primarySurface = Color(0xFFFFF1EC);

  // ── Secondary (navy profond) ───────────────────────────────────────────────
  static const Color secondary = Color(0xFF1B2B3A);
  static const Color secondaryLight = Color(0xFF2D4A6B);

  // ── Accent (teal professionnel) ────────────────────────────────────────────
  static const Color accent = Color(0xFF00A896);
  static const Color accentDark = Color(0xFF00877A);
  static const Color accentSurface = Color(0xFFE6F7F5);

  // ── Gold (badges premium) ──────────────────────────────────────────────────
  static const Color gold = Color(0xFFF5A623);
  static const Color goldSurface = Color(0xFFFFF8EC);

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF2ECC87);
  static const Color successSurface = Color(0xFFE8FBF4);
  static const Color warning = Color(0xFFF5A623);
  static const Color warningSurface = Color(0xFFFFF8EC);
  static const Color danger = Color(0xFFE53935);
  static const Color dangerSurface = Color(0xFFFDECEC);

  // ── Surfaces claires (fond crème chaud) ────────────────────────────────────
  static const Color background = Color(0xFFFDF8F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF9F3EF);
  static const Color border = Color(0xFFEDE5DF);
  static const Color borderStrong = Color(0xFFD4C4BA);

  // ── Texte clair ────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1B2B3A);
  static const Color textSecondary = Color(0xFF7C8FA6);
  static const Color textTertiary = Color(0xFFADBDCD);

  // ── Surfaces sombres ───────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF111827);
  static const Color darkSurface = Color(0xFF1F2937);
  static const Color darkSurfaceVariant = Color(0xFF2D3748);
  static const Color darkBorder = Color(0xFF374151);

  // ── Texte sombre ───────────────────────────────────────────────────────────
  static const Color darkText = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);

  // ── Gradients ──────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryDark, primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradientH = LinearGradient(
    colors: [primaryDark, primary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFDF8F5), Color(0xFFFFF1EC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Shadows ────────────────────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF1B2B3A).withValues(alpha: 0.06),
      blurRadius: 16,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: const Color(0xFF1B2B3A).withValues(alpha: 0.03),
      blurRadius: 4,
      spreadRadius: 0,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get primaryShadow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.30),
      blurRadius: 16,
      spreadRadius: 0,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: const Color(0xFF1B2B3A).withValues(alpha: 0.10),
      blurRadius: 24,
      spreadRadius: 0,
      offset: const Offset(0, 8),
    ),
  ];
}

import 'package:flutter/material.dart';

abstract final class AppSpacing {
  // ── Base scale ─────────────────────────────────────────────────────────────
  static const double xs   = 4;
  static const double sm   = 8;
  static const double md   = 12;
  static const double lg   = 16;
  static const double xl   = 20;
  static const double xxl  = 24;
  static const double xxxl = 32;
  static const double huge = 48;
  static const double mega = 64;

  // ── Screen padding ─────────────────────────────────────────────────────────
  static const EdgeInsets screenPadding  = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets screenPaddingV = EdgeInsets.symmetric(horizontal: xl, vertical: lg);
  static const EdgeInsets pagePadding    = EdgeInsets.fromLTRB(xl, xxl, xl, xl);

  // ── Border radii ───────────────────────────────────────────────────────────
  static const double buttonRadius = 14;
  static const double cardRadius   = 20;
  static const double inputRadius  = 14;
  static const double chipRadius   = 50;
  static const double badgeRadius  = 50;
  static const double sheetRadius  = 28;

  static const BorderRadius buttonBorderRadius =
      BorderRadius.all(Radius.circular(buttonRadius));
  static const BorderRadius cardBorderRadius =
      BorderRadius.all(Radius.circular(cardRadius));
  static const BorderRadius inputBorderRadius =
      BorderRadius.all(Radius.circular(inputRadius));
  static const BorderRadius chipBorderRadius =
      BorderRadius.all(Radius.circular(chipRadius));
  static const BorderRadius badgeBorderRadius =
      BorderRadius.all(Radius.circular(badgeRadius));
  static const BorderRadius sheetBorderRadius =
      BorderRadius.vertical(top: Radius.circular(sheetRadius));
  static const BorderRadius largeBorderRadius =
      BorderRadius.all(Radius.circular(24));
}

import 'package:flutter/material.dart';

/// RiderMate 2.0 — Design Token Colors
/// Source: Stitch handoff + Kinetic Precision design system
class AppColors {
  AppColors._();

  // ── Brand ───────────────────────────────────────────────────
  static const Color circuitOrange = Color(0xFFFF6B00);   // primary-container / CTA
  static const Color softOrange    = Color(0xFFFFB693);   // primary / accent
  static const Color orangeFixed   = Color(0xFFFFDBCC);   // primary-fixed

  // Brand Aliases
  static const Color primary       = circuitOrange;
  static const Color background    = surfaceDark;
  static const Color cardBackground= surfaceContainerHigh;
  static const Color textSecondary = onSurfaceVariant;

  // ── Surface (Dark) ──────────────────────────────────────────
  static const Color surfaceDark            = Color(0xFF121414);
  static const Color surfaceDim             = Color(0xFF121414);
  static const Color surfaceContainerLowest = Color(0xFF0C0F0F);
  static const Color surfaceContainerLow    = Color(0xFF1A1C1C);
  static const Color surfaceContainer       = Color(0xFF1E2020);
  static const Color surfaceContainerHigh   = Color(0xFF282A2B);
  static const Color surfaceContainerHighest= Color(0xFF333535);
  static const Color surfaceBright          = Color(0xFF37393A);
  static const Color surfaceVariant         = Color(0xFF333535);

  // ── Text ────────────────────────────────────────────────────
  static const Color onSurface        = Color(0xFFE2E2E2);   // high contrast text
  static const Color onSurfaceVariant = Color(0xFFE2BFB0);   // muted/label text
  static const Color onBackground     = Color(0xFFE2E2E2);

  // ── Secondary ───────────────────────────────────────────────
  static const Color secondary              = Color(0xFFC8C6C5);
  static const Color secondaryContainer     = Color(0xFF4A4949);
  static const Color onSecondary            = Color(0xFF313030);
  static const Color onSecondaryContainer   = Color(0xFFBAB8B7);

  // ── Tertiary ────────────────────────────────────────────────
  static const Color tertiary           = Color(0xFFC8C6C5);
  static const Color tertiaryContainer  = Color(0xFF9A9999);
  static const Color onTertiary         = Color(0xFF303030);

  // ── Error ───────────────────────────────────────────────────
  static const Color error          = Color(0xFFFFB4AB);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onError        = Color(0xFF690005);

  // ── Outline ─────────────────────────────────────────────────
  static const Color outline        = Color(0xFFA98A7D);
  static const Color outlineVariant = Color(0xFF5A4136);

  // ── Glass ───────────────────────────────────────────────────
  static const Color glassBorder       = Color(0x1AFFFFFF); // white/10
  static const Color glassBorderHigh   = Color(0x26FFFFFF); // white/15
  static const Color glassBg           = Color(0x99121414); // surface/60
  static const Color glassBgElevated   = Color(0xB3121414); // surface/70

  // ── Orange Glow ─────────────────────────────────────────────
  static const Color orangeGlow10 = Color(0x1AFF6B00);
  static const Color orangeGlow20 = Color(0x33FF6B00);
  static const Color orangeGlow40 = Color(0x66FF6B00);

  // ── Light Theme ─────────────────────────────────────────────
  static const Color surfaceLight            = Color(0xFFFFFFFF);
  static const Color backgroundLight        = Color(0xFFF5F5F5);
  static const Color onSurfaceLight         = Color(0xFF1A1A1A);
  static const Color onSurfaceVariantLight  = Color(0xFF5A4136);

  // ── Gradients ───────────────────────────────────────────────
  static const LinearGradient orangeGradient = LinearGradient(
    colors: [circuitOrange, Color(0xFFFF9240)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [surfaceContainerHigh, surfaceContainerLowest],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const RadialGradient ambientGlow = RadialGradient(
    colors: [Color(0x0DFF6B00), Colors.transparent],
    radius: 0.8,
  );
}

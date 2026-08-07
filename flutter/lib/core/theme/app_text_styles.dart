import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// RiderMate 2.0 — Typography Scale
/// Headers: Hanken Grotesk · Body: Inter · Mono: JetBrains Mono
class AppTextStyles {
  AppTextStyles._();

  // ── Display Stat ────────────────────────────────────────────
  /// 48px / 56px / -0.02em / 700  —  Big numbers (dashboard stats)
  static TextStyle displayStat({Color? color}) => GoogleFonts.hankenGrotesk(
    fontSize: 48,
    height: 56 / 48,
    letterSpacing: -0.02 * 48,
    fontWeight: FontWeight.w700,
    color: color,
  );

  /// 32px variant of displayStat
  static TextStyle displayStatSm({Color? color}) => GoogleFonts.hankenGrotesk(
    fontSize: 32,
    height: 40 / 32,
    letterSpacing: -0.01 * 32,
    fontWeight: FontWeight.w700,
    color: color,
  );

  // ── Headlines ───────────────────────────────────────────────
  /// 32px / 40px / -0.01em / 600
  static TextStyle headlineLg({Color? color}) => GoogleFonts.hankenGrotesk(
    fontSize: 32,
    height: 40 / 32,
    letterSpacing: -0.01 * 32,
    fontWeight: FontWeight.w600,
    color: color,
  );

  /// 24px / 32px / 600
  static TextStyle headlineMd({Color? color}) => GoogleFonts.hankenGrotesk(
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w600,
    color: color,
  );

  /// 18px / 24px / 600  — Section titles
  static TextStyle headlineSm({Color? color}) => GoogleFonts.hankenGrotesk(
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w600,
    color: color,
  );

  // ── Body ────────────────────────────────────────────────────
  /// 18px / 28px / 400
  static TextStyle bodyLg({Color? color}) => GoogleFonts.inter(
    fontSize: 18,
    height: 28 / 18,
    fontWeight: FontWeight.w400,
    color: color,
  );

  /// 16px / 24px / 400
  static TextStyle bodyMd({Color? color}) => GoogleFonts.inter(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    color: color,
  );

  /// 14px / 20px / 400  — Small descriptions
  static TextStyle bodySm({Color? color}) => GoogleFonts.inter(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    color: color,
  );

  /// 13px / 18px / 400
  static TextStyle bodyXs({Color? color}) => GoogleFonts.inter(
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w400,
    color: color,
  );

  // ── Stat Label ──────────────────────────────────────────────
  /// 14px / 20px / 600  — Metric values
  static TextStyle statLabel({Color? color}) => GoogleFonts.inter(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w600,
    color: color,
  );

  /// 16px / 20px / 600
  static TextStyle statLabelMd({Color? color}) => GoogleFonts.inter(
    fontSize: 16,
    height: 20 / 16,
    fontWeight: FontWeight.w600,
    color: color,
  );

  // ── Label Caps (JetBrains Mono) ─────────────────────────────
  /// 12px / 16px / 0.05em / 500  — ALL CAPS labels
  static TextStyle labelCaps({Color? color}) => GoogleFonts.jetBrainsMono(
    fontSize: 12,
    height: 16 / 12,
    letterSpacing: 0.05 * 12,
    fontWeight: FontWeight.w500,
    color: color,
  );

  /// 10px mono caps
  static TextStyle labelCapsSm({Color? color}) => GoogleFonts.jetBrainsMono(
    fontSize: 10,
    height: 14 / 10,
    letterSpacing: 0.05 * 10,
    fontWeight: FontWeight.w500,
    color: color,
  );

  static TextStyle labelCap({Color? color}) => labelCaps(color: color);

  // ── Button ──────────────────────────────────────────────────
  static TextStyle button({Color? color}) => GoogleFonts.inter(
    fontSize: 16,
    height: 1.25,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    color: color,
  );

  static TextStyle buttonSm({Color? color}) => GoogleFonts.inter(
    fontSize: 14,
    height: 1.25,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: color,
  );

  // ── Legacy / Convenient Aliases ─────────────────────────────
  static TextStyle h1({Color? color}) => headlineLg(color: color);
  static TextStyle h2({Color? color}) => headlineMd(color: color);
  static TextStyle h3({Color? color}) => headlineSm(color: color);
  static TextStyle h4({Color? color}) => bodyLg(color: color);
  static TextStyle body({Color? color}) => bodyMd(color: color);
  static TextStyle bodyText({Color? color}) => bodyMd(color: color);
  static TextStyle caption({Color? color}) => labelCapsSm(color: color);
  static TextStyle label({Color? color}) => labelCaps(color: color);
  static TextStyle labelStyle({Color? color}) => labelCaps(color: color);
  static TextStyle subtitle({Color? color}) => bodySm(color: color);
}

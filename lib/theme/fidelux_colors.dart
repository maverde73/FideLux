import 'package:flutter/material.dart';

/// FideLux color palette from brand-guidelines.md §9.
///
/// All colors are derived from the 3-level token architecture:
/// Primitive → Semantic → Component.
class FideLuxColors {
  FideLuxColors._();

  // ── Surfaces ──────────────────────────────────────────────────────────
  static const background = Color(0xFFFFFFFF);
  static const onBackground = Color(0xFF1C1A15);
  static const surface = Color(0xFFFAFAF8);
  static const onSurface = Color(0xFF1C1A15);
  static const surfaceVariant = Color(0xFFECEAE6);
  static const onSurfaceVariant = Color(0xFF6B6760);
  static const surfaceContainer = Color(0xFFF5F3F0);
  static const surfaceContainerHigh = Color(0xFFECEAE6);

  // ── Primary (Amber / Gold) ────────────────────────────────────────────
  static const primary = Color(0xFFD4A017);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFFFECB3);
  static const onPrimaryContainer = Color(0xFF5C4306);

  // ── Secondary (Teal) ──────────────────────────────────────────────────
  static const secondary = Color(0xFF1A8A7E);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFB2DFDB);
  static const onSecondaryContainer = Color(0xFF0E6B61);

  // ── Tertiary (Blue — links, info) ─────────────────────────────────────
  static const tertiary = Color(0xFF1976D2);

  // ── Error ─────────────────────────────────────────────────────────────
  static const error = Color(0xFFD32F2F);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFE0E0);

  // ── Status ────────────────────────────────────────────────────────────
  static const success = Color(0xFF43A047);
  static const successContainer = Color(0xFFDCEDC8);
  static const warning = Color(0xFFF57C00);

  // ── Outline ───────────────────────────────────────────────────────────
  static const outline = Color(0xFFC8C4BD);
  static const outlineVariant = Color(0xFFE0DDD8);

  // ── Shadow / Scrim ────────────────────────────────────────────────────
  static const shadow = Color(0xFF0D0C0A);
  static const scrim = Color(0xFF0D0C0A);

  // ── FideLux-specific ──────────────────────────────────────────────────
  static const scoreHigh = Color(0xFF43A047);
  static const scoreMedium = Color(0xFFF57C00);
  static const scoreLow = Color(0xFFD32F2F);
  static const scoreBackground = Color(0xFFFFF8E1);
  static const alertSos = Color(0xFFB71C1C);
  static const chainVerified = Color(0xFF43A047);
  static const chainPending = Color(0xFFFF9800);
  static const chainBroken = Color(0xFFD32F2F);
  static const chainLinkIcon = Color(0xFFD4A017);
  static const inboxUnread = Color(0xFFD4A017);
  static const inboxProcessed = Color(0xFF43A047);
  static const inboxFlagged = Color(0xFFE57373);
}

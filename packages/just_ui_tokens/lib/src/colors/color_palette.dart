import 'package:flutter/painting.dart';

/// The raw color palette for JustUI.
///
/// Contains 11 shades for each color category following a scale from 50 to 950.
/// All colors are defined as compile-time constants.
abstract final class JustColorPalette {
  /// Pure white color
  static const Color white = Color(0xFFFFFFFF);
  /// Pure black color
  static const Color black = Color(0xFF000000);

  // --- Neutral (Slate-like) ---
  /// Neutral shade 50 (lightest surface backgrounds)
  static const Color neutral50 = Color(0xFFF8FAFC);
  /// Neutral shade 100
  static const Color neutral100 = Color(0xFFF1F5F9);
  /// Neutral shade 200
  static const Color neutral200 = Color(0xFFE2E8F0);
  /// Neutral shade 300
  static const Color neutral300 = Color(0xFFCBD5E1);
  /// Neutral shade 400
  static const Color neutral400 = Color(0xFF94A3B8);
  /// Neutral shade 500 (base neutral, disabled text/icons)
  static const Color neutral500 = Color(0xFF64748B);
  /// Neutral shade 600
  static const Color neutral600 = Color(0xFF475569);
  /// Neutral shade 700 (secondary text/borders in light mode)
  static const Color neutral700 = Color(0xFF334155);
  /// Neutral shade 800 (primary text in dark mode)
  static const Color neutral800 = Color(0xFF1E293B);
  /// Neutral shade 900 (background in dark mode)
  static const Color neutral900 = Color(0xFF0F172A);
  /// Neutral shade 950 (darkest dark background)
  static const Color neutral950 = Color(0xFF020617);

  // --- Primary (Blue) ---
  /// Primary shade 50
  static const Color primary50 = Color(0xFFEFF6FF);
  /// Primary shade 100
  static const Color primary100 = Color(0xFFDBEAFE);
  /// Primary shade 200
  static const Color primary200 = Color(0xFFBFDBFE);
  /// Primary shade 300
  static const Color primary300 = Color(0xFF93C5FD);
  /// Primary shade 400
  static const Color primary400 = Color(0xFF60A5FA);
  /// Primary shade 500 (base primary)
  static const Color primary500 = Color(0xFF3B82F6);
  /// Primary shade 600
  static const Color primary600 = Color(0xFF2563EB);
  /// Primary shade 700
  static const Color primary700 = Color(0xFF1D4ED8);
  /// Primary shade 800
  static const Color primary800 = Color(0xFF1E40AF);
  /// Primary shade 900
  static const Color primary900 = Color(0xFF1E3A8A);
  /// Primary shade 950
  static const Color primary950 = Color(0xFF172554);

  // --- Success (Green) ---
  /// Success shade 50
  static const Color success50 = Color(0xFFF0FDF4);
  /// Success shade 100
  static const Color success100 = Color(0xFFDCFCE7);
  /// Success shade 200
  static const Color success200 = Color(0xFFBBF7D0);
  /// Success shade 300
  static const Color success300 = Color(0xFF86EFAC);
  /// Success shade 400
  static const Color success400 = Color(0xFF4ADE80);
  /// Success shade 500 (base success)
  static const Color success500 = Color(0xFF22C55E);
  /// Success shade 600
  static const Color success600 = Color(0xFF16A34A);
  /// Success shade 700
  static const Color success700 = Color(0xFF15803D);
  /// Success shade 800
  static const Color success800 = Color(0xFF166534);
  /// Success shade 900
  static const Color success900 = Color(0xFF14532D);
  /// Success shade 950
  static const Color success950 = Color(0xFF052E16);

  // --- Warning (Amber) ---
  /// Warning shade 50
  static const Color warning50 = Color(0xFFFFFBEB);
  /// Warning shade 100
  static const Color warning100 = Color(0xFFFEF3C7);
  /// Warning shade 200
  static const Color warning200 = Color(0xFFFDE68A);
  /// Warning shade 300
  static const Color warning300 = Color(0xFFFCD34D);
  /// Warning shade 400
  static const Color warning400 = Color(0xFFFBBF24);
  /// Warning shade 500 (base warning)
  static const Color warning500 = Color(0xFFF59E0B);
  /// Warning shade 600
  static const Color warning600 = Color(0xFFD97706);
  /// Warning shade 700
  static const Color warning700 = Color(0xFFB45309);
  /// Warning shade 800
  static const Color warning800 = Color(0xFF92400E);
  /// Warning shade 900
  static const Color warning900 = Color(0xFF78350F);
  /// Warning shade 950
  static const Color warning950 = Color(0xFF451A03);

  // --- Error (Red) ---
  /// Error shade 50
  static const Color error50 = Color(0xFFFEF2F2);
  /// Error shade 100
  static const Color error100 = Color(0xFFFEE2E2);
  /// Error shade 200
  static const Color error200 = Color(0xFFFECACA);
  /// Error shade 300
  static const Color error300 = Color(0xFFFCA5A5);
  /// Error shade 400
  static const Color error400 = Color(0xFFF87171);
  /// Error shade 500 (base error)
  static const Color error500 = Color(0xFFEF4444);
  /// Error shade 600
  static const Color error600 = Color(0xFFDC2626);
  /// Error shade 700
  static const Color error700 = Color(0xFFB91C1C);
  /// Error shade 800
  static const Color error800 = Color(0xFF991B1B);
  /// Error shade 900
  static const Color error900 = Color(0xFF7F1D1D);
  /// Error shade 950
  static const Color error950 = Color(0xFF450A0A);

  // --- Info (Cyan) ---
  /// Info shade 50
  static const Color info50 = Color(0xFFECFEFF);
  /// Info shade 100
  static const Color info100 = Color(0xFFCFFAFE);
  /// Info shade 200
  static const Color info200 = Color(0xFFA5F3FC);
  /// Info shade 300
  static const Color info300 = Color(0xFF67E8F9);
  /// Info shade 400
  static const Color info400 = Color(0xFF22D3EE);
  /// Info shade 500 (base info)
  static const Color info500 = Color(0xFF06B6D4);
  /// Info shade 600
  static const Color info600 = Color(0xFF0891B2);
  /// Info shade 700
  static const Color info700 = Color(0xFF0E7490);
  /// Info shade 800
  static const Color info800 = Color(0xFF155E75);
  /// Info shade 900
  static const Color info900 = Color(0xFF164E63);
  /// Info shade 950
  static const Color info950 = Color(0xFF083344);
}

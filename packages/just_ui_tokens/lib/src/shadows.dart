import 'package:flutter/painting.dart';

/// Shadow tokens for JustUI.
///
/// Uses multi-layer [BoxShadow] designs to achieve modern, premium, soft-depth shadows.
/// Direct hex values are used for opacity to keep the tokens as compile-time constants.
abstract final class JustShadows {
  // ==========================================
  // --- Light Mode Shadows ---
  // ==========================================

  /// Extra small light shadow (subtle depth)
  static const List<BoxShadow> xs = [
    BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 2.0,
      spreadRadius: 0.0,
      color: Color(0x0D000000), // 5% black
    ),
  ];

  /// Small light shadow (cards / dropdowns)
  static const List<BoxShadow> sm = [
    BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 2.0,
      spreadRadius: 0.0,
      color: Color(0x08000000), // 3% black
    ),
    BoxShadow(
      offset: Offset(0, 2),
      blurRadius: 4.0,
      spreadRadius: 0.0,
      color: Color(0x14000000), // 8% black
    ),
  ];

  /// Medium light shadow (interactive popovers)
  static const List<BoxShadow> md = [
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 6.0,
      spreadRadius: -1.0,
      color: Color(0x1A000000), // 10% black
    ),
    BoxShadow(
      offset: Offset(0, 2),
      blurRadius: 4.0,
      spreadRadius: -1.0,
      color: Color(0x0F000000), // 6% black
    ),
  ];

  /// Large light shadow (menus / dialogs)
  static const List<BoxShadow> lg = [
    BoxShadow(
      offset: Offset(0, 10),
      blurRadius: 15.0,
      spreadRadius: -3.0,
      color: Color(0x1A000000), // 10% black
    ),
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 6.0,
      spreadRadius: -2.0,
      color: Color(0x0F000000), // 6% black
    ),
  ];

  /// Extra large light shadow (modals)
  static const List<BoxShadow> xl = [
    BoxShadow(
      offset: Offset(0, 20),
      blurRadius: 25.0,
      spreadRadius: -5.0,
      color: Color(0x1A000000), // 10% black
    ),
    BoxShadow(
      offset: Offset(0, 10),
      blurRadius: 10.0,
      spreadRadius: -5.0,
      color: Color(0x0F000000), // 6% black
    ),
  ];

  /// Double extra large light shadow (toasts / floating sheets)
  static const List<BoxShadow> xxl = [
    BoxShadow(
      offset: Offset(0, 25),
      blurRadius: 50.0,
      spreadRadius: -12.0,
      color: Color(0x40000000), // 25% black
    ),
  ];

  // ==========================================
  // --- Dark Mode Shadows (More Subtle) ---
  // ==========================================

  /// Extra small dark shadow
  static const List<BoxShadow> xsDark = [
    BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 2.0,
      spreadRadius: 0.0,
      color: Color(0x33000000), // 20% black
    ),
  ];

  /// Small dark shadow
  static const List<BoxShadow> smDark = [
    BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 2.0,
      spreadRadius: 0.0,
      color: Color(0x1F000000), // 12% black
    ),
    BoxShadow(
      offset: Offset(0, 2),
      blurRadius: 4.0,
      spreadRadius: 0.0,
      color: Color(0x3D000000), // 24% black
    ),
  ];

  /// Medium dark shadow
  static const List<BoxShadow> mdDark = [
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 6.0,
      spreadRadius: -1.0,
      color: Color(0x40000000), // 25% black
    ),
    BoxShadow(
      offset: Offset(0, 2),
      blurRadius: 4.0,
      spreadRadius: -1.0,
      color: Color(0x26000000), // 15% black
    ),
  ];

  /// Large dark shadow
  static const List<BoxShadow> lgDark = [
    BoxShadow(
      offset: Offset(0, 10),
      blurRadius: 15.0,
      spreadRadius: -3.0,
      color: Color(0x4D000000), // 30% black
    ),
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 6.0,
      spreadRadius: -2.0,
      color: Color(0x33000000), // 20% black
    ),
  ];

  /// Extra large dark shadow
  static const List<BoxShadow> xlDark = [
    BoxShadow(
      offset: Offset(0, 20),
      blurRadius: 25.0,
      spreadRadius: -5.0,
      color: Color(0x59000000), // 35% black
    ),
    BoxShadow(
      offset: Offset(0, 10),
      blurRadius: 10.0,
      spreadRadius: -5.0,
      color: Color(0x40000000), // 25% black
    ),
  ];

  /// Double extra large dark shadow
  static const List<BoxShadow> xxlDark = [
    BoxShadow(
      offset: Offset(0, 25),
      blurRadius: 50.0,
      spreadRadius: -12.0,
      color: Color(0x80000000), // 50% black
    ),
  ];

  /// Generates a dynamic dual-layer brand-tinted shadow for a given brand seed color.
  ///
  /// Composes a crisp key shadow and a soft, tinted ambient shadow.
  static List<BoxShadow> generate({
    required Color seedColor,
    required double elevation,
    bool isDark = false,
  }) {
    final int elev = elevation.round();

    final double ambientOpacity;
    final Color keyColor;

    final Offset keyOffset;
    final double keyBlur;
    final double keySpread;

    final Offset ambientOffset;
    final double ambientBlur;
    final double ambientSpread;

    if (elev <= 1) {
      keyColor = isDark ? const Color(0x33000000) : const Color(0x0D000000);
      ambientOpacity = isDark ? 0.12 : 0.04;

      keyOffset = const Offset(0, 1);
      keyBlur = 2.0;
      keySpread = 0.0;

      ambientOffset = Offset.zero;
      ambientBlur = 1.0;
      ambientSpread = 0.0;
    } else if (elev <= 2) {
      keyColor = isDark ? const Color(0x3D000000) : const Color(0x14000000);
      ambientOpacity = isDark ? 0.16 : 0.06;

      keyOffset = const Offset(0, 2);
      keyBlur = 4.0;
      keySpread = 0.0;

      ambientOffset = const Offset(0, 1);
      ambientBlur = 2.0;
      ambientSpread = 0.0;
    } else if (elev <= 4) {
      keyColor = isDark ? const Color(0x40000000) : const Color(0x1A000000);
      ambientOpacity = isDark ? 0.20 : 0.08;

      keyOffset = const Offset(0, 4);
      keyBlur = 6.0;
      keySpread = -1.0;

      ambientOffset = const Offset(0, 2);
      ambientBlur = 4.0;
      ambientSpread = -1.0;
    } else if (elev <= 8) {
      keyColor = isDark ? const Color(0x4D000000) : const Color(0x1A000000);
      ambientOpacity = isDark ? 0.24 : 0.10;

      keyOffset = const Offset(0, 10);
      keyBlur = 15.0;
      keySpread = -3.0;

      ambientOffset = const Offset(0, 4);
      ambientBlur = 6.0;
      ambientSpread = -2.0;
    } else if (elev <= 16) {
      keyColor = isDark ? const Color(0x59000000) : const Color(0x1A000000);
      ambientOpacity = isDark ? 0.28 : 0.12;

      keyOffset = const Offset(0, 20);
      keyBlur = 25.0;
      keySpread = -5.0;

      ambientOffset = const Offset(0, 10);
      ambientBlur = 10.0;
      ambientSpread = -5.0;
    } else {
      keyColor = isDark ? const Color(0x80000000) : const Color(0x40000000);
      ambientOpacity = isDark ? 0.32 : 0.15;

      keyOffset = const Offset(0, 25);
      keyBlur = 50.0;
      keySpread = -12.0;

      ambientOffset = const Offset(0, 12);
      ambientBlur = 24.0;
      ambientSpread = -6.0;
    }

    return [
      BoxShadow(
        offset: keyOffset,
        blurRadius: keyBlur,
        spreadRadius: keySpread,
        color: keyColor,
      ),
      BoxShadow(
        offset: ambientOffset,
        blurRadius: ambientBlur,
        spreadRadius: ambientSpread,
        color: seedColor.withValues(alpha: ambientOpacity),
      ),
    ];
  }
}

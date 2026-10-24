import 'dart:ui' show Color;

/// Ink and Paper color roles, keyed by their CSS custom property name.
///
/// The values mirror the scoped Ink and Paper block in
/// `apps/docs/src/app/globals.css` (light and dark). The docs page and the
/// bridge must paint the same roles, so `test/theme/ink_paper_drift_test.dart`
/// parses that file and fails when a value here differs. The block is
/// temporary: PRD phases P1-P6 replace both with generated tokens.
abstract final class InkPaperTokens {
  /// Roles of the light (paper) mode.
  static const Map<String, Color> light = <String, Color>{
    '--ip-canvas': Color(0xFFFBFAF8),
    '--ip-surface': Color(0xFFFFFFFF),
    '--ip-raised': Color(0xFFFFFFFF),
    '--ip-sunken': Color(0xFFF3F1EF),
    '--ip-hover': Color(0xFFF3F1EF),
    '--ip-selection': Color(0xFFE1DFDD),
    '--ip-text-primary': Color(0xFF11100F),
    '--ip-text-secondary': Color(0xFF42413F),
    '--ip-text-tertiary': Color(0xFF51504D),
    '--ip-text-disabled': Color(0xFF93928F),
    '--ip-border-subtle': Color(0xFFE1DFDD),
    '--ip-border-control': Color(0xFF81807D),
    '--ip-inverse': Color(0xFF11100F),
    '--ip-inverse-hover': Color(0xFF2B2A28),
    '--ip-inverse-pressed': Color(0xFF3B3A38),
    '--ip-on-inverse': Color(0xFFFBFAF8),
    '--ip-error': Color(0xFF901114),
    '--ip-error-hover': Color(0xFF9A1F1D),
    '--ip-error-tint': Color(0xFFFEF0EE),
    '--ip-success': Color(0xFF115629),
    '--ip-success-tint': Color(0xFFEDF6EE),
    '--ip-warning': Color(0xFF723F00),
    '--ip-warning-tint': Color(0xFFFAF2E9),
  };

  /// Roles of the dark (ink) mode.
  static const Map<String, Color> dark = <String, Color>{
    '--ip-canvas': Color(0xFF0D0C0A),
    '--ip-surface': Color(0xFF151412),
    '--ip-raised': Color(0xFF1D1C1A),
    '--ip-sunken': Color(0xFF090807),
    '--ip-hover': Color(0xFF1D1C1A),
    '--ip-selection': Color(0xFF3B3A38),
    '--ip-text-primary': Color(0xFFF1F0EE),
    '--ip-text-secondary': Color(0xFFC4C2C0),
    '--ip-text-tertiary': Color(0xFFAEACA9),
    '--ip-text-disabled': Color(0xFF646361),
    '--ip-border-subtle': Color(0xFF2B2A28),
    '--ip-border-control': Color(0xFF767472),
    '--ip-inverse': Color(0xFFF1F0EE),
    '--ip-inverse-hover': Color(0xFFD2D1CE),
    '--ip-inverse-pressed': Color(0xFFBFBDBB),
    '--ip-on-inverse': Color(0xFF0D0C0A),
    '--ip-error': Color(0xFFF8A59B),
    '--ip-error-hover': Color(0xFFE9978D),
    '--ip-error-tint': Color(0xFF241513),
    '--ip-success': Color(0xFF99CDA3),
    '--ip-success-tint': Color(0xFF111D13),
    '--ip-warning': Color(0xFFE3B47D),
    '--ip-warning-tint': Color(0xFF21170C),
  };
}

/// Typed access to one mode of [InkPaperTokens].
class const InkPaperRoles(
  /// The role map of one mode, [InkPaperTokens.light] or [InkPaperTokens.dark].
  final Map<String, Color> roles,
) {
  Color _role(String name) => roles[name]!;

  /// Page background.
  Color get canvas => _role('--ip-canvas');

  /// Cards and containers.
  Color get surface => _role('--ip-surface');

  /// Dialogs and popovers.
  Color get raised => _role('--ip-raised');

  /// Wells, code blocks and filled fields.
  Color get sunken => _role('--ip-sunken');

  /// Hover fill.
  Color get hover => _role('--ip-hover');

  /// Selected item fill.
  Color get selection => _role('--ip-selection');

  /// Main text and ink borders.
  Color get textPrimary => _role('--ip-text-primary');

  /// Secondary text.
  Color get textSecondary => _role('--ip-text-secondary');

  /// Tertiary text.
  Color get textTertiary => _role('--ip-text-tertiary');

  /// Disabled text.
  Color get textDisabled => _role('--ip-text-disabled');

  /// Hairlines between containers.
  Color get borderSubtle => _role('--ip-border-subtle');

  /// Borders of controls (inputs, unchecked boxes).
  Color get borderControl => _role('--ip-border-control');

  /// Ink fill of primary actions.
  Color get inverse => _role('--ip-inverse');

  /// Hovered ink fill.
  Color get inverseHover => _role('--ip-inverse-hover');

  /// Pressed ink fill.
  Color get inversePressed => _role('--ip-inverse-pressed');

  /// Text on the ink fill.
  Color get onInverse => _role('--ip-on-inverse');

  /// Oxblood: validation and destructive actions.
  Color get error => _role('--ip-error');

  /// Hovered oxblood.
  Color get errorHover => _role('--ip-error-hover');

  /// Oxblood tint behind error text.
  Color get errorTint => _role('--ip-error-tint');

  /// Bottle green: success.
  Color get success => _role('--ip-success');

  /// Bottle green tint.
  Color get successTint => _role('--ip-success-tint');

  /// Cognac: warnings.
  Color get warning => _role('--ip-warning');

  /// Cognac tint.
  Color get warningTint => _role('--ip-warning-tint');
}

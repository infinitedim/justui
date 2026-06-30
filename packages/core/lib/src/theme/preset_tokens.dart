import 'package:flutter/widgets.dart';
import 'package:just_ui_tokens/just_ui_tokens.dart';
import 'theme_data.dart';

/// Semantic shadow elevation levels, decoupled from preset-specific
/// shadow implementations (blurred vs flat-offset).
enum JustShadowLevel { xs, sm, md, lg, xl, xxl }

/// Abstraction over all preset-specific visual decisions.
///
/// Instead of components branching on `theme.preset == JustThemePreset.neobrutalism`,
/// they resolve visual values through this contract. Adding a new preset means
/// implementing this class once — no changes needed in any component.
abstract class JustPresetTokens {
  const JustPresetTokens();

  /// Standard border width for component containers (buttons, cards, inputs, etc).
  /// Returns 0.0 for presets with no visible border by default.
  double get borderWidth;

  /// Border width for emphasized/accent elements (e.g. active sidebar item).
  double get emphasizedBorderWidth;

  /// Resolves border radius for a component container.
  ///
  /// [isPill] — true for components that should always stay fully rounded
  /// regardless of preset (badges, pill buttons).
  /// [isCircle] — true for components that should always stay circular
  /// (avatars, radio dots, status indicators).
  BorderRadius resolveBorderRadius(
    JustRadiusScheme radius, {
    bool isPill = false,
    bool isCircle = false,
  });

  /// Resolves the shadow list for a given elevation level and press state.
  ///
  /// Implementations decide whether shadows blur (default) or use flat
  /// offset shadows (neobrutalism), and how pressed state collapses them.
  List<BoxShadow> resolveShadow(
    JustShadowScheme shadows,
    JustShadowLevel level, {
    required bool isPressed,
  });

  /// Wraps [child] with the preset's press interaction effect
  /// (e.g. scale-down for default, translate-offset for neobrutalism).
  Widget buildPressEffect({
    required Widget child,
    required bool isPressed,
    required JustMotionProfile animations,
    Offset? customOffset,
    double? customScale,
  });

  /// Resolves decoration for hover state. Returns null if the preset has
  /// no distinct hover decoration (relies on opacity/color shift handled
  /// elsewhere instead).
  BoxDecoration? resolveHoverDecoration(
    JustColorScheme colors, {
    Color? accentColor,
    BorderRadius? borderRadius,
  });

  /// Whether this preset shows a visible border by default on neutral
  /// (non-emphasized) containers like cards and inputs.
  bool get showsDefaultBorder;
}

/// Default preset — soft shadows, minimal/no borders, rounded corners,
/// scale-based press feedback.
class DefaultPresetTokens extends JustPresetTokens {
  const DefaultPresetTokens();

  @override
  double get borderWidth => 1.0;

  @override
  double get emphasizedBorderWidth => 2.0;

  @override
  bool get showsDefaultBorder => false;

  @override
  BorderRadius resolveBorderRadius(
    JustRadiusScheme radius, {
    bool isPill = false,
    bool isCircle = false,
  }) {
    if (isCircle) return .all(radius.full);
    if (isPill) return .all(radius.full);
    return .all(radius.md);
  }

  @override
  List<BoxShadow> resolveShadow(
    JustShadowScheme shadows,
    JustShadowLevel level, {
    required bool isPressed,
  }) {
    final base = switch (level) {
      .xs => shadows.xs,
      .sm => shadows.sm,
      .md => shadows.md,
      .lg => shadows.lg,
      .xl => shadows.xl,
      .xxl => shadows.xxl,
    };
    if (isPressed) {
      // Default preset: pressed state reduces elevation slightly rather
      // than fully collapsing the shadow.
      return base
          .map(
            (s) => s.copyWith(
              blurRadius: s.blurRadius * 0.6,
              offset: s.offset * 0.5,
            ),
          )
          .toList();
    }
    return base;
  }

  @override
  Widget buildPressEffect({
    required Widget child,
    required bool isPressed,
    required JustMotionProfile animations,
    Offset? customOffset,
    double? customScale,
  }) {
    return AnimatedScale(
      scale: isPressed ? (customScale ?? 0.97) : 1.0,
      duration: animations.instant,
      curve: animations.defaultCurve,
      child: child,
    );
  }

  @override
  BoxDecoration? resolveHoverDecoration(
    JustColorScheme colors, {
    Color? accentColor,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: (accentColor ?? colors.borderDefault).withValues(alpha: 0.06),
      borderRadius: borderRadius,
    );
  }
}

/// Neobrutalism preset — thick solid borders, flat offset shadows,
/// translate-based press feedback (no scale), sharp corners by default.
class NeobrutalismPresetTokens extends JustPresetTokens {
  const NeobrutalismPresetTokens();

  @override
  double get borderWidth => 2.5;

  @override
  double get emphasizedBorderWidth => 3.0;

  @override
  bool get showsDefaultBorder => true;

  @override
  BorderRadius resolveBorderRadius(
    JustRadiusScheme radius, {
    bool isPill = false,
    bool isCircle = false,
  }) {
    if (isCircle) return .all(radius.full);
    if (isPill) return .all(radius.full);
    return .zero;
  }

  @override
  List<BoxShadow> resolveShadow(
    JustShadowScheme shadows,
    JustShadowLevel level, {
    required bool isPressed,
  }) {
    if (isPressed) {
      // Neobrutalism: pressed state fully collapses the offset shadow
      // to simulate the element being "pushed into" the surface.
      return const [];
    }
    final base = switch (level) {
      .xs => shadows.xs,
      .sm => shadows.sm,
      .md => shadows.md,
      .lg => shadows.lg,
      .xl => shadows.xl,
      .xxl => shadows.xxl,
    };
    return base;
  }

  @override
  Widget buildPressEffect({
    required Widget child,
    required bool isPressed,
    required JustMotionProfile animations,
    Offset? customOffset,
    double? customScale,
  }) {
    final offset = customOffset ?? const Offset(4.0, 4.0);
    return AnimatedContainer(
      duration: animations.instant,
      curve: animations.defaultCurve,
      transform: .translationValues(
        isPressed ? offset.dx : 0.0,
        isPressed ? offset.dy : 0.0,
        0.0,
      ),
      child: child,
    );
  }

  @override
  BoxDecoration? resolveHoverDecoration(
    JustColorScheme colors, {
    Color? accentColor,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: (accentColor ?? colors.borderDefault).withValues(alpha: 0.08),
      border: .all(color: colors.borderDefault, width: borderWidth),
      borderRadius: borderRadius ?? .zero,
    );
  }
}

/// Resolves the [JustPresetTokens] implementation for a given preset.
extension JustThemePresetTokensX on JustThemePreset {
  JustPresetTokens get tokens {
    switch (this) {
      case .default_:
        return const DefaultPresetTokens();
      case .neobrutalism:
        return const NeobrutalismPresetTokens();
    }
  }
}

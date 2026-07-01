import 'package:flutter/widgets.dart';
import 'package:just_ui_tokens/just_ui_tokens.dart';
import '../components/slider/just_slider_style.dart' show JustSliderSize;
import '../components/progress/just_progress_variants.dart' show JustProgressSize;
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

  /// Resolves the track height for a slider size.
  double resolveSliderTrackHeight(JustSliderSize size);

  /// Resolves the thumb size (diameter) for a slider size.
  double resolveSliderThumbSize(JustSliderSize size);

  /// Whether slider haptic feedback is enabled by default.
  bool get sliderHapticDefault;

  /// Resolves the stroke width for a circular/linear progress indicator size.
  double resolveProgressStrokeWidth(JustProgressSize size);

  /// Resolves the font weight for a progress indicator's label.
  FontWeight get progressLabelFontWeight;

  /// Resolves the thickness for a separator.
  double resolveSeparatorThickness(double thickness);

  /// The default thickness for a tab indicator.
  double get tabIndicatorThickness;

  /// Resolves the transition duration for a focus ring/effect.
  Duration resolveFocusTransitionDuration(JustMotionProfile animations);

  /// Resolves the dropdown menu animation duration.
  Duration resolveDropdownDuration(JustMotionProfile animations);

  /// Resolves the dropdown menu animation curve.
  Curve resolveDropdownCurve(JustMotionProfile animations);

  /// Whether selection controls (Switch, Radio, Checkbox) default to triggering haptic feedback.
  bool get selectionHapticDefault;

  /// Whether the skeleton loader should pulse opacity instead of showing a gradient sweep shimmer.
  bool get usePulsingSkeleton;
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

  @override
  double resolveSliderTrackHeight(JustSliderSize size) {
    return switch (size) {
      .sm => 4.0,
      .md => 6.0,
      .lg => 8.0,
    };
  }

  @override
  double resolveSliderThumbSize(JustSliderSize size) {
    return switch (size) {
      .sm => 14.0,
      .md => 20.0,
      .lg => 26.0,
    };
  }

  @override
  bool get sliderHapticDefault => false;

  @override
  double resolveProgressStrokeWidth(JustProgressSize size) {
    return switch (size) {
      .sm => 2.0,
      .md => 3.0,
      .lg => 4.0,
    };
  }

  @override
  FontWeight get progressLabelFontWeight => FontWeight.w500;

  @override
  double resolveSeparatorThickness(double thickness) => thickness;

  @override
  double get tabIndicatorThickness => 2.0;

  @override
  Duration resolveFocusTransitionDuration(JustMotionProfile animations) =>
      animations.fast;

  @override
  Duration resolveDropdownDuration(JustMotionProfile animations) =>
      animations.fast;

  @override
  Curve resolveDropdownCurve(JustMotionProfile animations) =>
      animations.defaultCurve;

  @override
  bool get selectionHapticDefault => false;

  @override
  bool get usePulsingSkeleton => false;
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

  @override
  double resolveSliderTrackHeight(JustSliderSize size) {
    return switch (size) {
      .sm => 6.0,
      .md => 10.0,
      .lg => 14.0,
    };
  }

  @override
  double resolveSliderThumbSize(JustSliderSize size) {
    return switch (size) {
      .sm => 16.0,
      .md => 22.0,
      .lg => 28.0,
    };
  }

  @override
  bool get sliderHapticDefault => true;

  @override
  double resolveProgressStrokeWidth(JustProgressSize size) {
    return switch (size) {
      .sm => 3.0,
      .md => 4.0,
      .lg => 5.0,
    };
  }

  @override
  FontWeight get progressLabelFontWeight => FontWeight.w700;

  @override
  double resolveSeparatorThickness(double thickness) => 2.0;

  @override
  double get tabIndicatorThickness => 4.0;

  @override
  Duration resolveFocusTransitionDuration(JustMotionProfile animations) =>
      animations.instant;

  @override
  Duration resolveDropdownDuration(JustMotionProfile animations) =>
      animations.instant;

  @override
  Curve resolveDropdownCurve(JustMotionProfile animations) =>
      animations.defaultCurve;

  @override
  bool get selectionHapticDefault => true;

  @override
  bool get usePulsingSkeleton => true;
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

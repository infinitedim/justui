import 'package:flutter/material.dart' show ThemeExtension;
import 'package:flutter/widgets.dart';

import '../../../just_ui_core.dart';
import 'just_carousel_style.dart';
import 'just_carousel_variants.dart';

/// Alias for [JustCarouselTheme] for convention parity.
typedef JustCarouselThemeData = JustCarouselTheme;

/// Global theme configuration for carousel layouts, extending Flutter's [ThemeExtension].
class const JustCarouselTheme({
  /// Global base style override for carousels.
  final JustCarouselStyle? style,

  /// Default fraction of the viewport occupied by each slide item. Defaults to 1.0.
  final double viewportFraction = 1.0,

  /// Default duration for page transition animations. Defaults to 300ms.
  final Duration animationDuration = const Duration(milliseconds: 300),

  /// Default animation curve for page transitions. Defaults to [Curves.easeInOut].
  final Curve animationCurve = Curves.easeInOut,

  /// Default indicator style. Defaults to [JustCarouselIndicator.dots].
  final JustCarouselIndicator indicator = .dots,

  /// Default indicator position. Defaults to [JustCarouselIndicatorPosition.inside].
  final JustCarouselIndicatorPosition indicatorPosition = .inside,

  /// Default transition animation effect. Defaults to [JustCarouselTransition.slide].
  final JustCarouselTransition transition = .slide,

  /// Default inactive indicator color.
  final Color? indicatorColor,

  /// Default active indicator color.
  final Color? activeIndicatorColor,

  /// Default diameter of inactive indicators. Defaults to 8.0.
  final double indicatorSize = 8.0,

  /// Default diameter / length of active indicator. Defaults to 8.0.
  final double activeIndicatorSize = 8.0,

  /// Default spacing between adjacent indicators. Defaults to 8.0.
  final double indicatorSpacing = 8.0,

  /// Default border radius for indicator items.
  final BorderRadius? indicatorRadius,

  /// Default configuration for auto-scrolling progression.
  final JustCarouselAutoScroll? autoScroll,

  /// Whether tapping indicator dots navigates directly to slides. Defaults to true.
  final bool interactiveIndicators = true,

  /// Whether pointer wheel / trackpad scrolling navigates slides. Defaults to true.
  final bool enableMouseWheel = true,

  /// Whether arrow keys and spacebar control navigation and playback. Defaults to true.
  final bool enableKeyboardNavigation = true,

  /// Whether navigation arrow buttons are displayed. Defaults to false.
  final bool showArrows = false,

  /// Default background / icon color for navigation arrows.
  final Color? arrowColor,

  /// Default active / hovered color for navigation arrows.
  final Color? activeArrowColor,

  /// Default bounding dimension in pixels for navigation arrows. Defaults to 36.0.
  final double arrowSize = 36.0,

  /// Default border radius applied to navigation arrows.
  final BorderRadius? arrowRadius,
}) extends ThemeExtension<JustCarouselTheme> {
  /// Default configuration for the theme.
  static const defaults = JustCarouselTheme();

  /// Creates a theme resolved from [JustThemeData].
  factory JustCarouselTheme.fromTheme(JustThemeData theme) {
    final colors = theme.colors;
    final radius = theme.radius;

    return JustCarouselTheme(
      indicatorColor: colors.borderDefault,
      activeIndicatorColor: colors.borderFocus,
      indicatorRadius: .all(radius.full),
      arrowColor: colors.background,
      activeArrowColor: colors.textPrimary,
      arrowRadius: .all(radius.md),
    );
  }

  /// Creates a theme matching the neobrutalism preset specifications.
  factory JustCarouselTheme.neobrutalism(JustThemeData theme) {
    final colors = theme.colors;

    return JustCarouselTheme(
      indicatorColor: colors.background,
      activeIndicatorColor: colors.textPrimary,
      indicatorRadius: .zero,
      indicatorSize: 10.0,
      activeIndicatorSize: 10.0,
      arrowColor: colors.background,
      activeArrowColor: colors.textPrimary,
      arrowRadius: .zero,
      arrowSize: 36.0,
    );
  }

  @override
  JustCarouselTheme copyWith({
    JustCarouselStyle? style,
    double? viewportFraction,
    Duration? animationDuration,
    Curve? animationCurve,
    JustCarouselIndicator? indicator,
    JustCarouselIndicatorPosition? indicatorPosition,
    JustCarouselTransition? transition,
    Color? indicatorColor,
    Color? activeIndicatorColor,
    double? indicatorSize,
    double? activeIndicatorSize,
    double? indicatorSpacing,
    BorderRadius? indicatorRadius,
    JustCarouselAutoScroll? autoScroll,
    bool? interactiveIndicators,
    bool? enableMouseWheel,
    bool? enableKeyboardNavigation,
    bool? showArrows,
    Color? arrowColor,
    Color? activeArrowColor,
    double? arrowSize,
    BorderRadius? arrowRadius,
  }) {
    return JustCarouselTheme(
      style: style ?? this.style,
      viewportFraction: viewportFraction ?? this.viewportFraction,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      indicator: indicator ?? this.indicator,
      indicatorPosition: indicatorPosition ?? this.indicatorPosition,
      transition: transition ?? this.transition,
      indicatorColor: indicatorColor ?? this.indicatorColor,
      activeIndicatorColor: activeIndicatorColor ?? this.activeIndicatorColor,
      indicatorSize: indicatorSize ?? this.indicatorSize,
      activeIndicatorSize: activeIndicatorSize ?? this.activeIndicatorSize,
      indicatorSpacing: indicatorSpacing ?? this.indicatorSpacing,
      indicatorRadius: indicatorRadius ?? this.indicatorRadius,
      autoScroll: autoScroll ?? this.autoScroll,
      interactiveIndicators:
          interactiveIndicators ?? this.interactiveIndicators,
      enableMouseWheel: enableMouseWheel ?? this.enableMouseWheel,
      enableKeyboardNavigation:
          enableKeyboardNavigation ?? this.enableKeyboardNavigation,
      showArrows: showArrows ?? this.showArrows,
      arrowColor: arrowColor ?? this.arrowColor,
      activeArrowColor: activeArrowColor ?? this.activeArrowColor,
      arrowSize: arrowSize ?? this.arrowSize,
      arrowRadius: arrowRadius ?? this.arrowRadius,
    );
  }

  @override
  JustCarouselTheme lerp(ThemeExtension<JustCarouselTheme>? other, double t) {
    if (other is! JustCarouselTheme) return this;

    final lerpedFraction =
        viewportFraction + (other.viewportFraction - viewportFraction) * t;
    final lerpedSize =
        indicatorSize + (other.indicatorSize - indicatorSize) * t;
    final lerpedActiveSize =
        activeIndicatorSize +
        (other.activeIndicatorSize - activeIndicatorSize) * t;
    final lerpedSpacing =
        indicatorSpacing + (other.indicatorSpacing - indicatorSpacing) * t;
    final lerpedArrowSize = arrowSize + (other.arrowSize - arrowSize) * t;

    return JustCarouselTheme(
      style: .lerp(style, other.style, t),
      viewportFraction: lerpedFraction,
      animationDuration: t < 0.5 ? animationDuration : other.animationDuration,
      animationCurve: t < 0.5 ? animationCurve : other.animationCurve,
      indicator: t < 0.5 ? indicator : other.indicator,
      indicatorPosition: t < 0.5 ? indicatorPosition : other.indicatorPosition,
      transition: t < 0.5 ? transition : other.transition,
      indicatorColor: .lerp(indicatorColor, other.indicatorColor, t),
      activeIndicatorColor: .lerp(
        activeIndicatorColor,
        other.activeIndicatorColor,
        t,
      ),
      indicatorSize: lerpedSize,
      activeIndicatorSize: lerpedActiveSize,
      indicatorSpacing: lerpedSpacing,
      indicatorRadius: .lerp(indicatorRadius, other.indicatorRadius, t),
      autoScroll: t < 0.5 ? autoScroll : other.autoScroll,
      interactiveIndicators: t < 0.5
          ? interactiveIndicators
          : other.interactiveIndicators,
      enableMouseWheel: t < 0.5 ? enableMouseWheel : other.enableMouseWheel,
      enableKeyboardNavigation: t < 0.5
          ? enableKeyboardNavigation
          : other.enableKeyboardNavigation,
      showArrows: t < 0.5 ? showArrows : other.showArrows,
      arrowColor: .lerp(arrowColor, other.arrowColor, t),
      activeArrowColor: .lerp(activeArrowColor, other.activeArrowColor, t),
      arrowSize: lerpedArrowSize,
      arrowRadius: .lerp(arrowRadius, other.arrowRadius, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JustCarouselTheme &&
          runtimeType == other.runtimeType &&
          style == other.style &&
          viewportFraction == other.viewportFraction &&
          animationDuration == other.animationDuration &&
          animationCurve == other.animationCurve &&
          indicator == other.indicator &&
          indicatorPosition == other.indicatorPosition &&
          transition == other.transition &&
          indicatorColor == other.indicatorColor &&
          activeIndicatorColor == other.activeIndicatorColor &&
          indicatorSize == other.indicatorSize &&
          activeIndicatorSize == other.activeIndicatorSize &&
          indicatorSpacing == other.indicatorSpacing &&
          indicatorRadius == other.indicatorRadius &&
          autoScroll == other.autoScroll &&
          interactiveIndicators == other.interactiveIndicators &&
          enableMouseWheel == other.enableMouseWheel &&
          enableKeyboardNavigation == other.enableKeyboardNavigation &&
          showArrows == other.showArrows &&
          arrowColor == other.arrowColor &&
          activeArrowColor == other.activeArrowColor &&
          arrowSize == other.arrowSize &&
          arrowRadius == other.arrowRadius;

  @override
  int get hashCode => Object.hashAll([
    style,
    viewportFraction,
    animationDuration,
    animationCurve,
    indicator,
    indicatorPosition,
    transition,
    indicatorColor,
    activeIndicatorColor,
    indicatorSize,
    activeIndicatorSize,
    indicatorSpacing,
    indicatorRadius,
    autoScroll,
    interactiveIndicators,
    enableMouseWheel,
    enableKeyboardNavigation,
    showArrows,
    arrowColor,
    activeArrowColor,
    arrowSize,
    arrowRadius,
  ]);
}

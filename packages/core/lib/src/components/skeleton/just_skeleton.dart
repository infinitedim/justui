import 'package:flutter/material.dart' show Theme;
import 'package:flutter/widgets.dart';
import '../../theme/theme_provider.dart';
import '../avatar/just_avatar.dart';
import '../badge/just_badge.dart';
import '../button/just_button.dart';
import '../card/just_card.dart';
import '../separator/just_separator.dart';
import '../shared/_shared_progress_spinner.dart';
import 'just_skeleton_style.dart';
import 'just_skeleton_theme.dart';

/// A structure-aware skeleton loader widget that automatically transforms a widget tree
/// into a visual skeleton loading state, preserving containers and replacing leaves with shimmer blocks.
class JustSkeleton extends StatefulWidget {
  /// The child widget tree to transform when [loading] is true.
  final Widget child;

  /// Whether the skeleton loading state is active.
  final bool loading;

  /// Per-instance styling overrides.
  final JustSkeletonStyle? style;

  // Private fields for manual shape declarations
  final double? _manualWidth;
  final double? _manualHeight;
  final BorderRadius? _manualBorderRadius;
  final BoxShape? _manualShape;
  final bool _isManual;

  /// Default constructor for structure-aware skeleton loading.
  const JustSkeleton({
    super.key,
    required this.child,
    required this.loading,
    this.style,
  }) : _manualWidth = null,
       _manualHeight = null,
       _manualBorderRadius = null,
       _manualShape = null,
       _isManual = false;

  /// Named constructor for a manual text shape skeleton placeholder.
  ///
  /// Note: Escape hatches like [JustSkeletonIgnore] and [JustSkeletonAtomic]
  /// are not supported in manual mode as there is no child tree to inspect.
  const JustSkeleton.text({
    super.key,
    double? width,
    double? height,
    BorderRadius? borderRadius,
    this.style,
  }) : child = const SizedBox.shrink(),
       loading = true,
       _manualWidth = width,
       _manualHeight = height,
       _manualBorderRadius = borderRadius,
       _manualShape = .rectangle,
       _isManual = true;

  /// Named constructor for a manual circular shape skeleton placeholder.
  ///
  /// Note: Escape hatches like [JustSkeletonIgnore] and [JustSkeletonAtomic]
  /// are not supported in manual mode as there is no child tree to inspect.
  const JustSkeleton.circle({super.key, required double size, this.style})
    : child = const SizedBox.shrink(),
      loading = true,
      _manualWidth = size,
      _manualHeight = size,
      _manualBorderRadius = null,
      _manualShape = .circle,
      _isManual = true;

  /// Named constructor for a manual rectangular shape skeleton placeholder.
  ///
  /// Note: Escape hatches like [JustSkeletonIgnore] and [JustSkeletonAtomic]
  /// are not supported in manual mode as there is no child tree to inspect.
  const JustSkeleton.rect({
    super.key,
    double? width,
    double? height,
    BorderRadius? borderRadius,
    this.style,
  }) : child = const SizedBox.shrink(),
       loading = true,
       _manualWidth = width,
       _manualHeight = height,
       _manualBorderRadius = borderRadius,
       _manualShape = .rectangle,
       _isManual = true;

  @override
  State<JustSkeleton> createState() => _JustSkeletonState();
}

class _JustSkeletonState extends State<JustSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (widget.loading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant JustSkeleton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.loading != oldWidget.loading) {
      if (widget.loading) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Subscriptions for performance aspects
    final colors = JustThemeProvider.of(context, aspect: .colors).theme.colors;
    final animations = JustThemeProvider.of(
      context,
      aspect: .animations,
    ).theme.animations;

    final globalTheme = Theme.of(context).extension<JustSkeletonTheme>();
    final themeStyle = globalTheme?.style;

    // Resolve base colors
    final isDark = colors.background.computeLuminance() < 0.5;
    final Color defaultBase = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE2E8F0);
    final Color defaultHighlight = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFF1F5F9);

    final resolvedBase =
        widget.style?.backgroundColor ??
        themeStyle?.backgroundColor ??
        defaultBase;
    final resolvedHighlight =
        widget.style?.shimmerColor ??
        themeStyle?.shimmerColor ??
        defaultHighlight;

    final resolvedDuration =
        widget.style?.duration ?? themeStyle?.duration ?? animations.slower * 2;

    if (_controller.duration != resolvedDuration) {
      _controller.duration = resolvedDuration;
      if (widget.loading &&
          !_controller.isAnimating &&
          resolvedDuration > .zero) {
        _controller.repeat();
      } else if (resolvedDuration == .zero) {
        _controller.stop();
      }
    }

    final resolvedStyle = JustSkeletonStyle(
      backgroundColor: resolvedBase,
      shimmerColor: resolvedHighlight,
      duration: resolvedDuration,
      fallbackRadius:
          widget.style?.fallbackRadius ?? themeStyle?.fallbackRadius,
    );

    // If manual mode, render manual shape directly
    if (widget._isManual) {
      return _JustSkeletonScope(
        animation: _controller,
        resolvedStyle: resolvedStyle,
        baseColor: resolvedBase,
        highlightColor: resolvedHighlight,
        child: _JustSkeletonShape(
          width: widget._manualWidth,
          height: widget._manualHeight,
          borderRadius: widget._manualBorderRadius,
          shape: widget._manualShape ?? .rectangle,
        ),
      );
    }

    // Wrap with switcher to support fade/reveal transition
    return AnimatedSwitcher(
      duration: animations.normal,
      switchInCurve: animations.defaultCurve,
      switchOutCurve: animations.defaultCurve,
      child: widget.loading
          ? _JustSkeletonScope(
              animation: _controller,
              resolvedStyle: resolvedStyle,
              baseColor: resolvedBase,
              highlightColor: resolvedHighlight,
              child: _transform(widget.child, context),
            )
          : widget.child,
    );
  }

  Widget _transform(Widget widget, BuildContext context) {
    // 1. Escape Hatch: Ignore
    if (widget is JustSkeletonIgnore) {
      return widget.child;
    }

    // 2. Escape Hatch: Atomic Block
    if (widget is JustSkeletonAtomic) {
      double? w = widget.width;
      double? h = widget.height;
      final child = widget.child;

      if (w == null) {
        if (child is Container) {
          w = _getContainerWidth(child);
        } else if (child is SizedBox) {
          w = child.width;
        }
      }
      if (h == null) {
        if (child is Container) {
          h = _getContainerHeight(child);
        } else if (child is SizedBox) {
          h = child.height;
        }
      }

      return _JustSkeletonShape(
        width: w ?? .infinity,
        height: h ?? 56.0,
        borderRadius: widget.borderRadius,
      );
    }

    // 3. Manual JustSkeleton nested in structure-aware mode
    if (widget is JustSkeleton && widget._isManual) {
      return _JustSkeletonShape(
        width: widget._manualWidth,
        height: widget._manualHeight,
        borderRadius: widget._manualBorderRadius,
        shape: widget._manualShape ?? .rectangle,
      );
    }

    // 4. JustUI Component Registry Mappings
    if (widget is JustAvatar) {
      final BoxShape shape = widget.shape == .circle ? .circle : .rectangle;
      double diameter = 40.0;
      switch (widget.size) {
        case .xs:
          diameter = 24.0;
          break;
        case .sm:
          diameter = 32.0;
          break;
        case .md:
          diameter = 40.0;
          break;
        case .lg:
          diameter = 48.0;
          break;
        case .xl:
          diameter = 64.0;
          break;
        case .xxl:
          diameter = 96.0;
          break;
      }
      return _JustSkeletonShape(
        width: diameter,
        height: diameter,
        shape: shape,
        borderRadius: shape == .circle ? null : const .all(.circular(8.0)),
      );
    }

    if (widget is JustBadge) {
      double height = 22.0;
      double width = 50.0;
      switch (widget.size) {
        case .sm:
          height = 18.0;
          width = 40.0;
          break;
        case .md:
          height = 22.0;
          width = 50.0;
          break;
        case .lg:
          height = 26.0;
          width = 60.0;
          break;
      }
      if (widget.variant == .dot) {
        final double dotSize = widget.size == .sm
            ? 6.0
            : (widget.size == .md ? 8.0 : 10.0);
        return _JustSkeletonShape(
          width: dotSize,
          height: dotSize,
          shape: .circle,
        );
      }
      return _JustSkeletonShape(
        width: width,
        height: height,
        borderRadius: const .all(.circular(10.0)),
      );
    }

    if (widget is JustButton) {
      double height = 40.0;
      switch (widget.size) {
        case .xs:
          height = 28.0;
          break;
        case .sm:
          height = 32.0;
          break;
        case .md:
          height = 40.0;
          break;
        case .lg:
          height = 48.0;
          break;
        case .xl:
          height = 56.0;
          break;
      }
      return _JustSkeletonShape(
        width: widget.isFullWidth ? .infinity : 100.0,
        height: height,
        borderRadius: const .all(.circular(6.0)),
      );
    }

    if (widget is JustCard) {
      return JustCard(
        variant: widget.variant,
        header: widget.header != null
            ? _transform(widget.header!, context)
            : null,
        footer: widget.footer != null
            ? _transform(widget.footer!, context)
            : null,
        padding: widget.padding,
        margin: widget.margin,
        width: widget.width,
        height: widget.height,
        style: widget.style,
        child: _transform(widget.child, context),
      );
    }

    if (widget is JustSeparator) {
      return widget;
    }

    // 5. Standard Leaf Widgets
    if (widget is Text) {
      final textStr = widget.data ?? widget.textSpan?.toPlainText() ?? '';
      final fontSize = widget.style?.fontSize ?? 14.0;
      if (textStr.isEmpty) return const SizedBox.shrink();

      final textAlign = widget.textAlign ?? .start;
      CrossAxisAlignment columnAlignment = .start;
      Alignment alignment = .centerLeft;
      if (textAlign == .center) {
        columnAlignment = .center;
        alignment = .center;
      } else if (textAlign == .end || textAlign == .right) {
        columnAlignment = .end;
        alignment = .centerRight;
      }

      if (textStr.length > 40 || textStr.contains('\n')) {
        final linesCount = textStr.contains('\n')
            ? textStr.split('\n').length
            : (textStr.length / 40).ceil();
        final clampedLines = linesCount.clamp(1, 4);
        return Column(
          crossAxisAlignment: columnAlignment,
          mainAxisSize: .min,
          children: List.generate(clampedLines, (index) {
            final isLast = index == clampedLines - 1;
            return Padding(
              padding: .only(bottom: isLast ? 0.0 : 6.0),
              child: FractionallySizedBox(
                alignment: alignment,
                widthFactor: isLast ? 0.6 : 1.0,
                child: _JustSkeletonShape(
                  height: fontSize * 0.85,
                  borderRadius: const .all(.circular(4.0)),
                ),
              ),
            );
          }),
        );
      } else {
        final double estimatedWidth = textStr.length * fontSize * 0.6;
        return _JustSkeletonShape(
          width: estimatedWidth.clamp(30.0, 250.0),
          height: fontSize * 0.85,
          borderRadius: const .all(.circular(4.0)),
        );
      }
    }

    if (widget is RichText) {
      final textStr = widget.text.toPlainText();
      if (textStr.isEmpty) return const SizedBox.shrink();

      final style = widget.text.style;
      final fontSize = style?.fontSize ?? 14.0;

      final textAlign = widget.textAlign;
      CrossAxisAlignment columnAlignment = .start;
      Alignment alignment = .centerLeft;
      if (textAlign == .center) {
        columnAlignment = .center;
        alignment = .center;
      } else if (textAlign == .end || textAlign == .right) {
        columnAlignment = .end;
        alignment = .centerRight;
      }

      if (textStr.length > 40 || textStr.contains('\n')) {
        final linesCount = textStr.contains('\n')
            ? textStr.split('\n').length
            : (textStr.length / 40).ceil();
        final clampedLines = linesCount.clamp(1, 4);
        return Column(
          crossAxisAlignment: columnAlignment,
          mainAxisSize: .min,
          children: List.generate(clampedLines, (index) {
            final isLast = index == clampedLines - 1;
            return Padding(
              padding: .only(bottom: isLast ? 0.0 : 6.0),
              child: FractionallySizedBox(
                alignment: alignment,
                widthFactor: isLast ? 0.6 : 1.0,
                child: _JustSkeletonShape(
                  height: fontSize * 0.85,
                  borderRadius: const .all(.circular(4.0)),
                ),
              ),
            );
          }),
        );
      } else {
        final double estimatedWidth = textStr.length * fontSize * 0.6;
        return _JustSkeletonShape(
          width: estimatedWidth.clamp(30.0, 250.0),
          height: fontSize * 0.85,
          borderRadius: const .all(.circular(4.0)),
        );
      }
    }

    if (widget is Image || widget is RawImage) {
      double? w;
      double? h;
      if (widget is Image) {
        w = widget.width;
        h = widget.height;
      } else if (widget is RawImage) {
        w = widget.width;
        h = widget.height;
      }
      return _JustSkeletonShape(
        width: w ?? 100.0,
        height: h ?? 100.0,
        borderRadius: const .all(.circular(4.0)),
      );
    }

    if (widget is Icon) {
      return _JustSkeletonShape(
        width: widget.size ?? 24.0,
        height: widget.size ?? 24.0,
        shape: .circle,
      );
    }

    if (widget is JustProgressSpinner) {
      return _JustSkeletonShape(
        width: widget.size,
        height: widget.size,
        shape: .circle,
      );
    }

    // 6. Stack Fallback (Avoid overlapping complexity)
    if (widget is Stack) {
      return const _JustSkeletonShape(
        width: .infinity,
        height: 120.0,
        borderRadius: .all(.circular(6.0)),
      );
    }

    // 7. Whitelisted Layout Containers (Pass-throughs)
    if (widget is GestureDetector) {
      return AbsorbPointer(
        absorbing: true,
        child: GestureDetector(
          key: widget.key,
          behavior: widget.behavior,
          child: widget.child != null
              ? _transform(widget.child!, context)
              : null,
        ),
      );
    }
    if (widget is MouseRegion) {
      return AbsorbPointer(
        absorbing: true,
        child: MouseRegion(
          key: widget.key,
          cursor: widget.cursor,
          child: widget.child != null
              ? _transform(widget.child!, context)
              : null,
        ),
      );
    }
    if (widget is Semantics) {
      final label = widget.properties.label;
      final resolvedLabel = label != null && label.isNotEmpty
          ? '$label (loading)'
          : 'Loading';
      return Semantics(
        key: widget.key,
        container: widget.container,
        explicitChildNodes: widget.explicitChildNodes,
        excludeSemantics: widget.excludeSemantics,
        label: resolvedLabel,
        value: widget.properties.value,
        hint: widget.properties.hint,
        scopesRoute: widget.properties.scopesRoute,
        namesRoute: widget.properties.namesRoute,
        liveRegion: widget.properties.liveRegion,
        child: widget.child != null
            ? _transform(widget.child!, context)
            : const SizedBox.shrink(),
      );
    }
    if (widget is SafeArea) {
      return SafeArea(
        key: widget.key,
        left: widget.left,
        top: widget.top,
        right: widget.right,
        bottom: widget.bottom,
        minimum: widget.minimum,
        maintainBottomViewPadding: widget.maintainBottomViewPadding,
        child: _transform(widget.child, context),
      );
    }

    // 8. Whitelisted Layout Containers (Preserved structure)
    if (widget is Padding) {
      return Padding(
        padding: widget.padding,
        child: widget.child != null ? _transform(widget.child!, context) : null,
      );
    }
    if (widget is SizedBox) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: widget.child != null ? _transform(widget.child!, context) : null,
      );
    }
    if (widget is Center) {
      return Center(
        widthFactor: widget.widthFactor,
        heightFactor: widget.heightFactor,
        child: widget.child != null ? _transform(widget.child!, context) : null,
      );
    }
    if (widget is Align) {
      return Align(
        alignment: widget.alignment,
        widthFactor: widget.widthFactor,
        heightFactor: widget.heightFactor,
        child: widget.child != null ? _transform(widget.child!, context) : null,
      );
    }
    if (widget is Expanded) {
      return Expanded(
        flex: widget.flex,
        child: _transform(widget.child, context),
      );
    }
    if (widget is Flexible) {
      return Flexible(
        flex: widget.flex,
        fit: widget.fit,
        child: _transform(widget.child, context),
      );
    }
    if (widget is Opacity) {
      return Opacity(
        opacity: widget.opacity,
        alwaysIncludeSemantics: widget.alwaysIncludeSemantics,
        child: widget.child != null ? _transform(widget.child!, context) : null,
      );
    }
    if (widget is ClipRRect) {
      return ClipRRect(
        borderRadius: widget.borderRadius,
        clipBehavior: widget.clipBehavior,
        child: widget.child != null ? _transform(widget.child!, context) : null,
      );
    }
    if (widget is ClipRect) {
      return ClipRect(
        clipBehavior: widget.clipBehavior,
        child: widget.child != null ? _transform(widget.child!, context) : null,
      );
    }
    if (widget is Container) {
      return Container(
        alignment: widget.alignment,
        padding: widget.padding,
        color: widget.color,
        decoration: widget.decoration,
        foregroundDecoration: widget.foregroundDecoration,
        width: _getContainerWidth(widget),
        height: _getContainerHeight(widget),
        constraints: widget.constraints,
        margin: widget.margin,
        transform: widget.transform,
        transformAlignment: widget.transformAlignment,
        clipBehavior: widget.clipBehavior,
        child: widget.child != null ? _transform(widget.child!, context) : null,
      );
    }
    if (widget is DecoratedBox) {
      return DecoratedBox(
        decoration: widget.decoration,
        position: widget.position,
        child: widget.child != null ? _transform(widget.child!, context) : null,
      );
    }
    if (widget is ColoredBox) {
      return ColoredBox(
        color: widget.color,
        child: widget.child != null ? _transform(widget.child!, context) : null,
      );
    }
    if (widget is ConstrainedBox) {
      return ConstrainedBox(
        constraints: widget.constraints,
        child: widget.child != null ? _transform(widget.child!, context) : null,
      );
    }
    if (widget is FractionallySizedBox) {
      return FractionallySizedBox(
        alignment: widget.alignment,
        widthFactor: widget.widthFactor,
        heightFactor: widget.heightFactor,
        child: widget.child != null ? _transform(widget.child!, context) : null,
      );
    }
    if (widget is AspectRatio) {
      return AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: widget.child != null ? _transform(widget.child!, context) : null,
      );
    }
    if (widget is Transform) {
      return Transform(
        transform: widget.transform,
        origin: widget.origin,
        alignment: widget.alignment,
        transformHitTests: widget.transformHitTests,
        filterQuality: widget.filterQuality,
        child: widget.child != null ? _transform(widget.child!, context) : null,
      );
    }

    // Multi-child layout widgets
    if (widget is Row) {
      return Row(
        key: widget.key,
        mainAxisAlignment: widget.mainAxisAlignment,
        mainAxisSize: widget.mainAxisSize,
        crossAxisAlignment: widget.crossAxisAlignment,
        textDirection: widget.textDirection,
        verticalDirection: widget.verticalDirection,
        textBaseline: widget.textBaseline,
        children: widget.children.map((c) => _transform(c, context)).toList(),
      );
    }
    if (widget is Column) {
      return Column(
        key: widget.key,
        mainAxisAlignment: widget.mainAxisAlignment,
        mainAxisSize: widget.mainAxisSize,
        crossAxisAlignment: widget.crossAxisAlignment,
        textDirection: widget.textDirection,
        verticalDirection: widget.verticalDirection,
        textBaseline: widget.textBaseline,
        children: widget.children.map((c) => _transform(c, context)).toList(),
      );
    }
    if (widget is Wrap) {
      return Wrap(
        key: widget.key,
        direction: widget.direction,
        alignment: widget.alignment,
        spacing: widget.spacing,
        runAlignment: widget.runAlignment,
        runSpacing: widget.runSpacing,
        crossAxisAlignment: widget.crossAxisAlignment,
        textDirection: widget.textDirection,
        verticalDirection: widget.verticalDirection,
        clipBehavior: widget.clipBehavior,
        children: widget.children.map((c) => _transform(c, context)).toList(),
      );
    }

    // 9. Dynamic Fallback for Custom/Third-party Layout Wrappers
    try {
      final dynamic dynamicWidget = widget;
      if (dynamicWidget.child is Widget) {
        return _transform(dynamicWidget.child as Widget, context);
      }
    } catch (_) {}

    try {
      final dynamic dynamicWidget = widget;
      if (dynamicWidget.children is List<Widget>) {
        final childrenList = (dynamicWidget.children as List).cast<Widget>();
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: .start,
          children: childrenList.map((c) => _transform(c, context)).toList(),
        );
      }
    } catch (_) {}

    // 10. Unknown Widget Fallback
    return const _JustSkeletonShape(
      width: 120.0,
      height: 40.0,
      borderRadius: .all(.circular(4.0)),
    );
  }
}

/// A scope that provides shared synchronized shimmer parameters.
class _JustSkeletonScope extends InheritedWidget {
  final AnimationController animation;
  final JustSkeletonStyle resolvedStyle;
  final Color baseColor;
  final Color highlightColor;

  const _JustSkeletonScope({
    required this.animation,
    required this.resolvedStyle,
    required this.baseColor,
    required this.highlightColor,
    required super.child,
  });

  static _JustSkeletonScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_JustSkeletonScope>();
  }

  Shader createShader(Rect bounds, double value, BuildContext context) {
    double screenWidth = 1000.0;
    try {
      screenWidth = MediaQuery.sizeOf(context).width;
    } catch (_) {}

    final renderBox = context.findRenderObject() as RenderBox?;
    double globalX = 0.0;
    if (renderBox != null && renderBox.hasSize) {
      try {
        globalX = renderBox.localToGlobal(.zero).dx;
      } catch (_) {}
    }

    final double sweepWidth = screenWidth;
    final double xOffset = -sweepWidth + (sweepWidth * 2 * value);
    final double localXOffset = xOffset - globalX;

    return LinearGradient(
      begin: .centerLeft,
      end: .centerRight,
      colors: [baseColor, highlightColor, baseColor],
      stops: const [0.0, 0.5, 1.0],
      transform: _GradientTranslation(localXOffset),
    ).createShader(bounds);
  }

  @override
  bool updateShouldNotify(_JustSkeletonScope oldWidget) {
    return animation != oldWidget.animation ||
        resolvedStyle != oldWidget.resolvedStyle ||
        baseColor != oldWidget.baseColor ||
        highlightColor != oldWidget.highlightColor;
  }
}

/// A leaf skeleton shape widget that can either participate in a synchronized parent scope
/// or run its own independent local animation controller.
class _JustSkeletonShape extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxShape shape;

  const _JustSkeletonShape({
    this.width,
    this.height,
    this.borderRadius,
    this.shape = .rectangle,
  });

  @override
  State<_JustSkeletonShape> createState() => _JustSkeletonShapeState();
}

class _JustSkeletonShapeState extends State<_JustSkeletonShape>
    with SingleTickerProviderStateMixin {
  AnimationController? _localController;

  @override
  void dispose() {
    _localController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = _JustSkeletonScope.of(context);

    final colors = JustThemeProvider.of(context, aspect: .colors).theme.colors;
    final isDark = colors.background.computeLuminance() < 0.5;

    final Color defaultBase = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE2E8F0);
    final Color defaultHighlight = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFF1F5F9);

    final baseColor = scope?.baseColor ?? defaultBase;
    final highlightColor = scope?.highlightColor ?? defaultHighlight;

    final BorderRadius resolvedRadius = widget.shape == .circle
        ? .zero
        : (widget.borderRadius ??
              scope?.resolvedStyle.fallbackRadius ??
              const .all(.circular(4.0)));

    final decoration = BoxDecoration(
      color: baseColor,
      borderRadius: widget.shape == .circle ? null : resolvedRadius,
      shape: widget.shape,
    );

    final baseContainer = Container(
      width: widget.width,
      height: widget.height,
      decoration: decoration,
    );

    final theme = JustThemeProvider.of(context).theme;
    final isNeobrutalism = theme.preset == .neobrutalism;

    if (isNeobrutalism) {
      final animations = JustThemeProvider.of(
        context,
        aspect: .animations,
      ).theme.animations;
      final targetDuration =
          scope?.resolvedStyle.duration ?? (animations.slower * 2);

      if (targetDuration == .zero) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: baseColor.withValues(alpha: 0.3),
            borderRadius: widget.shape == .circle ? null : resolvedRadius,
            shape: widget.shape,
          ),
        );
      }

      AnimationController? activeController;
      if (scope != null) {
        activeController = scope.animation;
      } else {
        _localController ??= AnimationController(
          vsync: this,
          duration: targetDuration,
        );
        if (_localController!.duration != targetDuration) {
          _localController!.duration = targetDuration;
        }
        if (!_localController!.isAnimating) {
          _localController!.repeat();
        }
        activeController = _localController;
      }

      return RepaintBoundary(
        child: AnimatedBuilder(
          animation: activeController!,
          builder: (context, child) {
            final double value = activeController!.value;
            final double opacity =
                0.3 + 0.3 * (1.0 - (2.0 * (value - 0.5).abs()));
            return Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: baseColor.withValues(alpha: opacity),
                borderRadius: widget.shape == .circle ? null : resolvedRadius,
                shape: widget.shape,
              ),
            );
          },
        ),
      );
    }

    if (scope != null) {
      if (scope.resolvedStyle.duration == .zero) {
        return baseContainer;
      }
      return RepaintBoundary(
        child: AnimatedBuilder(
          animation: scope.animation,
          builder: (context, child) {
            return ShaderMask(
              shaderCallback: (bounds) {
                return scope.createShader(
                  bounds,
                  scope.animation.value,
                  context,
                );
              },
              blendMode: .srcATop,
              child: child,
            );
          },
          child: baseContainer,
        ),
      );
    } else {
      final animations = JustThemeProvider.of(
        context,
        aspect: .animations,
      ).theme.animations;
      final targetDuration = animations.slower * 2;

      if (targetDuration == .zero) {
        return baseContainer;
      }

      _localController ??= AnimationController(
        vsync: this,
        duration: targetDuration,
      );

      if (_localController!.duration != targetDuration) {
        _localController!.duration = targetDuration;
      }

      if (!_localController!.isAnimating) {
        _localController!.repeat();
      }

      return RepaintBoundary(
        child: AnimatedBuilder(
          animation: _localController!,
          builder: (context, child) {
            final double value = _localController!.value;
            return ShaderMask(
              shaderCallback: (bounds) {
                double screenWidth = 1000.0;
                try {
                  screenWidth = MediaQuery.sizeOf(context).width;
                } catch (_) {}

                final renderBox = context.findRenderObject() as RenderBox?;
                double globalX = 0.0;
                if (renderBox != null && renderBox.hasSize) {
                  try {
                    globalX = renderBox.localToGlobal(.zero).dx;
                  } catch (_) {}
                }

                final double sweepWidth = screenWidth;
                final double xOffset = -sweepWidth + (sweepWidth * 2 * value);
                final double localXOffset = xOffset - globalX;

                return LinearGradient(
                  begin: .centerLeft,
                  end: .centerRight,
                  colors: [baseColor, highlightColor, baseColor],
                  stops: const [0.0, 0.5, 1.0],
                  transform: _GradientTranslation(localXOffset),
                ).createShader(bounds);
              },
              blendMode: .srcATop,
              child: child,
            );
          },
          child: baseContainer,
        ),
      );
    }
  }
}

/// A linear matrix gradient translation transform for driving the sweep animation.
class _GradientTranslation extends GradientTransform {
  final double dx;
  const _GradientTranslation(this.dx);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(dx, 0.0, 0.0);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! _GradientTranslation) return false;
    return dx == other.dx;
  }

  @override
  int get hashCode => dx.hashCode;
}

/// Wrapper widget that acts as an escape hatch to keep its child and descendants
/// fully visible and interactive during a skeleton loading state.
class JustSkeletonIgnore extends StatelessWidget {
  /// The child widget.
  final Widget child;

  /// Creates a [JustSkeletonIgnore] wrapper.
  const JustSkeletonIgnore({super.key, required this.child});

  @override
  Widget build(BuildContext context) => child;
}

/// Wrapper widget that acts as an escape hatch to force its entire child sub-tree
/// into a single atomic solid skeleton shape block during a skeleton loading state.
///
/// If [width] or [height] is null, the loader will attempt to resolve dimensions
/// from the child if it is a [Container] or [SizedBox] with explicit sizes.
/// If dimensions cannot be resolved, they fall back to predictable defaults
/// ([double.infinity] for width, and `56.0` for height).
class JustSkeletonAtomic extends StatelessWidget {
  /// The child widget.
  final Widget child;

  /// Optional explicit width for the resulting skeleton block.
  final double? width;

  /// Optional explicit height for the resulting skeleton block.
  final double? height;

  /// Optional explicit border radius for the resulting skeleton block.
  final BorderRadius? borderRadius;

  /// Creates a [JustSkeletonAtomic] wrapper.
  const JustSkeletonAtomic({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) => child;
}

double? _getContainerWidth(Container container) {
  final constraints = container.constraints;
  if (constraints != null &&
      constraints.maxWidth < double.infinity &&
      constraints.hasTightWidth) {
    return constraints.maxWidth;
  }
  return null;
}

double? _getContainerHeight(Container container) {
  final constraints = container.constraints;
  if (constraints != null &&
      constraints.maxHeight < double.infinity &&
      constraints.hasTightHeight) {
    return constraints.maxHeight;
  }
  return null;
}

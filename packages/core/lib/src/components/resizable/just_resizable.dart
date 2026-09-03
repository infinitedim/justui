import 'dart:collection' show UnmodifiableListView;
import 'dart:math' as math;

import 'package:flutter/material.dart' show Theme;
import 'package:flutter/services.dart' show PointerEnterEvent, PointerExitEvent;
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/just_ui_core.dart';

import 'just_resizable_style.dart';
import 'just_resizable_theme.dart';
import 'just_resizable_variants.dart';

export 'just_resizable_style.dart';
export 'just_resizable_theme.dart';
export 'just_resizable_variants.dart';

/// Represents an individual resizable pane within a [JustResizable] container.
class const JustResizablePanel({
  super.key,

  /// The widget content rendered inside this panel.
  required final Widget child,

  /// The initial proportional size of this panel (fraction from 0.0 to 1.0).
  ///
  /// When multiple panels define [initialSize], their values are normalized so
  /// that all panel fractions sum to 1.0. If omitted, available space is distributed equally.
  final double? initialSize,

  /// The minimum size of this panel in pixels.
  final double? minSize,

  /// The maximum size of this panel in pixels.
  final double? maxSize,

  /// Whether this panel can collapse down to 0 dimensions when dragged below [collapseThreshold].
  final bool collapsible = false,

  /// The threshold distance (in pixels or fractional ratio) below which a collapsible panel snaps to 0.
  /// Defaults to 50% of [minSize] if unspecified.
  final double? collapseThreshold,

  /// Optional magnetic snap target fractions for this panel (e.g. `[0.25, 0.50, 0.75]`).
  final List<double>? snapPoints,

  /// The fractional distance threshold within which snapping activates. Defaults to 0.03 (3%).
  final double snapThreshold = 0.03,

  /// Whether this panel is resizable. If set to false, splitters bounding this panel are locked.
  final bool resizable = true,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => child;
}

/// Pure mathematical engine for fraction normalization, space distribution, and isolated drag calculations.
///
/// Complies with the Single Responsibility Principle (SRP) and operates free of widget dependencies.
abstract final class JustResizableEngine {
  /// Normalizes initial panel sizes into fractional values summing strictly to 1.0.
  static List<double> normalizeFractions(List<double?> initialSizes, int count) {
    if (count <= 0) return const <double>[];
    if (count == 1) return const <double>[1.0];

    final hasNonNull = initialSizes.any((s) => s != null && s > 0.0);
    if (!hasNonNull) {
      final equalShare = 1.0 / count;
      return List<double>.filled(count, equalShare);
    }

    double totalSum = 0.0;
    final parsed = List<double>.filled(count, 0.0);
    for (int i = 0; i < count; i++) {
      final val = (i < initialSizes.length) ? initialSizes[i] : null;
      final resolved = (val != null && val > 0.0) ? val : (1.0 / count);
      parsed[i] = resolved;
      totalSum += resolved;
    }

    if (totalSum <= 0.0) {
      final equalShare = 1.0 / count;
      return List<double>.filled(count, equalShare);
    }

    return [for (final p in parsed) p / totalSum];
  }

  /// Computes the net space available for panels after subtracting divider line thicknesses.
  static double computeAvailableSpace(
    double totalSize,
    int panelCount,
    double dividerThickness,
  ) {
    if (!totalSize.isFinite || totalSize <= 0.0 || panelCount <= 0) return 0.0;
    if (panelCount == 1) return totalSize;
    final totalDividerSpace = (panelCount - 1) * dividerThickness;
    return math.max(0.0, totalSize - totalDividerSpace);
  }

  /// Distributes available pixel space across panels using the Bresenham Remainder Distribution formula:
  ///
  /// $$P_{N-1} = \max\left(0.0, \text{availableSpace} - \sum_{i=0}^{N-2} P_i\right)$$
  ///
  /// This eliminates subpixel rounding drift and prevents layout overflow.
  static void distributePixelSizes({
    required double availableSpace,
    required List<double> fractions,
    required List<JustResizablePanel> panels,
    required List<double> output,
  }) {
    final count = panels.length;
    if (count == 0 || output.isEmpty) return;
    if (availableSpace <= 0.0) {
      for (int i = 0; i < output.length; i++) {
        output[i] = 0.0;
      }
      return;
    }
    if (count == 1) {
      output[0] =
          (fractions.isNotEmpty && fractions[0] <= 0.0) ? 0.0 : availableSpace;
      return;
    }

    double allocatedSum = 0.0;
    final limit = math.min(count - 1, fractions.length - 1);
    for (int i = 0; i < limit; i++) {
      if (fractions[i] <= 0.0) {
        output[i] = 0.0;
        continue;
      }
      double size = availableSpace * fractions[i];
      final minSize = panels[i].minSize;
      final maxSize = panels[i].maxSize;
      if (minSize != null && size < minSize) size = minSize;
      if (maxSize != null && size > maxSize) size = maxSize;

      final remaining = math.max(0.0, availableSpace - allocatedSum);
      if (size > remaining) {
        size = remaining;
      }
      output[i] = size;
      allocatedSum += size;
    }

    final lastIndex = count - 1;
    if (lastIndex < fractions.length && fractions[lastIndex] <= 0.0) {
      output[lastIndex] = 0.0;
    } else {
      output[lastIndex] = math.max(0.0, availableSpace - allocatedSum);
    }
  }

  /// Calculates new panel fractions for an isolated splitter drag between panel [splitterIndex] and [splitterIndex] + 1.
  ///
  /// Guarantees that only adjacent panels exchange space while the total fraction sum remains invariant.
  static void applySplitterDrag({
    required int splitterIndex,
    required double deltaPixels,
    required double availableSpace,
    required List<double> currentFractions,
    required List<JustResizablePanel> panels,
    required List<double> outputFractions,
  }) {
    if (!identical(outputFractions, currentFractions)) {
      final copyLen = math.min(currentFractions.length, outputFractions.length);
      for (int i = 0; i < copyLen; i++) {
        outputFractions[i] = currentFractions[i];
      }
    }

    if (availableSpace <= 0.0) return;
    if (splitterIndex < 0 || splitterIndex >= panels.length - 1) return;
    if (splitterIndex >= currentFractions.length - 1) return;

    final panelA = panels[splitterIndex];
    final panelB = panels[splitterIndex + 1];
    if (!panelA.resizable || !panelB.resizable) return;

    final combined =
        currentFractions[splitterIndex] + currentFractions[splitterIndex + 1];
    if (combined <= 0.0) return;

    final deltaF = deltaPixels / availableSpace;
    final targetA =
        (currentFractions[splitterIndex] + deltaF).clamp(0.0, combined);

    final minFA =
        panelA.minSize != null ? panelA.minSize! / availableSpace : 0.0;
    final maxFA =
        panelA.maxSize != null ? panelA.maxSize! / availableSpace : 1.0;
    final threshA = _resolveThreshold(panelA, minFA, availableSpace);

    final minFB =
        panelB.minSize != null ? panelB.minSize! / availableSpace : 0.0;
    final maxFB =
        panelB.maxSize != null ? panelB.maxSize! / availableSpace : 1.0;
    final threshB = _resolveThreshold(panelB, minFB, availableSpace);

    double finalA = _constrainPair(
      targetA: targetA,
      combined: combined,
      panelA: panelA,
      panelB: panelB,
      minFA: minFA,
      maxFA: maxFA,
      threshA: threshA,
      minFB: minFB,
      maxFB: maxFB,
      threshB: threshB,
    );

    finalA = _resolveSnapping(
      finalA: finalA,
      combined: combined,
      panelA: panelA,
      panelB: panelB,
      minFA: minFA,
      maxFA: maxFA,
      minFB: minFB,
      maxFB: maxFB,
    );

    outputFractions[splitterIndex] = finalA;
    outputFractions[splitterIndex + 1] = combined - finalA;
  }

  static double _resolveThreshold(
    JustResizablePanel panel,
    double minFraction,
    double availableSpace,
  ) {
    final explicit = panel.collapseThreshold;
    if (explicit == null) return minFraction * 0.5;
    if (explicit <= 0.0) return 0.0;
    if (explicit <= 1.0) return explicit;
    return availableSpace > 0.0 ? explicit / availableSpace : 0.0;
  }

  static double _constrainPair({
    required double targetA,
    required double combined,
    required JustResizablePanel panelA,
    required JustResizablePanel panelB,
    required double minFA,
    required double maxFA,
    required double threshA,
    required double minFB,
    required double maxFB,
    required double threshB,
  }) {
    if (panelA.collapsible && targetA < threshA && combined <= maxFB) {
      return 0.0;
    }

    final targetB = combined - targetA;
    if (panelB.collapsible && targetB < threshB && combined <= maxFA) {
      return combined;
    }

    final effectiveMinA = math.max(minFA, combined - maxFB);
    final effectiveMaxA = math.min(maxFA, combined - minFB);

    if (effectiveMinA > effectiveMaxA) {
      return (effectiveMinA + effectiveMaxA) / 2.0;
    }

    return targetA.clamp(effectiveMinA, effectiveMaxA);
  }

  static double _resolveSnapping({
    required double finalA,
    required double combined,
    required JustResizablePanel panelA,
    required JustResizablePanel panelB,
    required double minFA,
    required double maxFA,
    required double minFB,
    required double maxFB,
  }) {
    if (panelA.snapPoints != null) {
      for (final snap in panelA.snapPoints!) {
        if ((finalA - snap).abs() <= panelA.snapThreshold) {
          final candB = combined - snap;
          final validA =
              (panelA.collapsible && snap == 0.0) ||
              (snap >= minFA && snap <= maxFA);
          final validB =
              (panelB.collapsible && candB == 0.0) ||
              (candB >= minFB && candB <= maxFB);
          if (validA && validB) {
            return snap;
          }
        }
      }
    }

    if (panelB.snapPoints != null) {
      final currentB = combined - finalA;
      for (final snap in panelB.snapPoints!) {
        if ((currentB - snap).abs() <= panelB.snapThreshold) {
          final candA = combined - snap;
          final validB =
              (panelB.collapsible && snap == 0.0) ||
              (snap >= minFB && snap <= maxFB);
          final validA =
              (panelA.collapsible && candA == 0.0) ||
              (candA >= minFA && candA <= maxFA);
          if (validA && validB) {
            return candA;
          }
        }
      }
    }

    return finalA;
  }
}

/// Controller that coordinates panel resizing, collapsing, and fraction persistence for [JustResizable].
class JustResizableController extends ChangeNotifier {
  final List<double> _fractions = [];
  final List<double> _initialFractions = [];
  final Map<int, double> _savedFractions = {};
  late final List<double> _unmodifiableView = UnmodifiableListView(_fractions);

  /// Creates a [JustResizableController] with optional [initialFractions].
  JustResizableController({List<double>? initialFractions}) {
    if (initialFractions != null && initialFractions.isNotEmpty) {
      _setInitialFractions(initialFractions);
    }
  }

  void _setInitialFractions(List<double> initial) {
    final norm =
        JustResizableEngine.normalizeFractions(initial, initial.length);
    _initialFractions.clear();
    _initialFractions.addAll(norm);
    _fractions.clear();
    _fractions.addAll(norm);
    for (int i = 0; i < norm.length; i++) {
      _savedFractions[i] = norm[i];
    }
  }

  void _initFromPanels(List<JustResizablePanel> panels) {
    if (_fractions.length == panels.length && _fractions.isNotEmpty) return;
    final initialSizes = [for (final p in panels) p.initialSize];
    _setInitialFractions(
      JustResizableEngine.normalizeFractions(initialSizes, panels.length),
    );
  }

  /// An unmodifiable view of current panel fractions with zero runtime allocation on read.
  List<double> get fractions => _unmodifiableView;

  /// Number of panels managed by this controller.
  int get length => _fractions.length;

  /// Returns true if the panel at [index] is currently collapsed (fraction == 0.0).
  bool isCollapsed(int index) {
    if (index < 0 || index >= _fractions.length) return false;
    return _fractions[index] == 0.0;
  }

  /// Sets panel fractions directly. Normalizes values to sum to 1.0.
  void setFractions(List<double> newFractions) {
    if (newFractions.isEmpty) return;
    final norm =
        JustResizableEngine.normalizeFractions(newFractions, newFractions.length);
    _fractions.clear();
    _fractions.addAll(norm);
    notifyListeners();
  }

  int _findActiveNeighbor(int index) {
    if (index + 1 < _fractions.length && _fractions[index + 1] > 0.0) {
      return index + 1;
    }
    if (index - 1 >= 0 && _fractions[index - 1] > 0.0) {
      return index - 1;
    }
    int bestIndex = -1;
    double maxFraction = 0.0;
    for (int i = 0; i < _fractions.length; i++) {
      if (i != index && _fractions[i] > maxFraction) {
        maxFraction = _fractions[i];
        bestIndex = i;
      }
    }
    return bestIndex;
  }

  /// Collapses panel at [index] to 0.0, transferring its space to the nearest active panel.
  void collapse(int index) {
    if (index < 0 || index >= _fractions.length) return;
    if (_fractions[index] <= 0.0) return;
    if (_fractions.length <= 1) return;

    final targetIndex = _findActiveNeighbor(index);
    if (targetIndex == -1) return;

    final currentFraction = _fractions[index];
    _savedFractions[index] = currentFraction;
    _fractions[index] = 0.0;
    _fractions[targetIndex] += currentFraction;
    notifyListeners();
  }

  /// Expands panel at [index] back to its saved pre-collapse fraction.
  void expand(int index) {
    if (index < 0 || index >= _fractions.length) return;
    if (_fractions[index] > 0.0) return;
    if (_fractions.length <= 1) return;

    final targetIndex = _findActiveNeighbor(index);
    if (targetIndex == -1) return;

    final saved = _savedFractions[index];
    final initial =
        _initialFractions.isNotEmpty
            ? _initialFractions[index]
            : (1.0 / _fractions.length);
    final restore = (saved != null && saved > 0.0) ? saved : initial;

    final available = _fractions[targetIndex];
    final take = math.min(restore, available);
    if (take <= 0.0) return;

    _fractions[targetIndex] -= take;
    _fractions[index] = take;
    notifyListeners();
  }

  /// Toggles between collapsed and expanded state for panel at [index].
  void toggle(int index) {
    if (index < 0 || index >= _fractions.length) return;
    if (_fractions[index] <= 0.0) {
      expand(index);
    } else {
      collapse(index);
    }
  }

  /// Resets all panel fractions to their initial state.
  void reset() {
    if (_initialFractions.isEmpty) return;
    _fractions.clear();
    _fractions.addAll(_initialFractions);
    notifyListeners();
  }

  void _updateDragFractions({
    required int splitterIndex,
    required double deltaPixels,
    required double availableSpace,
    required List<JustResizablePanel> panels,
  }) {
    JustResizableEngine.applySplitterDrag(
      splitterIndex: splitterIndex,
      deltaPixels: deltaPixels,
      availableSpace: availableSpace,
      currentFractions: _fractions,
      panels: panels,
      outputFractions: _fractions,
    );
    notifyListeners();
  }
}

/// A responsive, high-performance resizable panel container.
///
/// Supports horizontal and vertical orientations, magnetic snap points, collapsible panels,
/// subpixel remainder distribution, and state preservation via offstaging.
class const JustResizable({
  super.key,

  /// List of resizable panels to layout.
  required final List<JustResizablePanel> children,

  /// The layout orientation of panels (horizontal or vertical).
  final Axis direction = .horizontal,

  /// Optional external controller to programmatically inspect and mutate panel fractions.
  final JustResizableController? controller,

  /// Callback triggered continuously during dragging.
  final ValueChanged<List<double>>? onResize,

  /// Callback triggered when a resize drag begins.
  final VoidCallback? onResizeStart,

  /// Callback triggered when a resize drag concludes.
  final ValueChanged<List<double>>? onResizeEnd,

  /// Interactive touch and mouse hit box size for the splitter handles. Defaults to 8.0.
  final double handleHitSize = 8.0,

  /// Custom thickness for the visible splitter divider line.
  final double? dividerThickness,

  /// Visual variant of the splitter handle (line, grip, or none).
  final JustResizableHandleVariant? handleVariant,

  /// Per-instance style overrides.
  final JustResizableStyle? style,

  /// Builder callback for customized splitter handle rendering (Open/Closed escape hatch).
  final Widget Function(
    BuildContext context,
    int index,
    bool isDragging,
    bool isHovered,
  )?
  handleBuilder,
}) extends StatefulWidget {
  @override
  State<JustResizable> createState() => _JustResizableState();
}

class _JustResizableState extends State<JustResizable> {
  JustResizableController? _internalController;
  final List<double> _pixelSizes = [];
  final List<Widget> _flexChildren = [];
  double _lastAvailableSpace = 0.0;

  JustResizableController get _effectiveController =>
      widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = JustResizableController();
    }
    _effectiveController._initFromPanels(widget.children);
    _effectiveController.addListener(_onControllerChanged);
    _syncPixelBuffer();
  }

  @override
  void didUpdateWidget(JustResizable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      (oldWidget.controller ?? _internalController)?.removeListener(
        _onControllerChanged,
      );
      if (widget.controller == null) {
        _internalController ??= JustResizableController();
      }
      _effectiveController._initFromPanels(widget.children);
      _effectiveController.addListener(_onControllerChanged);
    } else if (widget.children.length != oldWidget.children.length) {
      _effectiveController._initFromPanels(widget.children);
    }
    _syncPixelBuffer();
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_onControllerChanged);
    _internalController?.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {});
  }

  void _syncPixelBuffer() {
    if (_pixelSizes.length != widget.children.length) {
      _pixelSizes.clear();
      _pixelSizes.addAll(List<double>.filled(widget.children.length, 0.0));
    }
  }

  void _onSplitterDragStart(int index) {
    widget.onResizeStart?.call();
  }

  void _onSplitterDragUpdate(int index, double delta) {
    _effectiveController._updateDragFractions(
      splitterIndex: index,
      deltaPixels: delta,
      availableSpace: _lastAvailableSpace,
      panels: widget.children,
    );
    widget.onResize?.call(_effectiveController.fractions);
  }

  void _onSplitterDragEnd(int index) {
    widget.onResizeEnd?.call(_effectiveController.fractions);
  }

  void _onSplitterDoubleTap(int index) {
    _effectiveController.toggle(index);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalSize =
            widget.direction == .horizontal
                ? constraints.maxWidth
                : constraints.maxHeight;

        assert(
          totalSize.isFinite,
          'JustResizable requires finite constraints along its main axis (${widget.direction}). '
          'Consider placing it inside a SizedBox, Expanded, or other bounded container.',
        );

        if (!totalSize.isFinite || totalSize <= 0.0) {
          return const SizedBox.shrink();
        }

        final theme =
            Theme.of(context).extension<JustResizableTheme>() ??
            JustResizableTheme.defaults;
        final isNeobrutalism =
            context.justPreset == JustThemePreset.neobrutalism;
        final defaultThickness = isNeobrutalism ? 2.5 : 1.0;
        final thickness =
            widget.dividerThickness ??
            widget.style?.dividerThickness ??
            theme.style?.dividerThickness ??
            (theme.dividerThickness > 0.0
                ? theme.dividerThickness
                : defaultThickness);
        final hitSize = widget.handleHitSize;
        final variant =
            widget.handleVariant ??
            widget.style?.handleVariant ??
            theme.style?.handleVariant ??
            theme.handleVariant;

        final availableSpace = JustResizableEngine.computeAvailableSpace(
          totalSize,
          widget.children.length,
          thickness,
        );
        _lastAvailableSpace = availableSpace;

        _syncPixelBuffer();

        JustResizableEngine.distributePixelSizes(
          availableSpace: availableSpace,
          fractions: _effectiveController.fractions,
          panels: widget.children,
          output: _pixelSizes,
        );

        _flexChildren.clear();
        for (int i = 0; i < widget.children.length; i++) {
          final panel = widget.children[i];
          final size = _pixelSizes[i];
          final isCollapsed = _effectiveController.isCollapsed(i);

          _flexChildren.add(
            SizedBox(
              width:
                  widget.direction == .horizontal
                      ? (isCollapsed ? 0.0 : size)
                      : null,
              height:
                  widget.direction == .vertical
                      ? (isCollapsed ? 0.0 : size)
                      : null,
              child: Offstage(
                offstage: isCollapsed,
                child: TickerMode(enabled: !isCollapsed, child: panel),
              ),
            ),
          );

          if (i < widget.children.length - 1) {
            final isLocked =
                !panel.resizable || !widget.children[i + 1].resizable;
            _flexChildren.add(
              _ResizableSplitter(
                key: ValueKey<int>(i),
                index: i,
                direction: widget.direction,
                thickness: thickness,
                hitSize: hitSize,
                variant: variant,
                style: widget.style,
                resizable: !isLocked,
                handleBuilder: widget.handleBuilder,
                onDragStart: _onSplitterDragStart,
                onDragUpdate: _onSplitterDragUpdate,
                onDragEnd: _onSplitterDragEnd,
                onDoubleTap: _onSplitterDoubleTap,
              ),
            );
          }
        }

        return Flex(
          direction: widget.direction,
          crossAxisAlignment: .stretch,
          mainAxisSize: .max,
          children: _flexChildren,
        );
      },
    );
  }
}

class _ResizableSplitter extends StatefulWidget {
  final int index;
  final Axis direction;
  final double thickness;
  final double hitSize;
  final JustResizableHandleVariant variant;
  final JustResizableStyle? style;
  final bool resizable;
  final ValueChanged<int>? onDragStart;
  final void Function(int index, double delta)? onDragUpdate;
  final ValueChanged<int>? onDragEnd;
  final ValueChanged<int>? onDoubleTap;
  final Widget Function(
    BuildContext context,
    int index,
    bool isDragging,
    bool isHovered,
  )?
  handleBuilder;

  const _ResizableSplitter({
    super.key,
    required this.index,
    required this.direction,
    required this.thickness,
    required this.hitSize,
    required this.variant,
    this.style,
    this.resizable = true,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.onDoubleTap,
    this.handleBuilder,
  });

  @override
  State<_ResizableSplitter> createState() => _ResizableSplitterState();
}

class _ResizableSplitterState extends State<_ResizableSplitter> {
  bool _isHovered = false;
  bool _isDragging = false;

  MouseCursor get _cursor {
    if (!widget.resizable) return SystemMouseCursors.basic;
    return widget.direction == .horizontal
        ? SystemMouseCursors.resizeColumn
        : SystemMouseCursors.resizeRow;
  }

  void _handleMouseEnter(PointerEnterEvent _) {
    setState(() => _isHovered = true);
  }

  void _handleMouseExit(PointerExitEvent _) {
    setState(() => _isHovered = false);
  }

  void _handleDoubleTap() {
    widget.onDoubleTap?.call(widget.index);
  }

  void _handleDragStart(DragStartDetails details) {
    setState(() => _isDragging = true);
    widget.onDragStart?.call(widget.index);
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    widget.onDragUpdate?.call(
      widget.index,
      details.primaryDelta ?? details.delta.dx,
    );
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    widget.onDragUpdate?.call(
      widget.index,
      details.primaryDelta ?? details.delta.dy,
    );
  }

  void _handleDragEnd(DragEndDetails details) {
    setState(() => _isDragging = false);
    widget.onDragEnd?.call(widget.index);
  }

  void _handleDragCancel() {
    setState(() => _isDragging = false);
    widget.onDragEnd?.call(widget.index);
  }

  Widget _buildGrip({
    required bool isHorizontal,
    required Color gripBg,
    required Color gripBorder,
    required Color dotColor,
    required double gripBorderWidth,
    required BorderRadius gripRadius,
    required Widget line,
  }) {
    final gripW = widget.style?.gripSize?.width ?? (isHorizontal ? 12.0 : 22.0);
    final gripH =
        widget.style?.gripSize?.height ?? (isHorizontal ? 22.0 : 12.0);

    final dot = Container(
      width: 2.5,
      height: 2.5,
      decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
    );

    final dots =
        isHorizontal
            ? Column(
              mainAxisSize: .min,
              mainAxisAlignment: .center,
              children: [dot, const SizedBox(height: 3.0), dot],
            )
            : Row(
              mainAxisSize: .min,
              mainAxisAlignment: .center,
              children: [dot, const SizedBox(width: 3.0), dot],
            );

    return Stack(
      alignment: .center,
      children: [
        Center(child: line),
        Container(
          width: gripW,
          height: gripH,
          decoration: BoxDecoration(
            color: gripBg,
            border: Border.all(color: gripBorder, width: gripBorderWidth),
            borderRadius: gripRadius,
          ),
          child: Center(child: dots),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.justColors;
    final isNeobrutalism = context.justPreset == JustThemePreset.neobrutalism;

    final baseDividerColor =
        widget.style?.dividerColor ??
        (isNeobrutalism ? colors.textPrimary : colors.borderDefault);
    final activeDividerColor =
        widget.style?.activeDividerColor ??
        (isNeobrutalism ? colors.textPrimary : colors.borderFocus);
    final effectiveLineColor =
        (_isHovered || _isDragging) ? activeDividerColor : baseDividerColor;

    final isHorizontal = widget.direction == .horizontal;
    final halfDiff = math.max(0.0, (widget.hitSize - widget.thickness) / 2.0);

    Widget handleContent;
    if (widget.handleBuilder != null) {
      handleContent = widget.handleBuilder!(
        context,
        widget.index,
        _isDragging,
        _isHovered,
      );
    } else if (widget.variant == JustResizableHandleVariant.none) {
      handleContent = const SizedBox.shrink();
    } else {
      final line = Container(
        width: isHorizontal ? widget.thickness : double.infinity,
        height: isHorizontal ? double.infinity : widget.thickness,
        color: effectiveLineColor,
      );

      if (widget.variant == JustResizableHandleVariant.line) {
        handleContent = Center(child: line);
      } else {
        final gripBg =
            widget.style?.gripColor ??
            (isNeobrutalism ? colors.card : colors.elevated);
        final gripBorder =
            (_isHovered || _isDragging)
                ? (widget.style?.activeGripBorderColor ?? activeDividerColor)
                : (widget.style?.gripBorderColor ?? baseDividerColor);
        final dotColor =
            widget.style?.gripDotColor ??
            ((_isHovered || _isDragging)
                ? (isNeobrutalism ? colors.textPrimary : colors.borderFocus)
                : (isNeobrutalism ? colors.textPrimary : colors.textSecondary));
        final gripBorderWidth = isNeobrutalism ? 2.5 : 1.0;
        final gripRadius =
            widget.style?.gripRadius ??
            const BorderRadius.all(Radius.circular(3.0));

        handleContent = _buildGrip(
          isHorizontal: isHorizontal,
          gripBg: gripBg,
          gripBorder: gripBorder,
          dotColor: dotColor,
          gripBorderWidth: gripBorderWidth,
          gripRadius: gripRadius,
          line: line,
        );
      }
    }

    final isCustomHandle = widget.handleBuilder != null;

    return SizedBox(
      width: isHorizontal ? widget.thickness : null,
      height: !isHorizontal ? widget.thickness : null,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: .center,
        children: [
          if (isCustomHandle)
            handleContent
          else
            IgnorePointer(child: handleContent),
          Positioned(
            left: isHorizontal ? -halfDiff : 0.0,
            right: isHorizontal ? -halfDiff : 0.0,
            top: !isHorizontal ? -halfDiff : 0.0,
            bottom: !isHorizontal ? -halfDiff : 0.0,
            child: MouseRegion(
              cursor: _cursor,
              onEnter: _handleMouseEnter,
              onExit: _handleMouseExit,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onDoubleTap: _handleDoubleTap,
                onHorizontalDragStart:
                    isHorizontal && widget.resizable ? _handleDragStart : null,
                onHorizontalDragUpdate:
                    isHorizontal && widget.resizable
                        ? _handleHorizontalDragUpdate
                        : null,
                onHorizontalDragEnd:
                    isHorizontal && widget.resizable ? _handleDragEnd : null,
                onHorizontalDragCancel:
                    isHorizontal && widget.resizable ? _handleDragCancel : null,
                onVerticalDragStart:
                    !isHorizontal && widget.resizable ? _handleDragStart : null,
                onVerticalDragUpdate:
                    !isHorizontal && widget.resizable
                        ? _handleVerticalDragUpdate
                        : null,
                onVerticalDragEnd:
                    !isHorizontal && widget.resizable ? _handleDragEnd : null,
                onVerticalDragCancel:
                    !isHorizontal && widget.resizable ? _handleDragCancel : null,
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

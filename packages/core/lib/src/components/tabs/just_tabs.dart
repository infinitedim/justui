import 'package:flutter/services.dart' show HapticFeedback, KeyDownEvent;
import 'package:flutter/material.dart' show Theme;
import 'package:flutter/widgets.dart';
import 'package:just_ui_tokens/just_ui_tokens.dart';
import '../../theme/theme_provider.dart';
import '../shared/_shared_pressable.dart';
import 'just_tab_indicator.dart';
import 'just_tabs_style.dart';
import 'just_tabs_theme.dart';
import 'just_tabs_variants.dart';

/// Represents a single tab configuration containing label, optional icon, and content.
class JustTab {
  /// The label text of the tab.
  final String label;

  /// An optional leading icon.
  final Widget? icon;

  /// The widget content rendered when this tab is selected.
  final Widget content;

  /// Whether the tab is interactive. Disabled tabs cannot be clicked or focused.
  final bool enabled;

  /// An optional notification badge displayed next to the label.
  final Widget? badge;

  /// Creates a [JustTab] item.
  const JustTab({
    required this.label,
    this.icon,
    required this.content,
    this.enabled = true,
    this.badge,
  });
}

/// A synchronization controller that acts as the single source of truth for [JustTabs].
class JustTabController extends ChangeNotifier {
  /// The total number of tabs.
  final int length;

  int _index;
  double _animationValue;
  AnimationController? _animationController;
  bool _isDisposed = false;

  /// Creates a [JustTabController].
  JustTabController({required this.length, int initialIndex = 0})
    : _index = length == 0 ? 0 : initialIndex.clamp(0, length > 0 ? length - 1 : 0),
      _animationValue = (length == 0 ? 0 : initialIndex.clamp(0, length > 0 ? length - 1 : 0)).toDouble() {
    assert(length == 0 || (initialIndex >= 0 && initialIndex < length));
  }

  /// The active index.
  int get index => _index;

  set index(int value) {
    if (value == _index) return;
    assert(length == 0 || (value >= 0 && value < length));
    if (length == 0) return;
    _index = value;
    _animationValue = value.toDouble();
    notifyListeners();
  }

  /// The current fractional position of the tabs (e.g. 0.0 during page 0, 0.5 mid-swipe).
  double get animationValue => _animationValue;

  /// Updates the fractional position value, typically called by scroll/swipe listeners.
  void updateAnimationValue(double value) {
    if (value == _animationValue) return;
    _animationValue = value;
    final newIndex = length == 0 ? 0 : value.round().clamp(0, length - 1);
    if (newIndex != _index) {
      _index = newIndex;
    }
    notifyListeners();
  }

  void _bindVsync(TickerProvider vsync, {Duration? defaultDuration}) {
    _animationController?.dispose();
    _animationController = AnimationController(
      vsync: vsync,
      duration: defaultDuration ?? const Duration(milliseconds: 250),
    );
  }

  /// Updates the default duration of the tab transition animation.
  void updateDuration(Duration duration) {
    if (_animationController != null &&
        _animationController!.duration != duration) {
      _animationController!.duration = duration;
    }
  }

  /// Animates the controller to the target index.
  void animateTo(int targetIndex, {Duration? duration, Curve? curve}) {
    if (length == 0) return;
    assert(targetIndex >= 0 && targetIndex < length);
    if (targetIndex == _index) return;

    if (_animationController == null) {
      index = targetIndex;
      return;
    }

    _animationController!.stop();
    _animationController!.duration =
        duration ??
        _animationController!.duration ??
        const Duration(milliseconds: 250);

    final Animation<double> animation =
        Tween<double>(
          begin: _animationValue,
          end: targetIndex.toDouble(),
        ).animate(
          CurvedAnimation(
            parent: _animationController!,
            curve: curve ?? Curves.easeInOut,
          ),
        );

    void updateTween() {
      updateAnimationValue(animation.value);
    }

    _animationController!.addListener(updateTween);

    _animationController!.forward(from: 0.0).whenComplete(() {
      if (_isDisposed) return;
      _animationController?.removeListener(updateTween);
      _index = targetIndex;
      _animationValue = targetIndex.toDouble();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _animationController?.dispose();
    _animationController = null;
    super.dispose();
  }
}

/// A premium, Material-free tabs component supporting sliding indicators, swiping,
/// lazy loading/caching, and keyboard navigation.
class JustTabs extends StatefulWidget {
  /// The list of tab configurations.
  final List<JustTab> tabs;

  /// The visual style variant (line, enclosed, pill, vertical).
  final JustTabVariant variant;

  /// The initial active tab index (defaults to 0).
  final int initialIndex;

  /// Callback executed when the active tab index changes.
  final ValueChanged<int>? onChanged;

  /// Whether the tab headers scroll horizontally (defaults to false).
  final bool isScrollable;

  /// An optional external controller to sync selection and transitions.
  final JustTabController? controller;

  /// Custom style overrides.
  final JustTabsStyle? style;

  /// Creates a [JustTabs] component.
  const JustTabs({
    super.key,
    required this.tabs,
    this.variant = .line,
    this.initialIndex = 0,
    this.onChanged,
    this.isScrollable = false,
    this.controller,
    this.style,
  });

  /// Named constructor for underline style tabs.
  const JustTabs.line({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    this.onChanged,
    this.isScrollable = false,
    this.controller,
    this.style,
  }) : variant = .line;

  /// Named constructor for card enclosed style tabs.
  const JustTabs.enclosed({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    this.onChanged,
    this.isScrollable = false,
    this.controller,
    this.style,
  }) : variant = .enclosed;

  /// Named constructor for pill style tabs.
  const JustTabs.pill({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    this.onChanged,
    this.isScrollable = false,
    this.controller,
    this.style,
  }) : variant = .pill;

  /// Named constructor for vertical layout tabs.
  const JustTabs.vertical({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    this.onChanged,
    this.controller,
    this.style,
  }) : variant = .vertical,
       isScrollable = false;

  @override
  State<JustTabs> createState() => _JustTabsState();
}

class _JustTabsState extends State<JustTabs> with TickerProviderStateMixin {
  late JustTabController _tabController;
  late final PageController _pageController;
  final List<GlobalKey> _tabKeys = [];
  final FocusNode _focusNode = FocusNode();

  // Visited set for lazy loading tab page content
  final Set<int> _visitedIndices = {};

  List<double> _tabWidths = [];
  List<double> _tabOffsets = [];
  bool _isAnimatingToPage = false;
  bool _isLocalController = false;

  @override
  void initState() {
    super.initState();
    _visitedIndices.add(widget.initialIndex);

    if (widget.controller != null) {
      _tabController = widget.controller!;
    } else {
      _tabController = JustTabController(
        length: widget.tabs.length,
        initialIndex: widget.initialIndex,
      );
      _isLocalController = true;
    }

    final animations = JustThemeProvider.read(context).theme.animations;
    _tabController._bindVsync(this, defaultDuration: animations.normal);
    _tabController.addListener(_onControllerChanged);

    _pageController = PageController(initialPage: _tabController.index);
    _pageController.addListener(_onPageScroll);

    for (int i = 0; i < widget.tabs.length; i++) {
      _tabKeys.add(GlobalKey(debugLabel: 'tab_header_$i'));
    }
  }

  @override
  void didUpdateWidget(covariant JustTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tabs.length != oldWidget.tabs.length) {
      _tabKeys.clear();
      for (int i = 0; i < widget.tabs.length; i++) {
        _tabKeys.add(GlobalKey(debugLabel: 'tab_header_$i'));
      }
    }
    if (widget.controller != oldWidget.controller) {
      if (_isLocalController) {
        _tabController.dispose();
      } else {
        _tabController.removeListener(_onControllerChanged);
      }

      if (widget.controller != null) {
        _tabController = widget.controller!;
        _isLocalController = false;
      } else {
        _tabController = JustTabController(
          length: widget.tabs.length,
          initialIndex: widget.initialIndex,
        );
        _isLocalController = true;
      }
      final animations = JustThemeProvider.read(context).theme.animations;
      _tabController._bindVsync(this, defaultDuration: animations.normal);
      _tabController.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    _tabController.removeListener(_onControllerChanged);
    if (_isLocalController) {
      _tabController.dispose();
    }
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    final int index = _tabController.index;
    _visitedIndices.add(index);
    if (_pageController.hasClients && _pageController.page?.round() != index) {
      _isAnimatingToPage = true;
      final animations = JustThemeProvider.read(context).theme.animations;
      final duration = _durationForTransition(
        _tabController.index,
        index,
        animations,
      );
      _pageController
          .animateToPage(
            index,
            duration: duration,
            curve: animations.defaultCurve,
          )
          .then((_) {
            _isAnimatingToPage = false;
          });
    }
  }

  void _onPageScroll() {
    if (!mounted) return;
    if (_pageController.hasClients && !_isAnimatingToPage) {
      final double? page = _pageController.page;
      if (page != null) {
        _tabController.updateAnimationValue(page);
        final int targetIndex = page.round();
        if (_visitedIndices.add(targetIndex)) {
          setState(() {});
        }
      }
    }
  }

  void _measureTabs() {
    if (!mounted) return;
    final RenderBox? parentBox = context.findRenderObject() as RenderBox?;
    if (parentBox == null) return;

    final List<double> widths = [];
    final List<double> offsets = [];

    for (final key in _tabKeys) {
      final RenderBox? box =
          key.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        widths.add(
          widget.variant == .vertical ? box.size.height : box.size.width,
        );
        final localOffset = box.localToGlobal(.zero, ancestor: parentBox);
        offsets.add(
          widget.variant == .vertical ? localOffset.dy : localOffset.dx,
        );
      } else {
        return; // Layout not fully completed yet
      }
    }

    if (!_listEquals(_tabWidths, widths) ||
        !_listEquals(_tabOffsets, offsets)) {
      setState(() {
        _tabWidths = widths;
        _tabOffsets = offsets;
      });
    }
  }

  bool _listEquals(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Duration _durationForTransition(
    int fromIndex,
    int toIndex,
    JustMotionProfile animations,
  ) {
    if (_tabOffsets.length > fromIndex && _tabOffsets.length > toIndex) {
      final double distance = (_tabOffsets[toIndex] - _tabOffsets[fromIndex])
          .abs();
      return JustDuration.scaleForDistance(
        distance,
        min: animations.fast,
        max: animations.slow,
      );
    }
    return animations.normal;
  }

  void _handleTabTap(int index) {
    if (!widget.tabs[index].enabled) return;
    HapticFeedback.selectionClick();
    _visitedIndices.add(index);
    final animations = JustThemeProvider.read(context).theme.animations;
    final duration = _durationForTransition(
      _tabController.index,
      index,
      animations,
    );
    _tabController.animateTo(
      index,
      duration: duration,
      curve: animations.defaultCurve,
    );
    widget.onChanged?.call(index);
    setState(() {});
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    int newIndex = _tabController.index;
    if (widget.variant == .vertical) {
      if (event.logicalKey == .arrowDown) {
        newIndex = (newIndex + 1).clamp(0, widget.tabs.length - 1);
      } else if (event.logicalKey == .arrowUp) {
        newIndex = (newIndex - 1).clamp(0, widget.tabs.length - 1);
      }
    } else {
      if (event.logicalKey == .arrowRight) {
        newIndex = (newIndex + 1).clamp(0, widget.tabs.length - 1);
      } else if (event.logicalKey == .arrowLeft) {
        newIndex = (newIndex - 1).clamp(0, widget.tabs.length - 1);
      }
    }

    if (newIndex != _tabController.index && widget.tabs[newIndex].enabled) {
      _handleTabTap(newIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tabs.isEmpty) {
      return const SizedBox.shrink();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _measureTabs());

    final customTheme = JustThemeProvider.of(context).theme;
    _tabController.updateDuration(customTheme.animations.normal);
    final tabsTheme = Theme.of(context).extension<JustTabsTheme>();
    final colors = JustThemeProvider.of(context, aspect: .colors).theme.colors;
    final typography = JustThemeProvider.of(
      context,
      aspect: .typography,
    ).theme.typography;
    final spacing = JustThemeProvider.of(
      context,
      aspect: .spacing,
    ).theme.spacing;
    final radius = customTheme.radius;

    // Resolve active styles
    JustTabsStyle? themeStyle;
    if (tabsTheme != null) {
      switch (widget.variant) {
        case .line:
          themeStyle = tabsTheme.lineStyle;
          break;
        case .enclosed:
          themeStyle = tabsTheme.enclosedStyle;
          break;
        case .pill:
          themeStyle = tabsTheme.pillStyle;
          break;
        case .vertical:
          themeStyle = tabsTheme.verticalStyle;
          break;
      }
    }

    final activeColor =
        widget.style?.activeColor ??
        themeStyle?.activeColor ??
        colors.borderFocus;
    final inactiveColor =
        widget.style?.inactiveColor ??
        themeStyle?.inactiveColor ??
        colors.textSecondary;

    final containerBg =
        widget.style?.containerBackgroundColor ??
        themeStyle?.containerBackgroundColor ??
        (widget.variant == .pill || widget.variant == .enclosed
            ? colors.card
            : const Color(0x00000000));

    final containerBorderRadius =
        widget.style?.containerRadius ??
        themeStyle?.containerRadius ??
        .all(radius.md);

    final double activeVal = _tabController.animationValue.clamp(
      0.0,
      (widget.tabs.length - 1).toDouble(),
    );

    // Build Tab Headers
    final List<Widget> tabWidgets = [];
    for (int i = 0; i < widget.tabs.length; i++) {
      final tab = widget.tabs[i];
      final isSelected = _tabController.index == i;
      final isEnabled = tab.enabled;

      tabWidgets.add(
        JustPressable(
          key: _tabKeys[i],
          enabled: isEnabled,
          onTap: () => _handleTabTap(i),
          builder: (context, isHovered, isPressed, isFocused, focusNode) {
            final double distance = (activeVal - i).abs();
            final double textInterpolation = (1.0 - distance).clamp(0.0, 1.0);
            final textColor =
                Color.lerp(inactiveColor, activeColor, textInterpolation) ??
                inactiveColor;

            final resolvedTextStyle = isSelected
                ? (widget.style?.activeTextStyle ??
                      typography.bodyMd.copyWith(fontWeight: .w600))
                : (widget.style?.inactiveTextStyle ?? typography.bodyMd);

            final Widget headerContent = Row(
              mainAxisSize: .min,
              mainAxisAlignment: .center,
              children: [
                if (tab.icon != null) ...[
                  IconTheme.merge(
                    data: IconThemeData(
                      size: 18.0,
                      color: isEnabled ? textColor : colors.textDisabled,
                    ),
                    child: tab.icon!,
                  ),
                  SizedBox(width: spacing.sm),
                ],
                Text(
                  tab.label,
                  style: resolvedTextStyle.copyWith(
                    color: isEnabled ? textColor : colors.textDisabled,
                  ),
                ),
                if (tab.badge != null) ...[
                  SizedBox(width: spacing.sm),
                  tab.badge!,
                ],
              ],
            );

            return Semantics(
              label: tab.label,
              selected: isSelected,
              enabled: isEnabled,
              child: Container(
                padding:
                    widget.style?.tabPadding ??
                    themeStyle?.tabPadding ??
                    .symmetric(horizontal: spacing.lg, vertical: spacing.md),
                child: headerContent,
              ),
            );
          },
        ),
      );
    }

    // Indicator positioning widget
    Widget? indicatorWidget;
    if (_tabWidths.length == widget.tabs.length &&
        _tabOffsets.length == widget.tabs.length) {
      final int floorIdx = activeVal.floor();
      final int ceilIdx = activeVal.ceil();
      final double t = activeVal - floorIdx;

      final double pos1 = _tabOffsets[floorIdx];
      final double pos2 = _tabOffsets[ceilIdx];
      final double size1 = _tabWidths[floorIdx];
      final double size2 = _tabWidths[ceilIdx];

      final double pos = pos1 + (pos2 - pos1) * t;
      final double size = size1 + (size2 - size1) * t;

      final indicatorInner = JustTabIndicator(
        variant: widget.variant,
        orientation: widget.variant == .vertical ? .vertical : .horizontal,
        colors: colors,
        radius: radius,
        theme: customTheme,
        style: widget.style ?? themeStyle,
      );

      if (widget.variant == .vertical) {
        indicatorWidget = Positioned(
          top: pos,
          height: size,
          left: 0.0,
          right: 0.0,
          child: indicatorInner,
        );
      } else {
        indicatorWidget = Positioned(
          left: pos,
          width: size,
          top: 0.0,
          bottom: 0.0,
          child: indicatorInner,
        );
      }
    }

    // Layout configuration
    final bool isVertical = widget.variant == .vertical;

    final Widget headerBar = Stack(
      clipBehavior: .none,
      children: [
        // ignore: use_null_aware_elements
        if (indicatorWidget != null) indicatorWidget,
        if (widget.isScrollable && !isVertical)
          SingleChildScrollView(
            scrollDirection: .horizontal,
            child: Row(mainAxisSize: .min, children: tabWidgets),
          )
        else if (isVertical)
          Column(
            crossAxisAlignment: .stretch,
            mainAxisSize: .min,
            children: tabWidgets,
          )
        else
          Row(
            mainAxisAlignment: .spaceEvenly,
            children: tabWidgets
                .map((w) => Expanded(child: Center(child: w)))
                .toList(),
          ),
      ],
    );

    final presetTokens = customTheme.presetTokens;
    final Widget headerContainer = KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Container(
        decoration: BoxDecoration(
          color: containerBg,
          borderRadius: containerBorderRadius,
          border: presetTokens.showsDefaultBorder
              ? (widget.variant == .enclosed || widget.variant == .pill
                    ? .all(
                        color: colors.textPrimary,
                        width: presetTokens.borderWidth,
                      )
                    : null)
              : (widget.variant == .enclosed
                    ? .all(color: colors.borderDefault, width: 1.0)
                    : null),
        ),
        padding: widget.style?.padding ?? themeStyle?.padding,
        child: headerBar,
      ),
    );

    // Build the Tab Pages
    final pageView = PageView.builder(
      controller: _pageController,
      physics: const ClampingScrollPhysics(),
      itemCount: widget.tabs.length,
      itemBuilder: (context, index) {
        final isVisited = _visitedIndices.contains(index);
        if (isVisited) {
          return _JustTabKeepAlive(child: widget.tabs[index].content);
        } else {
          return const SizedBox.shrink();
        }
      },
    );

    if (isVertical) {
      return Row(
        crossAxisAlignment: .start,
        children: [
          SizedBox(
            width: 200, // Fixed width for vertical tab header panel
            child: headerContainer,
          ),
          Expanded(child: pageView),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: .stretch,
        children: [
          headerContainer,
          Expanded(child: pageView),
        ],
      );
    }
  }
}

class _JustTabKeepAlive extends StatefulWidget {
  final Widget child;
  const _JustTabKeepAlive({required this.child});

  @override
  State<_JustTabKeepAlive> createState() => _JustTabKeepAliveState();
}

class _JustTabKeepAliveState extends State<_JustTabKeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

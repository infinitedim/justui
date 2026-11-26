import 'package:flutter/services.dart'
    show HapticFeedback, KeyDownEvent, KeyRepeatEvent;
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/src/theme/preset_tokens.dart';
import 'package:just_ui_core/src/theme/theme_data.dart';
import 'package:just_ui_tokens/just_ui_tokens.dart';

import '../../theme/theme_data_material.dart';
import '../../theme/theme_provider.dart';
import '../shared/_shared_focus_indicator.dart';
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

  /// Creates a [JustTabController].
  JustTabController({required this.length, int initialIndex = 0})
    : _index = length == 0
          ? 0
          : initialIndex.clamp(0, length > 0 ? length - 1 : 0),
      _animationValue =
          (length == 0 ? 0 : initialIndex.clamp(0, length > 0 ? length - 1 : 0))
              .toDouble() {
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
    final int newIndex = length == 0 ? 0 : value.round().clamp(0, length - 1);
    if (newIndex != _index) {
      _index = newIndex;
    }
    notifyListeners();
  }

  void _bindVsync(TickerProvider vsync, {Duration? defaultDuration}) {}

  /// Updates the default duration of the tab transition animation.
  void updateDuration(Duration duration) {}

  /// Animates the controller to the target index.
  void animateTo(int targetIndex, {Duration? duration, Curve? curve}) {
    if (length == 0) return;
    assert(targetIndex >= 0 && targetIndex < length);
    _index = targetIndex;
    _animationValue = targetIndex.toDouble();
    notifyListeners();
  }
}

/// A premium, Material-free tabs component supporting sliding indicators, swiping,
/// lazy loading/caching, and keyboard navigation.
class const JustTabs({
  super.key,

  /// The list of tab configurations.
  required final List<JustTab> tabs,

  /// The visual style variant (line, enclosed, pill, vertical).
  final JustTabVariant variant = .line,

  /// The initial active tab index (defaults to 0).
  final int initialIndex = 0,

  /// Callback executed when the active tab index changes.
  final ValueChanged<int>? onChanged,

  /// Whether the tab headers scroll horizontally (defaults to false).
  final bool isScrollable = false,

  /// An optional external controller to sync selection and transitions.
  final JustTabController? controller,

  /// Custom style overrides.
  final JustTabsStyle? style,

  /// Accessible label announced for the tablist container.
  final String? semanticsLabel,

  /// Whether to render the tab content pages alongside or below the tab bar.
  final bool showContent = true,
}) extends StatefulWidget {
  /// Named constructor for underline style tabs.
  const new line({
    Key? key,
    required List<JustTab> tabs,
    int initialIndex = 0,
    ValueChanged<int>? onChanged,
    bool isScrollable = false,
    JustTabController? controller,
    JustTabsStyle? style,
    String? semanticsLabel,
    bool showContent = true,
  }) : this(
         key: key,
         tabs: tabs,
         variant: .line,
         initialIndex: initialIndex,
         onChanged: onChanged,
         isScrollable: isScrollable,
         controller: controller,
         style: style,
         semanticsLabel: semanticsLabel,
         showContent: showContent,
       );

  /// Named constructor for card enclosed style tabs.
  const new enclosed({
    Key? key,
    required List<JustTab> tabs,
    int initialIndex = 0,
    ValueChanged<int>? onChanged,
    bool isScrollable = false,
    JustTabController? controller,
    JustTabsStyle? style,
    String? semanticsLabel,
    bool showContent = true,
  }) : this(
         key: key,
         tabs: tabs,
         variant: .enclosed,
         initialIndex: initialIndex,
         onChanged: onChanged,
         isScrollable: isScrollable,
         controller: controller,
         style: style,
         semanticsLabel: semanticsLabel,
         showContent: showContent,
       );

  /// Named constructor for pill style tabs.
  const new pill({
    Key? key,
    required List<JustTab> tabs,
    int initialIndex = 0,
    ValueChanged<int>? onChanged,
    bool isScrollable = false,
    JustTabController? controller,
    JustTabsStyle? style,
    String? semanticsLabel,
    bool showContent = true,
  }) : this(
         key: key,
         tabs: tabs,
         variant: .pill,
         initialIndex: initialIndex,
         onChanged: onChanged,
         isScrollable: isScrollable,
         controller: controller,
         style: style,
         semanticsLabel: semanticsLabel,
         showContent: showContent,
       );

  /// Named constructor for vertical layout tabs.
  const new vertical({
    Key? key,
    required List<JustTab> tabs,
    int initialIndex = 0,
    ValueChanged<int>? onChanged,
    JustTabController? controller,
    JustTabsStyle? style,
    String? semanticsLabel,
    bool showContent = true,
  }) : this(
         key: key,
         tabs: tabs,
         variant: .vertical,
         initialIndex: initialIndex,
         onChanged: onChanged,
         isScrollable: false,
         controller: controller,
         style: style,
         semanticsLabel: semanticsLabel,
         showContent: showContent,
       );

  @override
  State<JustTabs> createState() => _JustTabsState();
}

class _JustTabsState extends State<JustTabs> with TickerProviderStateMixin {
  late JustTabController _tabController;
  late final PageController _pageController;
  final List<GlobalKey> _tabKeys = <GlobalKey<State<StatefulWidget>>>[];
  final List<FocusNode> _tabFocusNodes = <FocusNode>[];

  // Visited set for lazy loading tab page content
  final Set<int> _visitedIndices = <int>{};

  List<double> _tabWidths = <double>[];
  List<double> _tabOffsets = <double>[];
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

    final JustMotionProfile animations = JustThemeProvider.read(context)
        .theme
        .animations;
    _tabController._bindVsync(this, defaultDuration: animations.normal);
    _tabController.addListener(_onControllerChanged);

    _pageController = PageController(initialPage: _tabController.index);
    _pageController.addListener(_onPageScroll);

    for (int i = 0; i < widget.tabs.length; i++) {
      _tabKeys.add(GlobalKey(debugLabel: 'tab_header_$i'));
    }
    _syncTabFocusNodes();
    _updateFocusTraversal();
  }

  @override
  void didUpdateWidget(covariant JustTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tabs.length != oldWidget.tabs.length) {
      _tabKeys.clear();
      for (int i = 0; i < widget.tabs.length; i++) {
        _tabKeys.add(GlobalKey(debugLabel: 'tab_header_$i'));
      }
      _syncTabFocusNodes();
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
      final JustMotionProfile animations = JustThemeProvider.read(context)
          .theme
          .animations;
      _tabController._bindVsync(this, defaultDuration: animations.normal);
      _tabController.addListener(_onControllerChanged);
    }
    _updateFocusTraversal();
  }

  @override
  void dispose() {
    for (final FocusNode node in _tabFocusNodes) {
      node.dispose();
    }
    _tabFocusNodes.clear();
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    _tabController.removeListener(_onControllerChanged);
    if (_isLocalController) {
      _tabController.dispose();
    }
    super.dispose();
  }

  void _syncTabFocusNodes() {
    final int targetLength = widget.tabs.length;
    while (_tabFocusNodes.length < targetLength) {
      final int index = _tabFocusNodes.length;
      _tabFocusNodes.add(FocusNode(debugLabel: 'tab_focus_$index'));
    }
    while (_tabFocusNodes.length > targetLength) {
      _tabFocusNodes.removeLast().dispose();
    }
  }

  void _updateFocusTraversal() {
    int rovingIndex = _tabController.index;
    if (rovingIndex < 0 ||
        rovingIndex >= widget.tabs.length ||
        !widget.tabs[rovingIndex].enabled) {
      rovingIndex = _findBoundaryEnabledIndex(fromStart: true) ?? -1;
    }
    for (int i = 0; i < _tabFocusNodes.length; i++) {
      final bool shouldSkip = i != rovingIndex;
      if (_tabFocusNodes[i].skipTraversal != shouldSkip) {
        _tabFocusNodes[i].skipTraversal = shouldSkip;
      }
    }
  }

  void _onControllerChanged() {
    if (!mounted) return;
    final int index = _tabController.index;
    _visitedIndices.add(index);
    _updateFocusTraversal();
    if (_pageController.hasClients && _pageController.page?.round() != index) {
      final JustMotionProfile animations = JustThemeProvider.read(context)
          .theme
          .animations
          .resolve(context);
      final int fromIndex = _pageController.page?.round() ?? index;
      final Duration duration = _durationForTransition(
        fromIndex,
        index,
        animations,
      );
      if (duration == .zero) {
        _pageController.jumpToPage(index);
      } else {
        _pageController.animateToPage(
          index,
          duration: duration,
          curve: animations.defaultCurve,
        );
      }
    }
    setState(() {});
  }

  void _onPageScroll() {
    if (!mounted) return;
    if (_pageController.hasClients) {
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

    final List<double> widths = <double>[];
    final List<double> offsets = <double>[];

    for (final GlobalKey<State<StatefulWidget>> key in _tabKeys) {
      final RenderBox? box =
          key.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        widths.add(
          widget.variant == .vertical ? box.size.height : box.size.width,
        );
        final Offset localOffset = box.localToGlobal(
          .zero,
          ancestor: parentBox,
        );
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
    final JustMotionProfile animations = JustThemeProvider.read(context)
        .theme
        .animations
        .resolve(context);
    final Duration duration = _durationForTransition(
      _tabController.index,
      index,
      animations,
    );
    _tabController.animateTo(
      index,
      duration: duration,
      curve: animations.defaultCurve,
    );
    _updateFocusTraversal();
    widget.onChanged?.call(index);
    setState(() {});
  }

  int? _findNextEnabledIndex(int fromIndex, int step) {
    final int count = widget.tabs.length;
    if (count == 0) return null;
    for (int offset = 1; offset <= count; offset++) {
      final int candidate = (fromIndex + step * offset) % count;
      if (widget.tabs[candidate].enabled) {
        return candidate;
      }
    }
    return null;
  }

  int? _findBoundaryEnabledIndex({required bool fromStart}) {
    final int count = widget.tabs.length;
    if (fromStart) {
      for (int i = 0; i < count; i++) {
        if (widget.tabs[i].enabled) return i;
      }
    } else {
      for (int i = count - 1; i >= 0; i--) {
        if (widget.tabs[i].enabled) return i;
      }
    }
    return null;
  }

  KeyEventResult _handleTabKeyEvent(
    int tabIndex,
    FocusNode node,
    KeyEvent event,
  ) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return .ignored;
    }

    if (event.logicalKey == .space || event.logicalKey == .enter) {
      if (event is KeyDownEvent && widget.tabs[tabIndex].enabled) {
        _handleTabTap(tabIndex);
        return .handled;
      }
      return .ignored;
    }

    int? targetIndex;
    if (event.logicalKey == .home) {
      targetIndex = _findBoundaryEnabledIndex(fromStart: true);
    } else if (event.logicalKey == .end) {
      targetIndex = _findBoundaryEnabledIndex(fromStart: false);
    } else if (widget.variant == .vertical) {
      if (event.logicalKey == .arrowDown) {
        targetIndex = _findNextEnabledIndex(_tabController.index, 1);
      } else if (event.logicalKey == .arrowUp) {
        targetIndex = _findNextEnabledIndex(_tabController.index, -1);
      }
    } else {
      if (event.logicalKey == .arrowRight) {
        targetIndex = _findNextEnabledIndex(_tabController.index, 1);
      } else if (event.logicalKey == .arrowLeft) {
        targetIndex = _findNextEnabledIndex(_tabController.index, -1);
      }
    }

    if (targetIndex == null) {
      return .ignored;
    }

    if (targetIndex != _tabController.index) {
      _handleTabTap(targetIndex);
    }
    _tabFocusNodes[targetIndex].requestFocus();
    return .handled;
  }

  Border? _resolveContainerBorder({
    required JustPresetTokens presetTokens,
    required JustColorScheme colors,
    required JustTabsStyle? themeStyle,
  }) {
    final Color? borderBottomColor =
        widget.style?.borderBottomColor ?? themeStyle?.borderBottomColor;
    final double? borderBottomWidth =
        widget.style?.borderBottomWidth ?? themeStyle?.borderBottomWidth;

    if (widget.variant == .line &&
        borderBottomColor != null &&
        (borderBottomWidth == null || borderBottomWidth > 0.0)) {
      return Border(
        bottom: BorderSide(
          color: borderBottomColor,
          width: borderBottomWidth ?? presetTokens.borderWidth,
        ),
      );
    }

    if (presetTokens.showsDefaultBorder) {
      if (widget.variant == .enclosed || widget.variant == .pill) {
        return .all(color: colors.textPrimary, width: presetTokens.borderWidth);
      }
      return null;
    }

    if (widget.variant == .enclosed) {
      return .all(color: colors.borderDefault, width: 1.0);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tabs.isEmpty) {
      return const SizedBox.shrink();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _measureTabs());

    final JustThemeData customTheme = JustThemeProvider.of(context).theme;
    final JustMotionProfile resolvedAnimations = customTheme.animations.resolve(
      context,
    );
    _tabController.updateDuration(resolvedAnimations.normal);
    final JustTabsTheme? tabsTheme = context
        .justThemeExtension<JustTabsTheme>();
    final JustColorScheme colors = JustThemeProvider.of(
      context,
      aspect: .colors,
    ).theme.colors;
    final JustTypographyScheme typography = JustThemeProvider.of(
      context,
      aspect: .typography,
    ).theme.typography;
    final JustSpacingScheme spacing = JustThemeProvider.of(
      context,
      aspect: .spacing,
    ).theme.spacing;
    final JustRadiusScheme radius = customTheme.radius;
    final JustPresetTokens presetTokens = customTheme.presetTokens;

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

    final Color activeColor =
        widget.style?.activeColor ??
        themeStyle?.activeColor ??
        colors.borderFocus;
    final Color inactiveColor =
        widget.style?.inactiveColor ??
        themeStyle?.inactiveColor ??
        colors.textSecondary;

    final Color containerBg =
        widget.style?.containerBackgroundColor ??
        themeStyle?.containerBackgroundColor ??
        (widget.variant == .pill || widget.variant == .enclosed
            ? colors.card
            : const Color(0x00000000));

    final BorderRadius containerBorderRadius =
        widget.style?.containerRadius ??
        themeStyle?.containerRadius ??
        presetTokens.resolveBorderRadius(radius);
    final BorderRadius tabFocusRadius =
        widget.style?.indicatorRadius ??
        themeStyle?.indicatorRadius ??
        presetTokens.resolveBorderRadius(
          radius,
          isPill: widget.variant == .pill,
        );

    final double activeVal = _tabController.animationValue.clamp(
      0.0,
      (widget.tabs.length - 1).toDouble(),
    );

    // Build Tab Headers
    final List<Widget> tabWidgets = <Widget>[];
    for (int i = 0; i < widget.tabs.length; i++) {
      final JustTab tab = widget.tabs[i];
      final bool isSelected = _tabController.index == i;
      final bool isEnabled = tab.enabled;

      tabWidgets.add(
        JustPressable(
          key: _tabKeys[i],
          focusNode: _tabFocusNodes[i],
          enabled: isEnabled,
          onTap: () => _handleTabTap(i),
          onKeyEvent: (FocusNode node, KeyEvent event) =>
              _handleTabKeyEvent(i, node, event),
          builder: (BuildContext context, JustInteractionState state) {
            final double distance = (activeVal - i).abs();
            final double textInterpolation = (1.0 - distance).clamp(0.0, 1.0);
            final Color textColor =
                .lerp(inactiveColor, activeColor, textInterpolation) ??
                inactiveColor;

            final TextStyle resolvedTextStyle = isSelected
                ? (widget.style?.activeTextStyle ??
                      typography.bodyMd.copyWith(fontWeight: .w600))
                : (widget.style?.inactiveTextStyle ?? typography.bodyMd);

            final Widget headerContent = Row(
              mainAxisSize: .min,
              mainAxisAlignment: .center,
              children: <Widget>[
                if (tab.icon != null) ...<Widget>[
                  IconTheme.merge(
                    data: IconThemeData(
                      size: 18.0,
                      color: isEnabled ? textColor : colors.textDisabled,
                    ),
                    child: tab.icon!,
                  ),
                  SizedBox(width: spacing.sm),
                ],
                Flexible(
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      // Invisible bold placeholder reserves max width so switching tabs has 0 layout jitter
                      Opacity(
                        opacity: 0.0,
                        child: Text(
                          tab.label,
                          maxLines: 1,
                          style:
                              (widget.style?.activeTextStyle ??
                                      typography.bodyMd.copyWith(
                                        fontWeight: .w600,
                                      ))
                                  .copyWith(color: const Color(0x00000000)),
                        ),
                      ),
                      Text(
                        tab.label,
                        maxLines: 1,
                        overflow: .ellipsis,
                        style: resolvedTextStyle.copyWith(
                          color: isEnabled ? textColor : colors.textDisabled,
                        ),
                      ),
                    ],
                  ),
                ),
                if (tab.badge != null) ...<Widget>[
                  SizedBox(width: spacing.sm),
                  tab.badge!,
                ],
              ],
            );

            return Semantics(
              role: .tab,
              label: tab.label,
              selected: isSelected,
              enabled: isEnabled,
              excludeSemantics: true,
              child: FocusIndicator(
                isFocused: state.isFocusVisible,
                borderRadius: tabFocusRadius,
                child: Container(
                  padding:
                      widget.style?.tabPadding ??
                      themeStyle?.tabPadding ??
                      .symmetric(horizontal: spacing.lg, vertical: spacing.md),
                  child: headerContent,
                ),
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

      final JustTabIndicator indicatorInner = JustTabIndicator(
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
      children: <Widget>[
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
                .map((Widget w) => Expanded(child: Center(child: w)))
                .toList(),
          ),
      ],
    );

    final Border? containerBorder = _resolveContainerBorder(
      presetTokens: presetTokens,
      colors: colors,
      themeStyle: themeStyle,
    );
    final Widget headerContainer = Semantics(
      container: true,
      explicitChildNodes: true,
      role: .tabBar,
      label: widget.semanticsLabel,
      child: Container(
        decoration: BoxDecoration(
          color: containerBg,
          borderRadius: (containerBorder == null || containerBorder.isUniform)
              ? containerBorderRadius
              : null,
          border: containerBorder,
        ),
        padding: widget.style?.padding ?? themeStyle?.padding,
        child: headerBar,
      ),
    );

    if (!widget.showContent) {
      return headerContainer;
    }

    // Build the Tab Pages
    final PageView pageView = PageView.builder(
      controller: _pageController,
      physics: const ClampingScrollPhysics(),
      itemCount: widget.tabs.length,
      itemBuilder: (BuildContext context, int index) {
        final bool isVisited = _visitedIndices.contains(index);
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
        children: <Widget>[
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
        children: <Widget>[
          headerContainer,
          Expanded(child: pageView),
        ],
      );
    }
  }
}

class const _JustTabKeepAlive({required final Widget child})
    extends StatefulWidget {
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
    final JustColorScheme colors = JustThemeProvider.of(
      context,
      aspect: .colors,
    ).theme.colors;
    return DefaultTextStyle(
      style: JustFluidTypo.bodyMd(context).copyWith(color: colors.textPrimary),
      child: IconTheme.merge(
        data: IconThemeData(color: colors.textPrimary),
        child: widget.child,
      ),
    );
  }
}

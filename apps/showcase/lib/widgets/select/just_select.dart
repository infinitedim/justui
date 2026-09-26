// justui-meta: registry=3b7f97c2dd093405782bc865d671ccba98e45ea6d231036e918bd742a7e175ed local=982023f8763b7284994d87d3701f3ba19bb49a97ac37a0ede32769b608be987d
import 'package:flutter/material.dart' show Theme;
import 'package:flutter/services.dart'
    show TextInputAction, TextInputType, KeyDownEvent, KeyEvent;
import 'package:flutter/widgets.dart';
import 'package:showcase/core/theme/preset_tokens.dart';
import 'package:showcase/core/theme/theme_data.dart';

import 'package:showcase/core/just_ui_core.dart';

import '../shared/just_focus_indicator.dart';
import '../shared/just_pressable.dart';
import 'just_select_style.dart';
import 'just_select_theme.dart';
import 'just_select_variants.dart';

/// Data model representing an option in the [JustSelect] dropdown.
class JustSelectOption<T> {
  /// The value associated with this option.
  final T? value;

  /// The user-visible label for this option.
  final String label;

  /// An optional leading icon or widget.
  final Widget? icon;

  /// Whether this option is interactive.
  final bool enabled;

  /// If true, this option is rendered as a divider separator line.
  final bool isDivider;

  /// Creates a [JustSelectOption].
  const JustSelectOption({
    required this.value,
    required this.label,
    this.icon,
    this.enabled = true,
    this.isDivider = false,
  });

  /// Creates a divider option.
  const JustSelectOption.divider()
    : value = null,
      label = '',
      icon = null,
      enabled = false,
      isDivider = true;
}

/// A highly customizable, accessible dropdown select component.
/// Built from scratch without Material's [DropdownButton] using [OverlayPortal].
class JustSelect<T> extends StatefulWidget {
  /// The list of options available in the dropdown.
  final List<JustSelectOption<T>> options;

  /// The currently selected value.
  final T? value;

  /// Callback when a new option is selected.
  final ValueChanged<T>? onChanged;

  /// Text shown when no option is selected.
  final String? placeholder;

  /// Optional label shown above the select trigger.
  final String? label;

  /// Optional error text shown below the select trigger.
  final String? errorText;

  /// Whether the select is interactive.
  final bool enabled;

  /// Whether to show a search input field inside the dropdown.
  final bool searchable;

  /// The physical size classification.
  final JustSelectSize size;

  /// Per-instance style overrides.
  final JustSelectStyle? style;

  /// Optional prefix icon shown before the value.
  final Widget? prefixIcon;

  /// Maximum height of the dropdown list. Defaults to 300.
  final int maxDropdownHeight;

  /// Creates a [JustSelect] component.
  const JustSelect({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.placeholder,
    this.label,
    this.errorText,
    this.enabled = true,
    this.searchable = false,
    this.size = .md,
    this.style,
    this.prefixIcon,
    this.maxDropdownHeight = 300,
  });

  @override
  State<JustSelect<T>> createState() => _JustSelectState<T>();
}

class _JustSelectState<T> extends State<JustSelect<T>> {
  final OverlayPortalController _overlayController = OverlayPortalController();
  final FocusNode _triggerFocusNode = FocusNode();
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  /// Internal dummy focus node required by the search box's [EditableText].
  /// Keyboard navigation/events are actually handled by the ancestor [Focus]
  /// widget bound to [_searchFocusNode] — this node exists only so
  /// [EditableText] has a focus target to render a cursor against, and must
  /// be created once (not per-build) so it can be disposed.
  final FocusNode _searchEditableFocusNode = FocusNode();
  final ScrollController _optionScrollController = ScrollController();

  String _searchQuery = '';
  int _focusedOptionIndex =
      -1; // Keyboard navigation index within filtered options

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _triggerFocusNode.dispose();
    _searchFocusNode.dispose();
    _searchEditableFocusNode.dispose();
    _optionScrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _focusedOptionIndex = -1;
    });
  }

  List<JustSelectOption<T>> get _filteredOptions {
    if (!widget.searchable || _searchQuery.isEmpty) {
      return widget.options;
    }
    return widget.options.where((JustSelectOption<T> option) {
      if (option.isDivider) return true;
      return option.label.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _toggleDropdown() {
    if (!widget.enabled) return;
    if (_overlayController.isShowing) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    setState(() {
      _focusedOptionIndex = -1;
      _searchController.clear();
      _searchQuery = '';
    });
    _overlayController.show();
    if (widget.searchable) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchEditableFocusNode.requestFocus();
      });
    } else {
      _triggerFocusNode.requestFocus();
    }
  }

  void _closeDropdown() {
    _overlayController.hide();
    _triggerFocusNode.requestFocus();
  }

  void _selectOption(JustSelectOption<T> option) {
    if (!option.enabled || option.isDivider) return;
    if (widget.onChanged != null && option.value != null) {
      widget.onChanged!(option.value as T);
    }
    _closeDropdown();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return .ignored;

    final List<JustSelectOption<T>> filtered = _filteredOptions;
    if (!_overlayController.isShowing) {
      if (event.logicalKey == .enter ||
          event.logicalKey == .space ||
          event.logicalKey == .arrowDown ||
          event.logicalKey == .arrowUp) {
        _openDropdown();
        return .handled;
      }
      return .ignored;
    }

    if (event.logicalKey == .escape) {
      _closeDropdown();
      return .handled;
    }

    if (event.logicalKey == .arrowDown) {
      _moveFocus(1);
      return .handled;
    }

    if (event.logicalKey == .arrowUp) {
      _moveFocus(-1);
      return .handled;
    }

    if (event.logicalKey == .enter) {
      if (_focusedOptionIndex >= 0 && _focusedOptionIndex < filtered.length) {
        _selectOption(filtered[_focusedOptionIndex]);
      }
      return .handled;
    }

    return .ignored;
  }

  void _moveFocus(int direction) {
    final List<JustSelectOption<T>> filtered = _filteredOptions;
    if (filtered.isEmpty) return;

    int newIndex = _focusedOptionIndex;
    int attempts = 0;

    do {
      newIndex += direction;
      if (newIndex < 0) {
        newIndex = filtered.length - 1;
      } else if (newIndex >= filtered.length) {
        newIndex = 0;
      }
      attempts++;
    } while ((!filtered[newIndex].enabled || filtered[newIndex].isDivider) &&
        attempts < filtered.length);

    if (attempts < filtered.length) {
      setState(() {
        _focusedOptionIndex = newIndex;
      });
      _scrollToFocusedOption();
    }
  }

  void _scrollToFocusedOption() {
    if (!_optionScrollController.hasClients || _focusedOptionIndex < 0) return;
    const double itemHeight = 36.0;
    final double targetOffset = _focusedOptionIndex * itemHeight;
    final double viewportHeight =
        _optionScrollController.position.viewportDimension;
    final double currentScroll = _optionScrollController.offset;

    if (targetOffset < currentScroll) {
      _optionScrollController.jumpTo(targetOffset);
    } else if (targetOffset + itemHeight > currentScroll + viewportHeight) {
      _optionScrollController.jumpTo(
        targetOffset + itemHeight - viewportHeight,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final JustThemeData customTheme = JustThemeProvider.of(context).theme;
    final JustSelectTheme? selectTheme = Theme.of(context)
        .extension<JustSelectTheme>();
    final JustSelectStyle? themeStyle = selectTheme?.style;

    final JustColorScheme colors = JustThemeProvider.of(
      context,
      aspect: .colors,
    ).theme.colors;
    final JustSpacingScheme spacing = JustThemeProvider.of(
      context,
      aspect: .spacing,
    ).theme.spacing;
    final JustRadiusScheme radius = customTheme.radius;
    final JustTypographyScheme typography = JustThemeProvider.of(
      context,
      aspect: .typography,
    ).theme.typography;
    final JustPresetTokens presetTokens = customTheme.presetTokens;

    final (double height, TextStyle textStyle) = _selectSizeMetrics(
      widget.size,
      typography,
    );
    final BorderRadius defaultRadius = presetTokens.resolveBorderRadius(radius);

    final _SelectVisuals visuals = (
      theme: customTheme,
      themeStyle: themeStyle,
      colors: colors,
      spacing: spacing,
      radius: radius,
      presetTokens: presetTokens,
      height: height,
      textStyle: textStyle,
      bg:
          widget.style?.triggerBackgroundColor ??
          themeStyle?.triggerBackgroundColor ??
          colors.background,
      borderColor:
          widget.style?.triggerBorderColor ??
          themeStyle?.triggerBorderColor ??
          colors.borderDefault,
      textColor:
          widget.style?.textColor ??
          themeStyle?.textColor ??
          colors.textPrimary,
      placeholderColor:
          widget.style?.placeholderColor ??
          themeStyle?.placeholderColor ??
          colors.textSecondary,
      borderRadius:
          widget.style?.borderRadius ??
          themeStyle?.borderRadius ??
          defaultRadius,
    );

    final JustSelectOption<T>? selectedOption = widget.options
        .cast<JustSelectOption<T>?>()
        .firstWhere(
          (JustSelectOption<T>? opt) =>
              opt != null && !opt.isDivider && opt.value == widget.value,
          orElse: () => null,
        );

    final bool hasError = widget.errorText != null;

    return Semantics(
      container: true,
      label: widget.label ?? 'Select field',
      value: selectedOption?.label ?? 'None selected',
      hint: widget.enabled ? 'Double tap to open list of options' : 'Disabled',
      enabled: widget.enabled,
      child: Column(
        crossAxisAlignment: .start,
        mainAxisSize: .min,
        children: <Widget>[
          if (widget.label != null) ...<Widget>[
            Text(
              widget.label!,
              style: typography.bodySm.copyWith(
                fontWeight: .w600,
                color: colors.textPrimary,
              ),
            ),
            SizedBox(height: spacing.xs),
          ],
          OverlayPortal.overlayChildLayoutBuilder(
            controller: _overlayController,
            overlayChildBuilder: (
              BuildContext context,
              OverlayChildLayoutInfo info,
            ) => _buildDropdown(context, info, visuals),
            child: _buildTrigger(visuals, selectedOption, hasError),
          ),
          if (hasError) ...<Widget>[
            SizedBox(height: spacing.xs),
            Text(
              widget.errorText!,
              style: typography.caption.copyWith(color: colors.error),
            ),
          ],
        ],
      ),
    );
  }

  /// The always-visible trigger showing the selected option or placeholder.
  Widget _buildTrigger(
    _SelectVisuals v,
    JustSelectOption<T>? selectedOption,
    bool hasError,
  ) {
    final JustColorScheme colors = v.colors;
    final JustSpacingScheme spacing = v.spacing;
    final JustPresetTokens presetTokens = v.presetTokens;

    final BoxDecoration triggerDecoration = BoxDecoration(
      color: widget.enabled ? v.bg : v.bg.withValues(alpha: 0.5),
      border: .all(
        color: hasError
            ? colors.error
            : (_overlayController.isShowing
                  ? colors.borderFocus
                  : v.borderColor),
        width: presetTokens.borderWidth,
      ),
      borderRadius: presetTokens.showsDefaultBorder ? .zero : v.borderRadius,
    );

    return Focus(
      focusNode: _triggerFocusNode,
      onKeyEvent: (FocusNode node, KeyEvent event) =>
          _handleKeyEvent(node, event),
      child: JustPressable(
        enabled: widget.enabled,
        onTap: _toggleDropdown,
        builder: (BuildContext context, JustInteractionState state) {
          Widget inner = Container(
            height: v.height,
            padding: .symmetric(horizontal: spacing.md),
            decoration: triggerDecoration,
            child: Row(
              children: <Widget>[
                if (widget.prefixIcon != null) ...<Widget>[
                  widget.prefixIcon!,
                  SizedBox(width: spacing.sm),
                ],
                Expanded(
                  child: selectedOption != null
                      ? Row(
                          children: <Widget>[
                            if (selectedOption.icon != null) ...<Widget>[
                              selectedOption.icon!,
                              SizedBox(width: spacing.sm),
                            ],
                            Expanded(
                              child: Text(
                                selectedOption.label,
                                style: v.textStyle.copyWith(color: v.textColor),
                                overflow: .ellipsis,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          widget.placeholder ?? 'Select option...',
                          style: v.textStyle.copyWith(
                            color: v.placeholderColor,
                          ),
                          overflow: .ellipsis,
                        ),
                ),
                SizedBox(width: spacing.sm),
                // Chevron Icon
                AnimatedRotation(
                  turns: _overlayController.isShowing ? 0.5 : 0.0,
                  duration: presetTokens.dropdownOpenDuration,
                  curve: presetTokens.dropdownOpenCurve,
                  child: Icon(
                    const IconData(0xe150, fontFamily: 'MaterialIcons'),
                    size: widget.size == .sm ? 16 : 20,
                    color: hasError
                        ? colors.error
                        : (widget.enabled
                              ? v.textColor
                              : v.textColor.withValues(alpha: 0.5)),
                  ),
                ),
              ],
            ),
          );

          if (presetTokens.showsDefaultBorder) {
            inner = v.theme.buildPressEffect(
              isPressed: state.isPressed,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: v.theme.resolveShadows(
                    v.theme.shadows.md,
                    isPressed: state.isPressed,
                  ),
                  borderRadius: .zero,
                ),
                child: inner,
              ),
            );
          }

          return FocusIndicator(
            isFocused: state.isFocusVisible,
            borderRadius: presetTokens.showsDefaultBorder
                ? .zero
                : v.borderRadius,
            child: inner,
          );
        },
      ),
    );
  }

  /// The floating option list, positioned below the trigger (or above it
  /// when there is not enough room below).
  Widget _buildDropdown(
    BuildContext context,
    OverlayChildLayoutInfo info,
    _SelectVisuals v,
  ) {
    final JustColorScheme colors = v.colors;
    final JustSpacingScheme spacing = v.spacing;
    final JustPresetTokens presetTokens = v.presetTokens;

    final Offset targetOffset = MatrixUtils.transformPoint(
      info.childPaintTransform,
      .zero,
    );
    final double triggerHeight = info.childSize.height;
    final double triggerWidth = info.childSize.width;
    final double screenHeight = MediaQuery.sizeOf(context).height;

    // Calculate flip logic
    final double dropdownHeight = widget.maxDropdownHeight.toDouble();
    final double totalDropdownHeightNeeded = dropdownHeight + spacing.xs;
    final bool fitsBelow =
        targetOffset.dy + triggerHeight + totalDropdownHeightNeeded <=
        screenHeight;
    final bool fitsAbove = targetOffset.dy - totalDropdownHeightNeeded >= 0;
    final double topPosition = (fitsBelow || !fitsAbove)
        ? targetOffset.dy + triggerHeight + spacing.xs
        : targetOffset.dy - dropdownHeight - spacing.xs;

    final List<JustSelectOption<T>> filtered = _filteredOptions;

    final BoxDecoration dropdownDecoration = BoxDecoration(
      color:
          widget.style?.dropdownBackgroundColor ??
          v.themeStyle?.dropdownBackgroundColor ??
          colors.background,
      border: .all(
        color: presetTokens.showsDefaultBorder
            ? colors.textPrimary
            : colors.borderDefault,
        width: presetTokens.borderWidth,
      ),
      borderRadius: presetTokens.showsDefaultBorder ? .zero : v.borderRadius,
      boxShadow: presetTokens.showsDefaultBorder
          ? <BoxShadow>[
              BoxShadow(
                color: colors.textPrimary,
                offset: const Offset(6, 6),
                blurRadius: 0,
              ),
            ]
          : v.theme.shadows.lg,
    );

    final Widget dropdownContent = Container(
      width: triggerWidth,
      height: dropdownHeight,
      decoration: dropdownDecoration,
      child: Column(
        children: <Widget>[
          if (widget.searchable)
            _SelectSearchField(
              focusNode: _searchFocusNode,
              editableFocusNode: _searchEditableFocusNode,
              controller: _searchController,
              onKeyEvent: _handleKeyEvent,
              visuals: v,
            ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Padding(
                      padding: .all(spacing.md),
                      child: Text(
                        'No options found',
                        style: v.textStyle.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _optionScrollController,
                    padding: .zero,
                    itemCount: filtered.length,
                    itemBuilder: (BuildContext context, int index) {
                      final JustSelectOption<T> option = filtered[index];
                      if (option.isDivider) {
                        return Container(
                          height: 1,
                          margin: .symmetric(vertical: spacing.xs),
                          color: colors.borderDefault,
                        );
                      }
                      return _SelectOptionTile<T>(
                        option: option,
                        isSelected: option.value == widget.value,
                        isKeyboardFocused: index == _focusedOptionIndex,
                        instanceStyle: widget.style,
                        visuals: v,
                        onTap: () => _selectOption(option),
                      );
                    },
                  ),
          ),
        ],
      ),
    );

    return Stack(
      children: <Widget>[
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _closeDropdown,
          child: const SizedBox.expand(),
        ),
        Positioned(
          left: targetOffset.dx,
          top: topPosition,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: presetTokens.dropdownOpenDuration,
            curve: presetTokens.dropdownOpenCurve,
            builder: (BuildContext context, double val, Widget? child) {
              return Opacity(
                opacity: val,
                child: Transform.translate(
                  offset: Offset(0, (1 - val) * 10),
                  child: child,
                ),
              );
            },
            child: dropdownContent,
          ),
        ),
      ],
    );
  }
}

/// Theme values resolved once per [JustSelect] build and shared by the
/// trigger, dropdown, search field and option tiles.
typedef _SelectVisuals = ({
  JustThemeData theme,
  JustSelectStyle? themeStyle,
  JustColorScheme colors,
  JustSpacingScheme spacing,
  JustRadiusScheme radius,
  JustPresetTokens presetTokens,
  double height,
  TextStyle textStyle,
  Color bg,
  Color borderColor,
  Color textColor,
  Color placeholderColor,
  BorderRadius borderRadius,
});

/// Table-driven trigger height and text style for each [JustSelectSize].
(double, TextStyle) _selectSizeMetrics(
  JustSelectSize size,
  JustTypographyScheme typography,
) {
  return switch (size) {
    .sm => (36.0, typography.bodySm),
    .md => (44.0, typography.bodyMd),
    .lg => (52.0, typography.bodyLg),
  };
}

/// Search box shown at the top of a searchable [JustSelect] dropdown.
class _SelectSearchField extends StatelessWidget {
  final FocusNode focusNode;
  final FocusNode editableFocusNode;
  final TextEditingController controller;
  final FocusOnKeyEventCallback onKeyEvent;
  final _SelectVisuals visuals;

  const _SelectSearchField({
    required this.focusNode,
    required this.editableFocusNode,
    required this.controller,
    required this.onKeyEvent,
    required this.visuals,
  });

  @override
  Widget build(BuildContext context) {
    final JustColorScheme colors = visuals.colors;
    final JustSpacingScheme spacing = visuals.spacing;
    final JustPresetTokens presetTokens = visuals.presetTokens;

    return Padding(
      padding: .all(spacing.sm),
      child: Focus(
        focusNode: focusNode,
        onKeyEvent: onKeyEvent,
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            color: colors.background,
            border: .all(
              color: colors.borderDefault,
              width: presetTokens.showsDefaultBorder ? 2.0 : 1.0,
            ),
            borderRadius: presetTokens.showsDefaultBorder
                ? .zero
                : .all(visuals.radius.sm),
          ),
          padding: .symmetric(horizontal: spacing.sm),
          child: Row(
            children: <Widget>[
              Icon(
                const IconData(0xe554, fontFamily: 'MaterialIcons'),
                size: 16,
                color: colors.textSecondary,
              ),
              SizedBox(width: spacing.xs),
              Expanded(
                child: EditableText(
                  controller: controller,
                  focusNode: editableFocusNode, // internal dummy focus
                  style: visuals.textStyle.copyWith(color: colors.textPrimary),
                  cursorColor: colors.borderFocus,
                  backgroundCursorColor: colors.background,
                  textInputAction: TextInputAction.search,
                  keyboardType: TextInputType.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A single selectable row inside the [JustSelect] dropdown.
class _SelectOptionTile<T> extends StatelessWidget {
  final JustSelectOption<T> option;
  final bool isSelected;
  final bool isKeyboardFocused;
  final JustSelectStyle? instanceStyle;
  final _SelectVisuals visuals;
  final VoidCallback onTap;

  const _SelectOptionTile({
    required this.option,
    required this.isSelected,
    required this.isKeyboardFocused,
    required this.instanceStyle,
    required this.visuals,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final JustColorScheme colors = visuals.colors;
    final JustSpacingScheme spacing = visuals.spacing;
    final JustPresetTokens presetTokens = visuals.presetTokens;
    final JustSelectStyle? themeStyle = visuals.themeStyle;

    final Color optionBg = isSelected
        ? (presetTokens.showsDefaultBorder
              ? colors.textPrimary
              : (instanceStyle?.selectedOptionColor ??
                    themeStyle?.selectedOptionColor ??
                    colors.borderFocus.withValues(alpha: 0.15)))
        : const Color(0x00000000);

    final Color optionText = isSelected
        ? (presetTokens.showsDefaultBorder
              ? colors.textInverse
              : (instanceStyle?.textColor ??
                    themeStyle?.textColor ??
                    colors.borderFocus))
        : (option.enabled
              ? visuals.textColor
              : visuals.textColor.withValues(alpha: 0.4));

    return JustPressable(
      enabled: option.enabled,
      onTap: onTap,
      builder: (BuildContext context, JustInteractionState state) {
        final bool showHover = state.isHovered || isKeyboardFocused;
        final Color itemBg = showHover && !isSelected
            ? (instanceStyle?.optionHoverColor ??
                  themeStyle?.optionHoverColor ??
                  colors.borderDefault.withValues(alpha: 0.1))
            : optionBg;

        return Container(
          height: visuals.height - 4,
          padding: .symmetric(horizontal: spacing.md),
          decoration: BoxDecoration(
            color: itemBg,
            border: presetTokens.showsDefaultBorder && showHover
                ? Border(
                    left: BorderSide(color: colors.textPrimary, width: 3.0),
                  )
                : null,
          ),
          child: Row(
            children: <Widget>[
              if (option.icon != null) ...<Widget>[
                option.icon!,
                SizedBox(width: spacing.sm),
              ],
              Expanded(
                child: Text(
                  option.label,
                  style: visuals.textStyle.copyWith(
                    color: optionText,
                    fontWeight: isSelected ? .w600 : .w400,
                  ),
                  overflow: .ellipsis,
                ),
              ),
              if (isSelected && !presetTokens.showsDefaultBorder) ...<Widget>[
                SizedBox(width: spacing.sm),
                Icon(
                  const IconData(0xe156, fontFamily: 'MaterialIcons'),
                  size: 16,
                  color: optionText,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

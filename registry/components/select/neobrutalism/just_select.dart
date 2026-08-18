import 'package:flutter/material.dart' show Theme;
import 'package:flutter/services.dart'
    show TextInputAction, TextInputType, KeyDownEvent, KeyEvent;
import 'package:flutter/widgets.dart';

import '../shared/_shared_focus_indicator.dart';
import '../shared/_shared_pressable.dart';
import 'just_select_style.dart';
import 'just_select_theme.dart';
import 'just_select_variants.dart';

import 'package:just_ui_core/just_ui_core.dart';

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
    return widget.options.where((option) {
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

    final filtered = _filteredOptions;
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
    final filtered = _filteredOptions;
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
    final targetOffset = _focusedOptionIndex * itemHeight;
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
    final customTheme = JustThemeProvider.of(context).theme;
    final selectTheme = Theme.of(context).extension<JustSelectTheme>();
    final themeStyle = selectTheme?.style;

    final colors = JustThemeProvider.of(context, aspect: .colors).theme.colors;
    final spacing = JustThemeProvider.of(
      context,
      aspect: .spacing,
    ).theme.spacing;
    final radius = customTheme.radius;
    final shadows = customTheme.shadows;
    final typography = JustThemeProvider.of(
      context,
      aspect: .typography,
    ).theme.typography;
    final presetTokens = customTheme.presetTokens;

    // Resolve Size Properties
    double height;
    TextStyle textStyle;
    final BorderRadius defaultRadius;

    switch (widget.size) {
      case .sm:
        height = 36.0;
        textStyle = typography.bodySm;
        defaultRadius = presetTokens.resolveBorderRadius(radius);
        break;
      case .md:
        height = 44.0;
        textStyle = typography.bodyMd;
        defaultRadius = presetTokens.resolveBorderRadius(radius);
        break;
      case .lg:
        height = 52.0;
        textStyle = typography.bodyLg;
        defaultRadius = presetTokens.resolveBorderRadius(radius);
        break;
    }

    // Style Resolution
    final finalBg =
        widget.style?.triggerBackgroundColor ??
        themeStyle?.triggerBackgroundColor ??
        colors.background;
    final finalBorderColor =
        widget.style?.triggerBorderColor ??
        themeStyle?.triggerBorderColor ??
        colors.borderDefault;
    final finalTextColor =
        widget.style?.textColor ?? themeStyle?.textColor ?? colors.textPrimary;
    final finalPlaceholderColor =
        widget.style?.placeholderColor ??
        themeStyle?.placeholderColor ??
        colors.textSecondary;
    final finalRadius =
        widget.style?.borderRadius ?? themeStyle?.borderRadius ?? defaultRadius;

    final selectedOption = widget.options
        .cast<JustSelectOption<T>?>()
        .firstWhere(
          (opt) => opt != null && !opt.isDivider && opt.value == widget.value,
          orElse: () => null,
        );

    final hasError = widget.errorText != null;

    final triggerDecoration = BoxDecoration(
      color: widget.enabled ? finalBg : finalBg.withValues(alpha: 0.5),
      border: Border.all(
        color: hasError
            ? colors.error
            : (_overlayController.isShowing
                  ? colors.borderFocus
                  : finalBorderColor),
        width: presetTokens.borderWidth,
      ),
      borderRadius: presetTokens.showsDefaultBorder ? .zero : finalRadius,
    );

    final Widget triggerChild = Focus(
      focusNode: _triggerFocusNode,
      onKeyEvent: (node, event) => _handleKeyEvent(node, event),
      child: JustPressable(
        enabled: widget.enabled,
        onTap: _toggleDropdown,
        builder: (BuildContext context, JustInteractionState state) {
          Widget inner = Container(
            height: height,
            padding: .symmetric(horizontal: spacing.md),
            decoration: triggerDecoration,
            child: Row(
              children: [
                if (widget.prefixIcon != null) ...[
                  widget.prefixIcon!,
                  SizedBox(width: spacing.sm),
                ],
                Expanded(
                  child: selectedOption != null
                      ? Row(
                          children: [
                            if (selectedOption.icon != null) ...[
                              selectedOption.icon!,
                              SizedBox(width: spacing.sm),
                            ],
                            Expanded(
                              child: Text(
                                selectedOption.label,
                                style: textStyle.copyWith(
                                  color: finalTextColor,
                                ),
                                overflow: .ellipsis,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          widget.placeholder ?? 'Select option...',
                          style: textStyle.copyWith(
                            color: finalPlaceholderColor,
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
                              ? finalTextColor
                              : finalTextColor.withValues(alpha: 0.5)),
                  ),
                ),
              ],
            ),
          );

          if (presetTokens.showsDefaultBorder) {
            inner = customTheme.buildPressEffect(
              isPressed: state.isPressed,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: customTheme.resolveShadows(
                    shadows.md,
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
            borderRadius: presetTokens.showsDefaultBorder ? .zero : finalRadius,
            child: inner,
          );
        },
      ),
    );

    return Semantics(
      container: true,
      label: widget.label ?? 'Select field',
      value: selectedOption?.label ?? 'None selected',
      hint: widget.enabled ? 'Double tap to open list of options' : 'Disabled',
      enabled: widget.enabled,
      child: Column(
        crossAxisAlignment: .start,
        mainAxisSize: .min,
        children: [
          if (widget.label != null) ...[
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
            overlayChildBuilder: (context, info) {
              final targetOffset = MatrixUtils.transformPoint(
                info.childPaintTransform,
                .zero,
              );
              final triggerHeight = info.childSize.height;
              final triggerWidth = info.childSize.width;
              final screenHeight = MediaQuery.sizeOf(context).height;

              // Calculate flip logic
              final double dropdownHeight = widget.maxDropdownHeight.toDouble();
              final double totalDropdownHeightNeeded =
                  dropdownHeight + spacing.xs;
              final bool fitsBelow =
                  targetOffset.dy + triggerHeight + totalDropdownHeightNeeded <=
                  screenHeight;
              final bool fitsAbove =
                  targetOffset.dy - totalDropdownHeightNeeded >= 0;

              final double topPosition;
              if (fitsBelow || !fitsAbove) {
                topPosition = targetOffset.dy + triggerHeight + spacing.xs;
              } else {
                topPosition = targetOffset.dy - dropdownHeight - spacing.xs;
              }

              final filtered = _filteredOptions;

              final dropdownContainerBg =
                  widget.style?.dropdownBackgroundColor ??
                  themeStyle?.dropdownBackgroundColor ??
                  colors.background;

              final dropdownDecoration = BoxDecoration(
                color: dropdownContainerBg,
                border: Border.all(
                  color: presetTokens.showsDefaultBorder
                      ? colors.textPrimary
                      : colors.borderDefault,
                  width: presetTokens.borderWidth,
                ),
                borderRadius: presetTokens.showsDefaultBorder
                    ? .zero
                    : finalRadius,
                boxShadow: presetTokens.showsDefaultBorder
                    ? [
                        BoxShadow(
                          color: colors.textPrimary,
                          offset: const Offset(6, 6),
                          blurRadius: 0,
                        ),
                      ]
                    : shadows.lg,
              );

              Widget dropdownContent = Container(
                width: triggerWidth,
                height: dropdownHeight,
                decoration: dropdownDecoration,
                child: Column(
                  children: [
                    if (widget.searchable)
                      Padding(
                        padding: .all(spacing.sm),
                        child: Focus(
                          focusNode: _searchFocusNode,
                          onKeyEvent: (node, event) =>
                              _handleKeyEvent(node, event),
                          child: Container(
                            height: 36,
                            decoration: BoxDecoration(
                              color: colors.background,
                              border: Border.all(
                                color: colors.borderDefault,
                                width: presetTokens.showsDefaultBorder
                                    ? 2.0
                                    : 1.0,
                              ),
                              borderRadius: presetTokens.showsDefaultBorder
                                  ? .zero
                                  : .all(radius.sm),
                            ),
                            padding: .symmetric(horizontal: spacing.sm),
                            child: Row(
                              children: [
                                Icon(
                                  const IconData(
                                    0xe554,
                                    fontFamily: 'MaterialIcons',
                                  ),
                                  size: 16,
                                  color: colors.textSecondary,
                                ),
                                SizedBox(width: spacing.xs),
                                Expanded(
                                  child: EditableText(
                                    controller: _searchController,
                                    focusNode: _searchEditableFocusNode, // internal dummy focus
                                    style: textStyle.copyWith(
                                      color: colors.textPrimary,
                                    ),
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
                      ),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Padding(
                                padding: .all(spacing.md),
                                child: Text(
                                  'No options found',
                                  style: textStyle.copyWith(
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: _optionScrollController,
                              padding: .zero,
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final option = filtered[index];

                                if (option.isDivider) {
                                  return Container(
                                    height: 1,
                                    margin: .symmetric(vertical: spacing.xs),
                                    color: colors.borderDefault,
                                  );
                                }

                                final isSelected = option.value == widget.value;
                                final isKeyboardFocused =
                                    index == _focusedOptionIndex;

                                final optionBg = isSelected
                                    ? (presetTokens.showsDefaultBorder
                                          ? colors.textPrimary
                                          : (widget
                                                    .style
                                                    ?.selectedOptionColor ??
                                                themeStyle
                                                    ?.selectedOptionColor ??
                                                colors.borderFocus.withValues(
                                                  alpha: 0.15,
                                                )))
                                    : const Color(0x00000000);

                                final optionText = isSelected
                                    ? (presetTokens.showsDefaultBorder
                                          ? colors.textInverse
                                          : (widget.style?.textColor ??
                                                themeStyle?.textColor ??
                                                colors.borderFocus))
                                    : (option.enabled
                                          ? finalTextColor
                                          : finalTextColor.withValues(
                                              alpha: 0.4,
                                            ));

                                return JustPressable(
                                  enabled: option.enabled,
                                  onTap: () => _selectOption(option),
                                  builder:
                                      (
                                        BuildContext context,
                                        JustInteractionState state,
                                      ) {
                                        final isHovered = state.isHovered;
                                        final showHover =
                                            isHovered || isKeyboardFocused;
                                        Color itemBg = optionBg;

                                        if (showHover && !isSelected) {
                                          itemBg =
                                              widget.style?.optionHoverColor ??
                                              themeStyle?.optionHoverColor ??
                                              colors.borderDefault.withValues(
                                                alpha: 0.1,
                                              );
                                        }

                                        return Container(
                                          height: height - 4,
                                          padding: .symmetric(
                                            horizontal: spacing.md,
                                          ),
                                          decoration: BoxDecoration(
                                            color: itemBg,
                                            border:
                                                presetTokens
                                                        .showsDefaultBorder &&
                                                    showHover
                                                ? Border(
                                                    left: BorderSide(
                                                      color: colors.textPrimary,
                                                      width: 3.0,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                          child: Row(
                                            children: [
                                              if (option.icon != null) ...[
                                                option.icon!,
                                                SizedBox(width: spacing.sm),
                                              ],
                                              Expanded(
                                                child: Text(
                                                  option.label,
                                                  style: textStyle.copyWith(
                                                    color: optionText,
                                                    fontWeight: isSelected
                                                        ? .w600
                                                        : .w400,
                                                  ),
                                                  overflow: .ellipsis,
                                                ),
                                              ),
                                              if (isSelected &&
                                                  !presetTokens
                                                      .showsDefaultBorder) ...[
                                                SizedBox(width: spacing.sm),
                                                Icon(
                                                  const IconData(
                                                    0xe156,
                                                    fontFamily: 'MaterialIcons',
                                                  ),
                                                  size: 16,
                                                  color: optionText,
                                                ),
                                              ],
                                            ],
                                          ),
                                        );
                                      },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );

              dropdownContent = TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: presetTokens.dropdownOpenDuration,
                curve: presetTokens.dropdownOpenCurve,
                builder: (context, val, child) {
                  return Opacity(
                    opacity: val,
                    child: Transform.translate(
                      offset: Offset(0, (1 - val) * 10),
                      child: child,
                    ),
                  );
                },
                child: dropdownContent,
              );

              return Stack(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _closeDropdown,
                    child: const SizedBox.expand(),
                  ),
                  Positioned(
                    left: targetOffset.dx,
                    top: topPosition,
                    child: dropdownContent,
                  ),
                ],
              );
            },
            child: triggerChild,
          ),
          if (hasError) ...[
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
}

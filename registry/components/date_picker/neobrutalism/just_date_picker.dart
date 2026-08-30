import 'package:flutter/material.dart' show Icon, Icons, showGeneralDialog;
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/just_ui_core.dart';

import '../dialog/just_dialog.dart';
import '../shared/_shared_overlay_transition.dart';
import '../shared/_shared_pressable.dart';
import '../sheet/just_sheet.dart';
import '_date_picker_calendar.dart';
import 'just_date_picker_style.dart';
import 'just_date_picker_variants.dart';

/// A highly customizable, accessible date picker component adhering to JustUI design tokens.
class JustDatePicker extends StatefulWidget {
  /// Currently selected date.
  final DateTime? value;

  /// Called when user selects a date.
  final ValueChanged<DateTime>? onChanged;

  /// Earliest selectable date.
  final DateTime? firstDate;

  /// Latest selectable date.
  final DateTime? lastDate;

  /// Dates that cannot be selected.
  final bool Function(DateTime)? selectableDayPredicate;

  /// Display variant (.inline, .modal, .dropdown, .responsive).
  final JustDatePickerVariant variant;

  /// Initial calendar view (.day, .month, .year).
  final JustCalendarView initialView;

  /// Show week numbers column.
  final bool showWeekNumbers;

  /// First day of week (1=Mon, 7=Sun).
  final int firstDayOfWeek;

  /// Custom day cell builder for highlighting.
  final Widget Function(BuildContext context, DateTime date, bool isSelected)?
  dayBuilder;

  /// Custom header builder for month/year navigation.
  final Widget Function(
    BuildContext context,
    DateTime activeDate,
    JustCalendarView view,
    VoidCallback toggleView,
    VoidCallback onPrev,
    VoidCallback onNext,
  )?
  headerBuilder;

  /// Custom locale names provider.
  final JustDatePickerLocale locale;

  /// Placeholder text when no date is selected (used in dropdown variant).
  final String? placeholder;

  /// Label displayed above the date picker field.
  final String? label;

  /// Whether to render the outer card container in inline mode.
  final bool showContainer;

  /// Per-instance style overrides.
  final JustDatePickerStyle? style;

  /// Whether to enable haptic feedback on date selection.
  final bool? enableHaptic;

  /// Creates a [JustDatePicker] widget.
  const JustDatePicker({
    super.key,
    this.value,
    this.onChanged,
    this.firstDate,
    this.lastDate,
    this.selectableDayPredicate,
    this.variant = .inline,
    this.initialView = .day,
    this.showWeekNumbers = false,
    this.firstDayOfWeek = 7,
    this.dayBuilder,
    this.headerBuilder,
    this.locale = const JustDatePickerLocale(),
    this.placeholder,
    this.label,
    this.showContainer = true,
    this.style,
    this.enableHaptic,
  });

  /// Named constructor for inline calendar mode.
  const JustDatePicker.inline({
    Key? key,
    DateTime? value,
    ValueChanged<DateTime>? onChanged,
    DateTime? firstDate,
    DateTime? lastDate,
    bool Function(DateTime)? selectableDayPredicate,
    JustCalendarView initialView = .day,
    bool showWeekNumbers = false,
    int firstDayOfWeek = 7,
    Widget Function(BuildContext, DateTime, bool)? dayBuilder,
    Widget Function(
      BuildContext,
      DateTime,
      JustCalendarView,
      VoidCallback,
      VoidCallback,
      VoidCallback,
    )?
    headerBuilder,
    JustDatePickerLocale locale = const JustDatePickerLocale(),
    bool showContainer = true,
    JustDatePickerStyle? style,
    bool? enableHaptic,
  }) : this(
         key: key,
         value: value,
         onChanged: onChanged,
         firstDate: firstDate,
         lastDate: lastDate,
         selectableDayPredicate: selectableDayPredicate,
         variant: .inline,
         initialView: initialView,
         showWeekNumbers: showWeekNumbers,
         firstDayOfWeek: firstDayOfWeek,
         dayBuilder: dayBuilder,
         headerBuilder: headerBuilder,
         locale: locale,
         showContainer: showContainer,
         style: style,
         enableHaptic: enableHaptic,
       );

  /// Named constructor for dropdown popup mode.
  const JustDatePicker.dropdown({
    Key? key,
    DateTime? value,
    ValueChanged<DateTime>? onChanged,
    DateTime? firstDate,
    DateTime? lastDate,
    bool Function(DateTime)? selectableDayPredicate,
    String? placeholder,
    String? label,
    JustDatePickerLocale locale = const JustDatePickerLocale(),
    JustDatePickerStyle? style,
    bool? enableHaptic,
  }) : this(
         key: key,
         value: value,
         onChanged: onChanged,
         firstDate: firstDate,
         lastDate: lastDate,
         selectableDayPredicate: selectableDayPredicate,
         variant: .dropdown,
         placeholder: placeholder,
         label: label,
         locale: locale,
         style: style,
         enableHaptic: enableHaptic,
       );

  /// Named constructor for responsive adaptive mode.
  ///
  /// Automatically switches between floating popover (≥ 640px)
  /// and draggable bottom sheet (< 640px) based on screen width.
  const JustDatePicker.responsive({
    Key? key,
    DateTime? value,
    ValueChanged<DateTime>? onChanged,
    DateTime? firstDate,
    DateTime? lastDate,
    bool Function(DateTime)? selectableDayPredicate,
    String? placeholder,
    String? label,
    JustDatePickerLocale locale = const JustDatePickerLocale(),
    JustDatePickerStyle? style,
    bool? enableHaptic,
  }) : this(
         key: key,
         value: value,
         onChanged: onChanged,
         firstDate: firstDate,
         lastDate: lastDate,
         selectableDayPredicate: selectableDayPredicate,
         variant: .responsive,
         placeholder: placeholder,
         label: label,
         locale: locale,
         style: style,
         enableHaptic: enableHaptic,
       );

  @override
  State<JustDatePicker> createState() => _JustDatePickerState();
}

class _JustDatePickerState extends State<JustDatePicker> {
  final OverlayPortalController _overlayController = OverlayPortalController();

  void _toggleDropdown() {
    _overlayController.toggle();
  }

  void _onDateSelected(DateTime date) {
    widget.onChanged?.call(date);
    if ((widget.variant == .dropdown || widget.variant == .responsive) &&
        _overlayController.isShowing) {
      _overlayController.hide();
    }
  }

  String _formatDate(DateTime date) {
    final dayStr = date.day.toString().padLeft(2, '0');
    final monthStr = widget.locale.shortMonthNames[date.month - 1];
    return '$dayStr $monthStr ${date.year}';
  }

  DatePickerCalendar _buildCalendarWidget({
    ValueChanged<DateTime>? onDateSelected,
  }) {
    return DatePickerCalendar(
      selectedDate: widget.value,
      onDateSelected: onDateSelected ?? _onDateSelected,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      selectableDayPredicate: widget.selectableDayPredicate,
      initialView: widget.initialView,
      showWeekNumbers: widget.showWeekNumbers,
      firstDayOfWeek: widget.firstDayOfWeek,
      dayBuilder: widget.dayBuilder,
      headerBuilder: widget.headerBuilder,
      locale: widget.locale,
      showContainer: widget.showContainer,
      style: widget.style,
      enableHaptic: widget.enableHaptic,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.variant == .inline) {
      return _buildCalendarWidget();
    }

    if (widget.variant == .dropdown) {
      return _buildDropdownVariant(context);
    }

    if (widget.variant == .responsive) {
      return _buildResponsiveVariant(context);
    }

    // Modal variant renders as an inline trigger button that shows modal dialog on tap
    return _buildModalTriggerButton(context);
  }

  // ---------------------------------------------------------------------------
  // Dropdown Variant (Floating Popover with dynamic positioning & animation)
  // ---------------------------------------------------------------------------

  Widget _buildDropdownVariant(BuildContext context) {
    final colors = context.justColors;
    final typo = context.justTypo;
    final spacing = context.justSpacing;
    final radius = context.justRadius;
    final themeState = JustThemeProvider.maybeOf(context);
    final theme = themeState?.theme;
    final presetTokens = (theme ?? context.justTheme).presetTokens;

    final displayText = widget.value != null
        ? _formatDate(widget.value!)
        : (widget.placeholder ?? 'Select date');

    return OverlayPortal.overlayChildLayoutBuilder(
      controller: _overlayController,
      overlayChildBuilder: (overlayContext, info) {
        final targetOffset = MatrixUtils.transformPoint(
          info.childPaintTransform,
          .zero,
        );
        final triggerHeight = info.childSize.height;
        final triggerWidth = info.childSize.width;
        final screenSize = MediaQuery.sizeOf(overlayContext);
        final screenWidth = screenSize.width;
        final screenHeight = screenSize.height;

        const margin = 16.0;
        final double calendarWidth = (screenWidth - margin * 2).clamp(
          280.0,
          320.0,
        );
        const double estimatedCalendarHeight = 340.0;

        // Vertical flip logic
        final bool fitsBelow =
            targetOffset.dy +
                triggerHeight +
                spacing.xs +
                estimatedCalendarHeight <=
            screenHeight - margin;
        final bool fitsAbove =
            targetOffset.dy - spacing.xs - estimatedCalendarHeight >= margin;

        final bool showAbove = !fitsBelow && fitsAbove;

        final double topPosition;
        if (fitsBelow || !fitsAbove) {
          topPosition = targetOffset.dy + triggerHeight + spacing.xs;
        } else {
          topPosition = targetOffset.dy - estimatedCalendarHeight - spacing.xs;
        }

        // Horizontal positioning logic with screen boundary clamping
        double leftPosition = targetOffset.dx;
        if (leftPosition + calendarWidth > screenWidth - margin) {
          leftPosition = targetOffset.dx + triggerWidth - calendarWidth;
        }

        final maxLeft = screenWidth - calendarWidth - margin;
        if (maxLeft >= margin) {
          leftPosition = leftPosition.clamp(margin, maxLeft);
        } else {
          leftPosition = (screenWidth - calendarWidth) / 2;
        }

        final calendarWidget = _buildCalendarWidget();

        final themedCalendar = theme != null
            ? JustThemeProvider(
                lightTheme: theme,
                darkTheme: theme,
                initialThemeMode: themeState!.themeMode,
                child: calendarWidget,
              )
            : calendarWidget;

        return Stack(
          children: [
            // Backdrop barrier to dismiss on tap outside
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  if (_overlayController.isShowing) {
                    _overlayController.hide();
                  }
                },
              ),
            ),
            // Positioned Dropdown Calendar with entrance animation
            Positioned(
              left: leftPosition,
              top: topPosition,
              child: SizedBox(
                width: calendarWidth,
                child: JustOverlayTransition(
                  isVisible: true,
                  scaleAlignment: showAbove ? .bottomCenter : .topCenter,
                  child: themedCalendar,
                ),
              ),
            ),
          ],
        );
      },
      child: _buildTriggerButton(
        context,
        colors: colors,
        typo: typo,
        spacing: spacing,
        radius: radius,
        presetTokens: presetTokens,
        displayText: displayText,
        showChevron: true,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Responsive Variant (Desktop popover vs Mobile bottom sheet)
  // ---------------------------------------------------------------------------

  Widget _buildResponsiveVariant(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    if (screenWidth >= JustBreakpoints.sm) {
      return _buildDropdownVariant(context);
    }
    return _buildMobileSheetTrigger(context);
  }

  Widget _buildMobileSheetTrigger(BuildContext context) {
    final colors = context.justColors;
    final typo = context.justTypo;
    final spacing = context.justSpacing;
    final radius = context.justRadius;
    final themeState = JustThemeProvider.maybeOf(context);
    final theme = themeState?.theme;
    final presetTokens = (theme ?? context.justTheme).presetTokens;

    final displayText = widget.value != null
        ? _formatDate(widget.value!)
        : (widget.placeholder ?? 'Select date');

    return _buildTriggerButton(
      context,
      colors: colors,
      typo: typo,
      spacing: spacing,
      radius: radius,
      presetTokens: presetTokens,
      displayText: displayText,
      showChevron: false,
      onTap: () {
        final calendarWidget = DatePickerCalendar(
          selectedDate: widget.value,
          onDateSelected: (date) {
            widget.onChanged?.call(date);
            final scope = JustSheetScope.maybeOf(context);
            if (scope != null) {
              scope.dismiss();
            } else {
              Navigator.of(context, rootNavigator: false).pop();
            }
          },
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          selectableDayPredicate: widget.selectableDayPredicate,
          initialView: widget.initialView,
          showWeekNumbers: widget.showWeekNumbers,
          firstDayOfWeek: widget.firstDayOfWeek,
          dayBuilder: widget.dayBuilder,
          headerBuilder: widget.headerBuilder,
          locale: widget.locale,
          showContainer: false,
          style: widget.style,
          enableHaptic: widget.enableHaptic,
        );

        Widget content = SizedBox(
          width: double.infinity,
          child: calendarWidget,
        );

        if (theme != null) {
          content = JustThemeProvider(
            lightTheme: theme,
            darkTheme: theme,
            initialThemeMode: themeState!.themeMode,
            child: content,
          );
        }

        showJustBottomSheet<void>(
          context: context,
          content: content,
          draggable: true,
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Shared Trigger Button Builder
  // ---------------------------------------------------------------------------

  Widget _buildTriggerButton(
    BuildContext context, {
    required JustColorScheme colors,
    required JustTypographyScheme typo,
    required JustSpacingScheme spacing,
    required JustRadiusScheme radius,
    required JustPresetTokens presetTokens,
    required String displayText,
    required bool showChevron,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: .start,
      mainAxisSize: .min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: typo.bodySm.copyWith(
              color: colors.textPrimary,
              fontWeight: .w600,
            ),
          ),
          SizedBox(height: spacing.xs),
        ],
        JustPressable(
          onTap: onTap ?? _toggleDropdown,
          builder: (context, state) {
            return Container(
              padding: .symmetric(horizontal: spacing.md, vertical: spacing.sm),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: presetTokens.resolveBorderRadius(radius),
                border: presetTokens.showsDefaultBorder
                    ? .all(
                        color: colors.textPrimary,
                        width: presetTokens.borderWidth,
                      )
                    : .all(
                        color: colors.borderDefault,
                        width: presetTokens.borderWidth,
                      ),
              ),
              child: Row(
                mainAxisSize: .min,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 16.0,
                    color: colors.textSecondary,
                  ),
                  SizedBox(width: spacing.xs),
                  Text(
                    displayText,
                    style: typo.bodyMd.copyWith(
                      color: widget.value != null
                          ? colors.textPrimary
                          : colors.textSecondary,
                    ),
                  ),
                  if (showChevron) ...[
                    SizedBox(width: spacing.md),
                    Icon(
                      _overlayController.isShowing
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 18.0,
                      color: colors.textSecondary,
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Modal Variant
  // ---------------------------------------------------------------------------

  Widget _buildModalTriggerButton(BuildContext context) {
    final colors = context.justColors;
    final typo = context.justTypo;
    final spacing = context.justSpacing;
    final radius = context.justRadius;
    final theme = JustThemeProvider.of(context).theme;
    final presetTokens = theme.presetTokens;

    final displayText = widget.value != null
        ? _formatDate(widget.value!)
        : (widget.placeholder ?? 'Select date');

    return JustPressable(
      onTap: () async {
        final selected = await showJustDatePicker(
          context: context,
          initialDate: widget.value,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          selectableDayPredicate: widget.selectableDayPredicate,
          locale: widget.locale,
          style: widget.style,
        );
        if (selected != null) {
          _onDateSelected(selected);
        }
      },
      builder: (context, state) {
        return Container(
          padding: .symmetric(horizontal: spacing.md, vertical: spacing.sm),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: presetTokens.resolveBorderRadius(radius),
            border: presetTokens.showsDefaultBorder
                ? .all(
                    color: colors.textPrimary,
                    width: presetTokens.borderWidth,
                  )
                : .all(
                    color: colors.borderDefault,
                    width: presetTokens.borderWidth,
                  ),
          ),
          child: Row(
            mainAxisSize: .min,
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 16.0,
                color: colors.textSecondary,
              ),
              SizedBox(width: spacing.xs),
              Text(
                displayText,
                style: typo.bodyMd.copyWith(
                  color: widget.value != null
                      ? colors.textPrimary
                      : colors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Imperative helper to display a [JustDatePicker] inside a modal layer.
///
/// Automatically uses a bottom sheet ([JustSheetScope]) on mobile (< 640px)
/// and a centered dialog ([JustDialogScope]) on desktop/tablet (≥ 640px).
Future<DateTime?> showJustDatePicker({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
  bool Function(DateTime)? selectableDayPredicate,
  JustDatePickerLocale locale = const JustDatePickerLocale(),
  JustDatePickerStyle? style,
}) async {
  DateTime? result;

  final themeState = JustThemeProvider.maybeOf(context);
  final theme = themeState?.theme;

  Widget wrapWithTheme(Widget child) {
    Widget themedChild = child;
    if (theme != null) {
      themedChild = JustThemeProvider(
        lightTheme: theme,
        darkTheme: theme,
        initialThemeMode: themeState!.themeMode,
        child: child,
      );
    }
    return DefaultTextStyle(
      style: const TextStyle(decoration: .none),
      child: themedChild,
    );
  }

  final isMobile = MediaQuery.sizeOf(context).width < JustBreakpoints.sm;

  if (isMobile) {
    return showJustBottomSheet<DateTime>(
      context: context,
      content: wrapWithTheme(
        SizedBox(
          width: double.infinity,
          child: JustDatePicker.inline(
            value: initialDate,
            firstDate: firstDate,
            lastDate: lastDate,
            selectableDayPredicate: selectableDayPredicate,
            locale: locale,
            showContainer: false,
            style: style,
            onChanged: (date) {
              result = date;
              final scope = JustSheetScope.maybeOf(context);
              if (scope != null) {
                scope.dismiss();
              } else {
                Navigator.of(context, rootNavigator: false).pop();
              }
            },
          ),
        ),
      ),
      draggable: true,
    ).then((_) => result);
  }

  if (!context.mounted) return null;

  try {
    final dialogScope = JustDialogScope.of(context);
    await dialogScope.show<void>(
      content: wrapWithTheme(
        SizedBox(
          width: 340.0,
          child: JustDatePicker.inline(
            value: initialDate,
            firstDate: firstDate,
            lastDate: lastDate,
            selectableDayPredicate: selectableDayPredicate,
            locale: locale,
            style: style,
            onChanged: (date) {
              result = date;
              dialogScope.dismiss();
            },
          ),
        ),
      ),
    );
    return result;
  } catch (_) {
    if (!context.mounted) return null;
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      pageBuilder:
          (
            BuildContext dialogContext,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return Center(
              child: wrapWithTheme(
                SizedBox(
                  width: 340.0,
                  child: JustDatePicker.inline(
                    value: initialDate,
                    firstDate: firstDate,
                    lastDate: lastDate,
                    selectableDayPredicate: selectableDayPredicate,
                    locale: locale,
                    style: style,
                    onChanged: (date) {
                      result = date;
                      Navigator.of(dialogContext).pop();
                    },
                  ),
                ),
              ),
            );
          },
    );
    return result;
  }
}

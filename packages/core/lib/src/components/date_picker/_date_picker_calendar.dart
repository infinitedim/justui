import 'package:flutter/material.dart'
    show Colors, DateUtils, DateTimeRange, Icon, Icons, Theme;
import 'package:flutter/services.dart'
    show HapticFeedback, KeyDownEvent, KeyEvent, LogicalKeyboardKey;
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/just_ui_core.dart';

import '../shared/_shared_focus_indicator.dart';
import '../shared/_shared_pressable.dart';
import 'just_date_picker_style.dart';
import 'just_date_picker_theme.dart';
import 'just_date_picker_variants.dart';

/// Internal shared calendar grid widget that powers both single date
/// selection and date range selection.
class DatePickerCalendar extends StatefulWidget {
  /// Currently selected single date (for single selection mode).
  final DateTime? selectedDate;

  /// Currently selected date range (for range selection mode).
  final DateTimeRange? selectedRange;

  /// Callback when a single date is selected.
  final ValueChanged<DateTime>? onDateSelected;

  /// Callback when a range of dates is selected.
  final ValueChanged<DateTimeRange>? onRangeSelected;

  /// Earliest selectable date.
  final DateTime? firstDate;

  /// Latest selectable date.
  final DateTime? lastDate;

  /// Predicate function to determine if a date is selectable.
  final bool Function(DateTime)? selectableDayPredicate;

  /// Initial view of the calendar (day, month, or year).
  final JustCalendarView initialView;

  /// Whether to display week numbers column.
  final bool showWeekNumbers;

  /// First day of the week (1 = Monday, 7 = Sunday).
  final int firstDayOfWeek;

  /// Custom builder for day cells.
  final Widget Function(BuildContext context, DateTime date, bool isSelected)?
  dayBuilder;

  /// Custom builder for header navigation bar.
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

  /// Per-instance style overrides.
  final JustDatePickerStyle? style;

  /// Whether to trigger haptic feedback on selection.
  final bool? enableHaptic;

  /// Creates a [DatePickerCalendar] widget.
  const DatePickerCalendar({
    super.key,
    this.selectedDate,
    this.selectedRange,
    this.onDateSelected,
    this.onRangeSelected,
    this.firstDate,
    this.lastDate,
    this.selectableDayPredicate,
    this.initialView = .day,
    this.showWeekNumbers = false,
    this.firstDayOfWeek = 1,
    this.dayBuilder,
    this.headerBuilder,
    this.locale = const JustDatePickerLocale(),
    this.style,
    this.enableHaptic,
  });

  @override
  State<DatePickerCalendar> createState() => _DatePickerCalendarState();
}

class _DatePickerCalendarState extends State<DatePickerCalendar> {
  late DateTime _activeDate;
  late JustCalendarView _currentView;
  late DateTime _focusedDate;
  final FocusNode _focusNode = FocusNode();

  // Range selection intermediate state (first tap sets start)
  DateTime? _rangeStart;

  @override
  void initState() {
    super.initState();
    _activeDate =
        widget.selectedDate ?? widget.selectedRange?.start ?? DateTime.now();
    _focusedDate = _activeDate;
    _currentView = widget.initialView;
  }

  @override
  void didUpdateWidget(covariant DatePickerCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate &&
        widget.selectedDate != null) {
      _activeDate = widget.selectedDate!;
      _focusedDate = widget.selectedDate!;
    } else if (widget.selectedRange != oldWidget.selectedRange &&
        widget.selectedRange != null) {
      _activeDate = widget.selectedRange!.start;
      _focusedDate = widget.selectedRange!.start;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  bool _isDateSelectable(DateTime date) {
    if (widget.firstDate != null &&
        date.isBefore(
          DateTime(
            widget.firstDate!.year,
            widget.firstDate!.month,
            widget.firstDate!.day,
          ),
        )) {
      return false;
    }
    if (widget.lastDate != null &&
        date.isAfter(
          DateTime(
            widget.lastDate!.year,
            widget.lastDate!.month,
            widget.lastDate!.day,
            23,
            59,
            59,
          ),
        )) {
      return false;
    }
    if (widget.selectableDayPredicate != null &&
        !widget.selectableDayPredicate!(date)) {
      return false;
    }
    return true;
  }

  void _onDayTapped(DateTime date) {
    if (!_isDateSelectable(date)) return;

    final theme = context.readTheme();
    final haptic =
        widget.enableHaptic ?? theme.presetTokens.selectionHapticDefault;
    if (haptic) {
      HapticFeedback.lightImpact();
    }

    setState(() {
      _focusedDate = date;
    });

    if (widget.onRangeSelected != null) {
      if (_rangeStart == null) {
        // First tap: set range start
        setState(() {
          _rangeStart = date;
        });
      } else {
        // Second tap: set range end
        final start = _rangeStart!.isBefore(date) ? _rangeStart! : date;
        final end = _rangeStart!.isBefore(date) ? date : _rangeStart!;
        setState(() {
          _rangeStart = null;
        });
        widget.onRangeSelected!(DateTimeRange(start: start, end: end));
      }
    } else {
      widget.onDateSelected?.call(date);
    }
  }

  void _onPrevClicked() {
    setState(() {
      switch (_currentView) {
        case .day:
          _activeDate = DateTime(_activeDate.year, _activeDate.month - 1, 1);
          break;
        case .month:
          _activeDate = DateTime(_activeDate.year - 1, _activeDate.month, 1);
          break;
        case .year:
          _activeDate = DateTime(_activeDate.year - 12, _activeDate.month, 1);
          break;
      }
    });
  }

  void _onNextClicked() {
    setState(() {
      switch (_currentView) {
        case .day:
          _activeDate = DateTime(_activeDate.year, _activeDate.month + 1, 1);
          break;
        case .month:
          _activeDate = DateTime(_activeDate.year + 1, _activeDate.month, 1);
          break;
        case .year:
          _activeDate = DateTime(_activeDate.year + 12, _activeDate.month, 1);
          break;
      }
    });
  }

  void _toggleViewHeader() {
    setState(() {
      switch (_currentView) {
        case .day:
          _currentView = .month;
          break;
        case .month:
          _currentView = .year;
          break;
        case .year:
          _currentView = .day;
          break;
      }
    });
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return .ignored;

    if (_currentView == .day) {
      final actions = <LogicalKeyboardKey, VoidCallback>{
        .arrowLeft: () => _moveFocusedDate(const Duration(days: -1)),
        .arrowRight: () => _moveFocusedDate(const Duration(days: 1)),
        .arrowUp: () => _moveFocusedDate(const Duration(days: -7)),
        .arrowDown: () => _moveFocusedDate(const Duration(days: 7)),
        .pageUp: _onPrevClicked,
        .pageDown: _onNextClicked,
        .home: () {
          setState(() {
            _focusedDate = DateTime(_activeDate.year, _activeDate.month, 1);
          });
        },
        .end: () {
          final daysInMonth = DateUtils.getDaysInMonth(
            _activeDate.year,
            _activeDate.month,
          );
          setState(() {
            _focusedDate = DateTime(
              _activeDate.year,
              _activeDate.month,
              daysInMonth,
            );
          });
        },
        .enter: () => _onDayTapped(_focusedDate),
        .space: () => _onDayTapped(_focusedDate),
      };

      final action = actions[event.logicalKey];
      if (action != null) {
        action();
        return .handled;
      }
    }
    return .ignored;
  }

  void _moveFocusedDate(Duration delta) {
    final next = _focusedDate.add(delta);
    if (_isDateSelectable(next)) {
      setState(() {
        _focusedDate = next;
        if (next.month != _activeDate.month || next.year != _activeDate.year) {
          _activeDate = DateTime(next.year, next.month, 1);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.justColors;
    final typo = context.justTypo;
    final spacing = context.justSpacing;
    final radius = context.justRadius;
    final theme = JustThemeProvider.of(context).theme;
    final presetTokens = theme.presetTokens;

    // Theme & Style overrides
    final themeExtension = Theme.of(context).extension<JustDatePickerTheme>();
    final style = widget.style;

    final bgColor =
        style?.backgroundColor ??
        themeExtension?.inlineStyle?.backgroundColor ??
        colors.card;
    final borderColor =
        style?.borderColor ??
        themeExtension?.inlineStyle?.borderColor ??
        (presetTokens.showsDefaultBorder
            ? colors.textPrimary
            : colors.borderDefault);
    final borderRadius =
        style?.borderRadius ??
        themeExtension?.inlineStyle?.borderRadius ??
        presetTokens.resolveBorderRadius(radius);
    final padding =
        style?.padding ??
        themeExtension?.inlineStyle?.padding ??
        .all(spacing.md);
    final borderWidth = presetTokens.borderWidth;

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: borderRadius,
          border: presetTokens.showsDefaultBorder
              ? .all(color: borderColor, width: borderWidth)
              : (borderWidth > 0
                    ? .all(color: colors.borderDefault, width: borderWidth)
                    : null),
          boxShadow: presetTokens.resolveShadow(
            theme.shadows,
            .md,
            isPressed: false,
          ),
        ),
        child: Column(
          mainAxisSize: .min,
          children: [
            // Navigation Header
            widget.headerBuilder != null
                ? widget.headerBuilder!(
                    context,
                    _activeDate,
                    _currentView,
                    _toggleViewHeader,
                    _onPrevClicked,
                    _onNextClicked,
                  )
                : _buildHeader(colors, typo, spacing),
            SizedBox(height: spacing.sm),
            // View Content (Day / Month / Year)
            AnimatedSwitcher(
              duration: theme.animations.fast,
              child: _buildCurrentView(
                colors,
                typo,
                spacing,
                radius,
                presetTokens,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    JustColorScheme colors,
    JustTypographyScheme typo,
    JustSpacingScheme spacing,
  ) {
    String headerText;
    switch (_currentView) {
      case .day:
        headerText =
            '${widget.locale.monthNames[_activeDate.month - 1]} ${_activeDate.year}';
        break;
      case .month:
        headerText = '${_activeDate.year}';
        break;
      case .year:
        final startYear = _activeDate.year - 5;
        final endYear = _activeDate.year + 6;
        headerText = '$startYear - $endYear';
        break;
    }

    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        JustPressable(
          onTap: _onPrevClicked,
          builder: (context, state) {
            return Container(
              padding: .all(spacing.xs),
              decoration: BoxDecoration(
                color: state.isHovered ? colors.muted : Colors.transparent,
                borderRadius: .all(context.justRadius.sm),
              ),
              child: Icon(
                Icons.chevron_left_rounded,
                size: 20.0,
                color: colors.textPrimary,
              ),
            );
          },
        ),
        JustPressable(
          onTap: _toggleViewHeader,
          builder: (context, state) {
            return Container(
              padding: .symmetric(horizontal: spacing.sm, vertical: spacing.xs),
              decoration: BoxDecoration(
                color: state.isHovered ? colors.muted : Colors.transparent,
                borderRadius: .all(context.justRadius.sm),
              ),
              child: Text(
                headerText,
                style: typo.headingSm.copyWith(color: colors.textPrimary),
              ),
            );
          },
        ),
        JustPressable(
          onTap: _onNextClicked,
          builder: (context, state) {
            return Container(
              padding: .all(spacing.xs),
              decoration: BoxDecoration(
                color: state.isHovered ? colors.muted : Colors.transparent,
                borderRadius: .all(context.justRadius.sm),
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 20.0,
                color: colors.textPrimary,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCurrentView(
    JustColorScheme colors,
    JustTypographyScheme typo,
    JustSpacingScheme spacing,
    JustRadiusScheme radius,
    JustPresetTokens presetTokens,
  ) {
    switch (_currentView) {
      case .day:
        return _buildDayView(colors, typo, spacing, radius, presetTokens);
      case .month:
        return _buildMonthView(colors, typo, spacing, radius, presetTokens);
      case .year:
        return _buildYearView(colors, typo, spacing, radius, presetTokens);
    }
  }

  Widget _buildDayView(
    JustColorScheme colors,
    JustTypographyScheme typo,
    JustSpacingScheme spacing,
    JustRadiusScheme radius,
    JustPresetTokens presetTokens,
  ) {
    final firstDayOfMonth = DateTime(_activeDate.year, _activeDate.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(
      _activeDate.year,
      _activeDate.month,
    );

    // Calculate weekday offset (ISO weekday 1 = Monday ... 7 = Sunday)
    int firstWeekdayOffset = firstDayOfMonth.weekday - widget.firstDayOfWeek;
    if (firstWeekdayOffset < 0) firstWeekdayOffset += 7;

    // Shift weekday headers according to firstDayOfWeek
    final shiftedWeekdayHeaders = <String>[];
    for (int i = 0; i < 7; i++) {
      final idx = (widget.firstDayOfWeek - 1 + i) % 7;
      shiftedWeekdayHeaders.add(widget.locale.weekdayHeaders[idx]);
    }

    final int totalItems = firstWeekdayOffset + daysInMonth;

    return KeyedSubtree(
      key: ValueKey('day_view_${_activeDate.year}_${_activeDate.month}'),
      child: Column(
        mainAxisSize: .min,
        children: [
          // Weekday Header Labels
          Row(
            children: shiftedWeekdayHeaders
                .map(
                  (header) => Expanded(
                    child: Center(
                      child: Text(
                        header,
                        style: typo.caption.copyWith(
                          color: colors.textSecondary,
                          fontWeight: .w600,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: spacing.xs),
          // Days Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
            ),
            itemCount: totalItems,
            itemBuilder: (context, index) {
              if (index < firstWeekdayOffset) {
                return const SizedBox.shrink();
              }
              final day = index - firstWeekdayOffset + 1;
              final date = DateTime(_activeDate.year, _activeDate.month, day);
              return _buildDayCell(date, colors, typo, radius, presetTokens);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(
    DateTime date,
    JustColorScheme colors,
    JustTypographyScheme typo,
    JustRadiusScheme radius,
    JustPresetTokens presetTokens,
  ) {
    final DateTime now = .now();
    final isToday = DateUtils.isSameDay(date, now);
    final isSelected =
        widget.selectedDate != null &&
        DateUtils.isSameDay(date, widget.selectedDate!);
    final isFocused = DateUtils.isSameDay(date, _focusedDate);
    final isSelectable = _isDateSelectable(date);

    // Range checking
    bool isRangeStart = false;
    bool isRangeEnd = false;
    bool isInRange = false;

    if (widget.selectedRange != null) {
      final start = widget.selectedRange!.start;
      final end = widget.selectedRange!.end;
      isRangeStart = DateUtils.isSameDay(date, start);
      isRangeEnd = DateUtils.isSameDay(date, end);
      isInRange = date.isAfter(start) && date.isBefore(end);
    } else if (_rangeStart != null) {
      isRangeStart = DateUtils.isSameDay(date, _rangeStart!);
    }

    if (widget.dayBuilder != null) {
      return widget.dayBuilder!(
        context,
        date,
        isSelected || isRangeStart || isRangeEnd,
      );
    }

    final isHighlight = isSelected || isRangeStart || isRangeEnd;
    final isCircular = presetTokens.datePickerCircularSelection;

    final cellBorderRadius = isCircular
        ? presetTokens.resolveBorderRadius(radius, isCircle: true)
        : presetTokens.resolveBorderRadius(radius);

    Color cellBgColor = Colors.transparent;
    if (isHighlight) {
      cellBgColor = widget.style?.selectedDayColor ?? colors.borderFocus;
    } else if (isInRange) {
      cellBgColor =
          widget.style?.rangeHighlightColor ??
          colors.borderFocus.withValues(alpha: 0.15);
    }

    Color cellTextColor = colors.textPrimary;
    if (isHighlight) {
      cellTextColor = widget.style?.selectedDayTextColor ?? colors.textInverse;
    } else if (!isSelectable) {
      cellTextColor = colors.textDisabled;
    } else if (isToday && !isHighlight) {
      cellTextColor = colors.borderFocus;
    }

    final Border? border = isToday && !isHighlight
        ? .all(
            color:
                widget.style?.todayBorderColor ??
                (presetTokens.showsDefaultBorder
                    ? colors.textPrimary
                    : colors.borderFocus),
            width: presetTokens.borderWidth,
          )
        : null;

    return Semantics(
      label:
          'Day ${date.day}, ${widget.locale.monthNames[date.month - 1]} ${date.year}',
      selected: isHighlight,
      enabled: isSelectable,
      child: JustPressable(
        enabled: isSelectable,
        onTap: () => _onDayTapped(date),
        builder: (context, state) {
          return FocusIndicator(
            isFocused: isFocused && state.isFocused,
            borderRadius: cellBorderRadius,
            child: Container(
              decoration: BoxDecoration(
                color: state.isHovered && !isHighlight
                    ? colors.muted
                    : cellBgColor,
                borderRadius: cellBorderRadius,
                border: border,
              ),
              child: Center(
                child: Text(
                  '${date.day}',
                  style: typo.bodySm.copyWith(
                    color: cellTextColor,
                    fontWeight: isHighlight || isToday ? .w700 : .w400,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthView(
    JustColorScheme colors,
    JustTypographyScheme typo,
    JustSpacingScheme spacing,
    JustRadiusScheme radius,
    JustPresetTokens presetTokens,
  ) {
    return KeyedSubtree(
      key: ValueKey('month_view_${_activeDate.year}'),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
          childAspectRatio: 1.5,
        ),
        itemCount: 12,
        itemBuilder: (context, index) {
          final monthName = widget.locale.shortMonthNames[index];
          final isSelectedMonth = _activeDate.month == (index + 1);

          return JustPressable(
            onTap: () {
              setState(() {
                _activeDate = DateTime(_activeDate.year, index + 1, 1);
                _currentView = .day;
              });
            },
            builder: (context, state) {
              return Container(
                decoration: BoxDecoration(
                  color: isSelectedMonth
                      ? colors.borderFocus
                      : (state.isHovered ? colors.muted : Colors.transparent),
                  borderRadius: presetTokens.resolveBorderRadius(radius),
                  border: presetTokens.showsDefaultBorder
                      ? .all(
                          color: colors.textPrimary,
                          width: presetTokens.borderWidth,
                        )
                      : null,
                ),
                child: Center(
                  child: Text(
                    monthName,
                    style: typo.bodySm.copyWith(
                      color: isSelectedMonth
                          ? colors.textInverse
                          : colors.textPrimary,
                      fontWeight: isSelectedMonth ? .w700 : .w500,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildYearView(
    JustColorScheme colors,
    JustTypographyScheme typo,
    JustSpacingScheme spacing,
    JustRadiusScheme radius,
    JustPresetTokens presetTokens,
  ) {
    final startYear = _activeDate.year - 5;

    return KeyedSubtree(
      key: ValueKey('year_view_$startYear'),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
          childAspectRatio: 1.5,
        ),
        itemCount: 12,
        itemBuilder: (context, index) {
          final year = startYear + index;
          final isSelectedYear = _activeDate.year == year;

          return JustPressable(
            onTap: () {
              setState(() {
                _activeDate = DateTime(year, _activeDate.month, 1);
                _currentView = .month;
              });
            },
            builder: (context, state) {
              return Container(
                decoration: BoxDecoration(
                  color: isSelectedYear
                      ? colors.borderFocus
                      : (state.isHovered ? colors.muted : Colors.transparent),
                  borderRadius: presetTokens.resolveBorderRadius(radius),
                  border: presetTokens.showsDefaultBorder
                      ? .all(
                          color: colors.textPrimary,
                          width: presetTokens.borderWidth,
                        )
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$year',
                    style: typo.bodySm.copyWith(
                      color: isSelectedYear
                          ? colors.textInverse
                          : colors.textPrimary,
                      fontWeight: isSelectedYear ? .w700 : .w500,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

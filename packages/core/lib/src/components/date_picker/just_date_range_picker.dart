import 'package:flutter/material.dart' show Colors, DateTimeRange;
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/just_ui_core.dart';

import '../shared/_shared_pressable.dart';
import '_date_picker_calendar.dart';
import 'just_date_picker_style.dart';
import 'just_date_picker_variants.dart';

/// A date range selection component supporting multi-day selection and quick presets.
class JustDateRangePicker extends StatelessWidget {
  /// Currently selected range.
  final DateTimeRange? value;

  /// Callback executed when a new range is selected.
  final ValueChanged<DateTimeRange>? onChanged;

  /// Earliest selectable date.
  final DateTime? firstDate;

  /// Latest selectable date.
  final DateTime? lastDate;

  /// Predicate function for disabling dates.
  final bool Function(DateTime)? selectableDayPredicate;

  /// List of quick preset ranges (e.g. 'Last 7 Days', 'This Month').
  final List<JustDateRangePreset>? presets;

  /// Whether to display week numbers column.
  final bool showWeekNumbers;

  /// First day of week (1=Mon, 7=Sun).
  final int firstDayOfWeek;

  /// Custom day cell builder.
  final Widget Function(BuildContext context, DateTime date, bool isSelected)?
  dayBuilder;

  /// Custom header builder.
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

  /// Whether to enable haptic feedback on selection.
  final bool? enableHaptic;

  /// Creates a [JustDateRangePicker] component.
  const JustDateRangePicker({
    super.key,
    this.value,
    this.onChanged,
    this.firstDate,
    this.lastDate,
    this.selectableDayPredicate,
    this.presets,
    this.showWeekNumbers = false,
    this.firstDayOfWeek = 7,
    this.dayBuilder,
    this.headerBuilder,
    this.locale = const JustDatePickerLocale(),
    this.style,
    this.enableHaptic,
  });

  /// Default list of common range presets.
  static List<JustDateRangePreset> defaultPresets() {
    final DateTime now = .now();
    final today = DateTime(now.year, now.month, now.day);

    return [
      JustDateRangePreset(
        label: 'Today',
        resolve: () => DateTimeRange(start: today, end: today),
      ),
      JustDateRangePreset(
        label: 'Last 7 Days',
        resolve: () => DateTimeRange(
          start: today.subtract(const Duration(days: 6)),
          end: today,
        ),
      ),
      JustDateRangePreset(
        label: 'Last 30 Days',
        resolve: () => DateTimeRange(
          start: today.subtract(const Duration(days: 29)),
          end: today,
        ),
      ),
      JustDateRangePreset(
        label: 'This Month',
        resolve: () {
          final start = DateTime(today.year, today.month, 1);
          final end = DateTime(today.year, today.month + 1, 0);
          return DateTimeRange(start: start, end: end);
        },
      ),
      JustDateRangePreset(
        label: 'This Year',
        resolve: () {
          final start = DateTime(today.year, 1, 1);
          final end = DateTime(today.year, 12, 31);
          return DateTimeRange(start: start, end: end);
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.justColors;
    final typo = context.justTypo;
    final spacing = context.justSpacing;
    final radius = context.justRadius;
    final theme = JustThemeProvider.of(context).theme;
    final presetTokens = theme.presetTokens;

    final calendar = DatePickerCalendar(
      selectedRange: value,
      onRangeSelected: onChanged,
      firstDate: firstDate,
      lastDate: lastDate,
      selectableDayPredicate: selectableDayPredicate,
      showWeekNumbers: showWeekNumbers,
      firstDayOfWeek: firstDayOfWeek,
      dayBuilder: dayBuilder,
      headerBuilder: headerBuilder,
      locale: locale,
      style: style,
      enableHaptic: enableHaptic,
    );

    if (presets == null || presets!.isEmpty) {
      return calendar;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 500;

        final presetsColumn = Container(
          padding: .all(spacing.sm),
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
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            children: presets!
                .map(
                  (preset) => Padding(
                    padding: .only(bottom: spacing.xs),
                    child: JustPressable(
                      onTap: () {
                        final range = preset.resolve();
                        onChanged?.call(range);
                      },
                      builder: (context, state) {
                        return Container(
                          width: double.infinity,
                          padding: .symmetric(
                            horizontal: spacing.sm,
                            vertical: spacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: state.isHovered
                                ? colors.muted
                                : Colors.transparent,
                            borderRadius: .all(context.justRadius.sm),
                          ),
                          child: Text(
                            preset.label,
                            style: typo.bodySm.copyWith(
                              color: colors.textPrimary,
                              fontWeight: .w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        );

        if (isMobile) {
          return Column(
            mainAxisSize: .min,
            children: [
              presetsColumn,
              SizedBox(height: spacing.sm),
              calendar,
            ],
          );
        }

        return Row(
          mainAxisSize: .min,
          crossAxisAlignment: .start,
          children: [
            SizedBox(width: 140.0, child: presetsColumn),
            SizedBox(width: spacing.sm),
            Flexible(child: calendar),
          ],
        );
      },
    );
  }
}

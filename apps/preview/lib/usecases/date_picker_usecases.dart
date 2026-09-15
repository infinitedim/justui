// ignore_for_file: implementation_imports
import 'package:flutter/material.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/date_picker/just_date_picker.dart';
import 'package:just_ui_core/src/components/date_picker/just_date_picker_variants.dart';
import 'package:just_ui_core/src/components/date_picker/just_date_range_picker.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// ── Inline Date Picker ───────────────────────────────────────────────────────

@widgetbook.UseCase(name: 'Inline Date Picker', type: JustDatePicker)
Widget buildJustDatePickerInlineUseCase(BuildContext context) {
  final bool showWeekNumbers = context.knobs.boolean(
    label: 'Show Week Numbers',
    initialValue: false,
  );
  final int firstDayOfWeek = context.knobs.object.dropdown<int>(
    label: 'First Day of Week',
    options: <int>[1, 7],
    initialOption: 1,
    labelBuilder: (int day) => day == 1 ? 'Monday (1)' : 'Sunday (7)',
  );
  final JustCalendarView initialView = context.knobs.object
      .dropdown<JustCalendarView>(
        label: 'Initial View',
        options: JustCalendarView.values,
        initialOption: JustCalendarView.day,
        labelBuilder: (JustCalendarView view) => view.name.toUpperCase(),
      );

  return Center(
    child: Padding(
      padding: const .all(16.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340.0),
        child: _InlineDatePickerDemo(
          showWeekNumbers: showWeekNumbers,
          firstDayOfWeek: firstDayOfWeek,
          initialView: initialView,
        ),
      ),
    ),
  );
}

class _InlineDatePickerDemo extends StatefulWidget {
  final bool showWeekNumbers;
  final int firstDayOfWeek;
  final JustCalendarView initialView;

  const _InlineDatePickerDemo({
    required this.showWeekNumbers,
    required this.firstDayOfWeek,
    required this.initialView,
  });

  @override
  State<_InlineDatePickerDemo> createState() => _InlineDatePickerDemoState();
}

class _InlineDatePickerDemoState extends State<_InlineDatePickerDemo> {
  DateTime? _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final JustColorScheme colors = context.justColors;
    final JustTypographyScheme typo = context.justTypo;

    return Column(
      mainAxisSize: .min,
      children: <Widget>[
        JustDatePicker.inline(
          value: _selectedDate,
          showWeekNumbers: widget.showWeekNumbers,
          firstDayOfWeek: widget.firstDayOfWeek,
          initialView: widget.initialView,
          onChanged: (DateTime date) {
            setState(() {
              _selectedDate = date;
            });
          },
        ),
        const SizedBox(height: 16.0),
        Text(
          _selectedDate != null
              ? 'Selected: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
              : 'No date selected',
          style: typo.bodyMd.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}

// ── Dropdown Date Picker ─────────────────────────────────────────────────────

@widgetbook.UseCase(name: 'Dropdown Date Picker', type: JustDatePicker)
Widget buildJustDatePickerDropdownUseCase(BuildContext context) {
  final String label = context.knobs.string(
    label: 'Label',
    initialValue: 'Birth Date',
  );
  final String placeholder = context.knobs.string(
    label: 'Placeholder',
    initialValue: 'Select a date...',
  );

  return Center(
    child: Padding(
      padding: const .all(16.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320.0),
        child: _DropdownDatePickerDemo(label: label, placeholder: placeholder),
      ),
    ),
  );
}

class _DropdownDatePickerDemo extends StatefulWidget {
  final String label;
  final String placeholder;

  const _DropdownDatePickerDemo({
    required this.label,
    required this.placeholder,
  });

  @override
  State<_DropdownDatePickerDemo> createState() =>
      _DropdownDatePickerDemoState();
}

class _DropdownDatePickerDemoState extends State<_DropdownDatePickerDemo> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return JustDatePicker.dropdown(
      value: _selectedDate,
      label: widget.label,
      placeholder: widget.placeholder,
      onChanged: (DateTime date) {
        setState(() {
          _selectedDate = date;
        });
      },
    );
  }
}

// ── Modal Date Picker ────────────────────────────────────────────────────────

@widgetbook.UseCase(name: 'Modal Dialog Date Picker', type: JustDatePicker)
Widget buildJustDatePickerModalUseCase(BuildContext context) {
  return const Center(
    child: Padding(padding: .all(16.0), child: _ModalDatePickerDemo()),
  );
}

class _ModalDatePickerDemo extends StatefulWidget {
  const _ModalDatePickerDemo();

  @override
  State<_ModalDatePickerDemo> createState() => _ModalDatePickerDemoState();
}

class _ModalDatePickerDemoState extends State<_ModalDatePickerDemo> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final JustColorScheme colors = context.justColors;
    final JustTypographyScheme typo = context.justTypo;

    return Column(
      mainAxisSize: .min,
      children: <Widget>[
        JustDatePicker(
          value: _selectedDate,
          variant: .modal,
          placeholder: 'Open Modal Date Picker',
          onChanged: (DateTime date) {
            setState(() {
              _selectedDate = date;
            });
          },
        ),
        const SizedBox(height: 16.0),
        Text(
          _selectedDate != null
              ? 'Selected: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
              : 'No date selected',
          style: typo.bodyMd.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}

// ── Constraints & Filtering ──────────────────────────────────────────────────

@widgetbook.UseCase(name: 'Date Constraints & Predicate', type: JustDatePicker)
Widget buildJustDatePickerConstraintsUseCase(BuildContext context) {
  final bool disableWeekends = context.knobs.boolean(
    label: 'Disable Weekends',
    initialValue: true,
  );

  return Center(
    child: Padding(
      padding: const .all(16.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340.0),
        child: _ConstraintsDatePickerDemo(disableWeekends: disableWeekends),
      ),
    ),
  );
}

class _ConstraintsDatePickerDemo extends StatefulWidget {
  final bool disableWeekends;

  const _ConstraintsDatePickerDemo({required this.disableWeekends});

  @override
  State<_ConstraintsDatePickerDemo> createState() =>
      _ConstraintsDatePickerDemoState();
}

class _ConstraintsDatePickerDemoState
    extends State<_ConstraintsDatePickerDemo> {
  DateTime? _selectedDate;
  final DateTime _now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final DateTime firstDate = DateTime(_now.year, _now.month, 5);
    final DateTime lastDate = DateTime(_now.year, _now.month, 25);

    return JustDatePicker.inline(
      value: _selectedDate,
      firstDate: firstDate,
      lastDate: lastDate,
      selectableDayPredicate: (DateTime date) {
        if (widget.disableWeekends &&
            (date.weekday == 6 || date.weekday == 7)) {
          return false;
        }
        return true;
      },
      onChanged: (DateTime date) {
        setState(() {
          _selectedDate = date;
        });
      },
    );
  }
}

// ── Custom Builders ─────────────────────────────────────────────────────────

@widgetbook.UseCase(name: 'Custom Day & Header Builders', type: JustDatePicker)
Widget buildJustDatePickerCustomBuildersUseCase(BuildContext context) {
  return Center(
    child: Padding(
      padding: const .all(16.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340.0),
        child: const _CustomBuildersDemo(),
      ),
    ),
  );
}

class _CustomBuildersDemo extends StatefulWidget {
  const _CustomBuildersDemo();

  @override
  State<_CustomBuildersDemo> createState() => _CustomBuildersDemoState();
}

class _CustomBuildersDemoState extends State<_CustomBuildersDemo> {
  DateTime? _selectedDate;
  final Set<int> eventDays = <int>{10, 15, 22};

  @override
  Widget build(BuildContext context) {
    final JustColorScheme colors = context.justColors;
    final JustTypographyScheme typo = context.justTypo;

    return JustDatePicker.inline(
      value: _selectedDate,
      headerBuilder:
          (
            BuildContext context,
            DateTime activeDate,
            JustCalendarView view,
            VoidCallback toggleView,
            void Function() onPrev,
            void Function() onNext,
          ) {
            return Container(
              padding: const .symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: colors.muted,
                borderRadius: .circular(8.0),
              ),
              child: Row(
                mainAxisAlignment: .spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    onTap: onPrev,
                    child: Icon(
                      Icons.chevron_left_rounded,
                      size: 20.0,
                      color: colors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: toggleView,
                    child: Row(
                      mainAxisSize: .min,
                      children: <Widget>[
                        Icon(
                          Icons.calendar_month_rounded,
                          size: 16.0,
                          color: colors.borderFocus,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          '${activeDate.month}/${activeDate.year}',
                          style: typo.headingSm.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: onNext,
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 20.0,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          },
      dayBuilder: (BuildContext context, DateTime date, bool isSelected) {
        final bool hasEvent = eventDays.contains(date.day);
        return Container(
          decoration: BoxDecoration(
            color: isSelected
                ? colors.borderFocus
                : (hasEvent
                      ? colors.warning.withValues(alpha: 0.2)
                      : Colors.transparent),
            borderRadius: .circular(8.0),
            border: hasEvent ? .all(color: colors.warning, width: 1.5) : null,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: .center,
              children: <Widget>[
                Text(
                  '${date.day}',
                  style: typo.bodySm.copyWith(
                    color: isSelected ? colors.textInverse : colors.textPrimary,
                    fontWeight: isSelected || hasEvent ? .w700 : .w400,
                  ),
                ),
                if (hasEvent && !isSelected)
                  Container(
                    width: 4.0,
                    height: 4.0,
                    decoration: BoxDecoration(
                      color: colors.warning,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
      onChanged: (DateTime date) {
        setState(() {
          _selectedDate = date;
        });
      },
    );
  }
}

// ── Date Range Picker ────────────────────────────────────────────────────────

@widgetbook.UseCase(name: 'Date Range Picker', type: JustDateRangePicker)
Widget buildJustDateRangePickerUseCase(BuildContext context) {
  final bool showPresets = context.knobs.boolean(
    label: 'Show Presets Sidebar',
    initialValue: true,
  );

  return Center(
    child: Padding(
      padding: const .all(16.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520.0),
        child: _DateRangePickerDemo(showPresets: showPresets),
      ),
    ),
  );
}

class _DateRangePickerDemo extends StatefulWidget {
  final bool showPresets;

  const _DateRangePickerDemo({required this.showPresets});

  @override
  State<_DateRangePickerDemo> createState() => _DateRangePickerDemoState();
}

class _DateRangePickerDemoState extends State<_DateRangePickerDemo> {
  DateTimeRange? _selectedRange;

  @override
  Widget build(BuildContext context) {
    final JustColorScheme colors = context.justColors;
    final JustTypographyScheme typo = context.justTypo;

    return Column(
      mainAxisSize: .min,
      children: <Widget>[
        JustDateRangePicker(
          value: _selectedRange,
          presets: widget.showPresets
              ? JustDateRangePicker.defaultPresets()
              : null,
          onChanged: (DateTimeRange<DateTime> range) {
            setState(() {
              _selectedRange = range;
            });
          },
        ),
        const SizedBox(height: 16.0),
        Text(
          _selectedRange != null
              ? 'Range: ${_selectedRange!.start.day}/${_selectedRange!.start.month} → ${_selectedRange!.end.day}/${_selectedRange!.end.month}/${_selectedRange!.end.year}'
              : 'Tap start and end dates to select a range',
          style: typo.bodyMd.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}

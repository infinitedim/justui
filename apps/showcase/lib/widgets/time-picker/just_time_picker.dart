// justui-meta: registry=a89b060e233004040ce1a637a4b5450e4b84883338779636c6533aa99239613a local=42cb6b6c1a3a792dbffbe7af6c3493840f7ed5a5bd832724906eed7348a4b0e0
import 'package:flutter/material.dart'
    show DayPeriod, Icon, Icons, Theme, TimeOfDay, showGeneralDialog;
import 'package:flutter/widgets.dart';
import 'package:showcase/core/just_ui_core.dart';

import '../button/just_button.dart';
import '../dialog/just_dialog.dart';
import '../shared/just_overlay_transition.dart';
import '../shared/just_pressable.dart';
import '../sheet/just_sheet.dart';
import '_time_picker_dial.dart';
import '_time_picker_input.dart';
import '_time_picker_spinner.dart';
import 'just_time_picker_style.dart';
import 'just_time_picker_theme.dart';
import 'just_time_picker_variants.dart';

export '_time_picker_dial.dart';
export '_time_picker_input.dart';
export '_time_picker_spinner.dart';
export 'just_time_picker_style.dart';
export 'just_time_picker_theme.dart';
export 'just_time_picker_variants.dart';

/// A highly customizable, accessible time picker component adhering to JustUI design tokens.
///
/// Supports three internal interaction modes ([JustTimePickerMode]):
/// - [JustTimePickerMode.dial]: interactive circular clock face with draggable hand.
/// - [JustTimePickerMode.spinner]: three-column vertical scrollable wheels with magnetic snapping.
/// - [JustTimePickerMode.input]: direct numeric text input with stepper controls.
///
/// Supports four display variants ([JustTimePickerVariant]):
/// - [JustTimePickerVariant.inline]: renders directly in the widget tree without overlay.
/// - [JustTimePickerVariant.dropdown]: floating popover anchored beneath a trigger field via [OverlayPortal].
/// - [JustTimePickerVariant.modal]: trigger button opening a modal dialog (desktop) or bottom sheet (mobile).
/// - [JustTimePickerVariant.responsive]: adaptively switches between dropdown on desktop (≥640px) and bottom sheet on mobile (<640px).
class JustTimePicker extends StatefulWidget {
  /// Currently selected time value.
  final TimeOfDay? value;

  /// Callback fired when the selected time changes.
  final ValueChanged<TimeOfDay>? onChanged;

  /// Earliest selectable time (inclusive).
  final TimeOfDay? firstTime;

  /// Latest selectable time (inclusive).
  final TimeOfDay? lastTime;

  /// Predicate to selectively disable specific times.
  final bool Function(TimeOfDay)? selectableTimePredicate;

  /// Display variant ([JustTimePickerVariant.inline], [JustTimePickerVariant.modal],
  /// [JustTimePickerVariant.dropdown], [JustTimePickerVariant.responsive]).
  final JustTimePickerVariant variant;

  /// Internal interaction mode ([JustTimePickerMode.dial], [JustTimePickerMode.spinner],
  /// [JustTimePickerMode.input]).
  final JustTimePickerMode mode;

  /// Time format ([JustTimeFormat.twelveHour] or [JustTimeFormat.twentyFourHour]).
  final JustTimeFormat timeFormat;

  /// Minute selection interval (e.g. 1, 5, 10, 15, 30). Must evenly divide 60.
  final int minuteInterval;

  /// Initial focused segment when the picker opens ([JustTimePickerSegment.hour],
  /// [JustTimePickerSegment.minute], [JustTimePickerSegment.period]).
  final JustTimePickerSegment initialSegment;

  /// Whether the user can toggle between dial, spinner, and input modes.
  final bool allowModeSwitch;

  /// Per-instance style overrides.
  final JustTimePickerStyle? style;

  /// Override haptic feedback (null = defer to theme/preset).
  final bool? enableHaptic;

  /// Locale strings for labels, action buttons, and tooltips.
  final JustTimePickerLocale locale;

  /// Placeholder text for dropdown/responsive trigger button when no time is selected.
  final String? placeholder;

  /// Label text displayed above the trigger button.
  final String? label;

  /// Whether to render the outer card container in inline mode.
  final bool showContainer;

  /// Creates a [JustTimePicker] widget.
  const JustTimePicker({
    super.key,
    this.value,
    this.onChanged,
    this.firstTime,
    this.lastTime,
    this.selectableTimePredicate,
    this.variant = .inline,
    this.mode = .dial,
    this.timeFormat = .twelveHour,
    this.minuteInterval = 1,
    this.initialSegment = .hour,
    this.allowModeSwitch = true,
    this.showContainer = true,
    this.style,
    this.enableHaptic,
    this.locale = const JustTimePickerLocale(),
    this.placeholder,
    this.label,
  });

  /// Named constructor for inline time picker mode.
  const JustTimePicker.inline({
    Key? key,
    TimeOfDay? value,
    ValueChanged<TimeOfDay>? onChanged,
    TimeOfDay? firstTime,
    TimeOfDay? lastTime,
    bool Function(TimeOfDay)? selectableTimePredicate,
    JustTimePickerMode mode = .dial,
    JustTimeFormat timeFormat = .twelveHour,
    int minuteInterval = 1,
    JustTimePickerSegment initialSegment = .hour,
    bool allowModeSwitch = true,
    bool showContainer = true,
    JustTimePickerStyle? style,
    bool? enableHaptic,
    JustTimePickerLocale locale = const JustTimePickerLocale(),
  }) : this(
         key: key,
         value: value,
         onChanged: onChanged,
         firstTime: firstTime,
         lastTime: lastTime,
         selectableTimePredicate: selectableTimePredicate,
         variant: .inline,
         mode: mode,
         timeFormat: timeFormat,
         minuteInterval: minuteInterval,
         initialSegment: initialSegment,
         allowModeSwitch: allowModeSwitch,
         showContainer: showContainer,
         style: style,
         enableHaptic: enableHaptic,
         locale: locale,
       );

  /// Named constructor for dropdown popup mode anchored to a trigger field.
  const JustTimePicker.dropdown({
    Key? key,
    TimeOfDay? value,
    ValueChanged<TimeOfDay>? onChanged,
    TimeOfDay? firstTime,
    TimeOfDay? lastTime,
    bool Function(TimeOfDay)? selectableTimePredicate,
    JustTimePickerMode mode = .dial,
    JustTimeFormat timeFormat = .twelveHour,
    int minuteInterval = 1,
    JustTimePickerSegment initialSegment = .hour,
    bool allowModeSwitch = true,
    JustTimePickerStyle? style,
    bool? enableHaptic,
    JustTimePickerLocale locale = const JustTimePickerLocale(),
    String? placeholder,
    String? label,
  }) : this(
         key: key,
         value: value,
         onChanged: onChanged,
         firstTime: firstTime,
         lastTime: lastTime,
         selectableTimePredicate: selectableTimePredicate,
         variant: .dropdown,
         mode: mode,
         timeFormat: timeFormat,
         minuteInterval: minuteInterval,
         initialSegment: initialSegment,
         allowModeSwitch: allowModeSwitch,
         style: style,
         enableHaptic: enableHaptic,
         locale: locale,
         placeholder: placeholder,
         label: label,
       );

  /// Named constructor for modal trigger button mode.
  const JustTimePicker.modal({
    Key? key,
    TimeOfDay? value,
    ValueChanged<TimeOfDay>? onChanged,
    TimeOfDay? firstTime,
    TimeOfDay? lastTime,
    bool Function(TimeOfDay)? selectableTimePredicate,
    JustTimePickerMode mode = .dial,
    JustTimeFormat timeFormat = .twelveHour,
    int minuteInterval = 1,
    JustTimePickerSegment initialSegment = .hour,
    bool allowModeSwitch = true,
    JustTimePickerStyle? style,
    bool? enableHaptic,
    JustTimePickerLocale locale = const JustTimePickerLocale(),
    String? placeholder,
    String? label,
  }) : this(
         key: key,
         value: value,
         onChanged: onChanged,
         firstTime: firstTime,
         lastTime: lastTime,
         selectableTimePredicate: selectableTimePredicate,
         variant: .modal,
         mode: mode,
         timeFormat: timeFormat,
         minuteInterval: minuteInterval,
         initialSegment: initialSegment,
         allowModeSwitch: allowModeSwitch,
         style: style,
         enableHaptic: enableHaptic,
         locale: locale,
         placeholder: placeholder,
         label: label,
       );

  /// Named constructor for responsive adaptive mode.
  ///
  /// Automatically switches between floating popover (≥ 640px)
  /// and draggable bottom sheet (< 640px) based on screen width.
  const JustTimePicker.responsive({
    Key? key,
    TimeOfDay? value,
    ValueChanged<TimeOfDay>? onChanged,
    TimeOfDay? firstTime,
    TimeOfDay? lastTime,
    bool Function(TimeOfDay)? selectableTimePredicate,
    JustTimePickerMode mode = .dial,
    JustTimeFormat timeFormat = .twelveHour,
    int minuteInterval = 1,
    JustTimePickerSegment initialSegment = .hour,
    bool allowModeSwitch = true,
    JustTimePickerStyle? style,
    bool? enableHaptic,
    JustTimePickerLocale locale = const JustTimePickerLocale(),
    String? placeholder,
    String? label,
  }) : this(
         key: key,
         value: value,
         onChanged: onChanged,
         firstTime: firstTime,
         lastTime: lastTime,
         selectableTimePredicate: selectableTimePredicate,
         variant: .responsive,
         mode: mode,
         timeFormat: timeFormat,
         minuteInterval: minuteInterval,
         initialSegment: initialSegment,
         allowModeSwitch: allowModeSwitch,
         style: style,
         enableHaptic: enableHaptic,
         locale: locale,
         placeholder: placeholder,
         label: label,
       );

  @override
  State<JustTimePicker> createState() => _JustTimePickerState();
}

class _JustTimePickerState extends State<JustTimePicker> {
  late TimeOfDay _currentTime;
  late JustTimePickerMode _currentMode;
  late JustTimePickerSegment _activeSegment;

  final OverlayPortalController _overlayController = OverlayPortalController();

  @override
  void initState() {
    super.initState();
    _currentTime = widget.value ?? const TimeOfDay(hour: 12, minute: 0);
    _currentMode = widget.mode;
    _activeSegment = widget.initialSegment;
  }

  @override
  void didUpdateWidget(covariant JustTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != null) {
      _currentTime = widget.value!;
    }
    if (widget.mode != oldWidget.mode) {
      _currentMode = widget.mode;
    }
  }

  void _toggleDropdown() {
    _overlayController.toggle();
  }

  void _onTimeSelected(TimeOfDay time) {
    setState(() {
      _currentTime = time;
    });
    widget.onChanged?.call(time);
    if ((widget.variant == .dropdown || widget.variant == .responsive) &&
        _overlayController.isShowing) {
      _overlayController.hide();
    }
  }

  void _cycleNextMode() {
    setState(() {
      _currentMode = switch (_currentMode) {
        .dial => .spinner,
        .spinner => .input,
        .input => .dial,
      };
    });
  }

  String _formatTime(TimeOfDay time) {
    if (widget.timeFormat == .twentyFourHour) {
      final String hourStr = time.hour.toString().padLeft(2, '0');
      final String minuteStr = time.minute.toString().padLeft(2, '0');
      return '$hourStr:$minuteStr';
    } else {
      final int hourOfPeriod = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
      final String hourStr = hourOfPeriod.toString().padLeft(2, '0');
      final String minuteStr = time.minute.toString().padLeft(2, '0');
      final String periodStr = time.period == DayPeriod.am
          ? widget.locale.amLabel
          : widget.locale.pmLabel;
      return '$hourStr:$minuteStr $periodStr';
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (widget.variant) {
      .inline => _buildInlineVariant(context),
      .dropdown => _buildDropdownVariant(context),
      .modal => _buildModalTriggerButton(context),
      .responsive => _buildResponsiveVariant(context),
    };
  }

  // ---------------------------------------------------------------------------
  // Inline Variant
  // ---------------------------------------------------------------------------

  Widget _buildInlineVariant(BuildContext context) {
    return _buildTimePickerBody(context);
  }

  // ---------------------------------------------------------------------------
  // Body Widget (Header + Dial/Spinner/Input Content in styled Container)
  // ---------------------------------------------------------------------------

  Widget _buildTimePickerBody(
    BuildContext context, {
    ValueChanged<TimeOfDay>? onTimeSelected,
  }) {
    final JustColorScheme colors = context.justColors;
    final JustSpacingScheme spacing = context.justSpacing;
    final JustRadiusScheme radius = context.justRadius;
    final JustThemeData theme = context.justTheme;
    final JustPresetTokens presetTokens = theme.presetTokens;

    final JustTimePickerTheme? themeExtension = Theme.of(context)
        .extension<JustTimePickerTheme>();
    final JustTimePickerStyle? style = widget.style;

    final Color bgColor =
        style?.backgroundColor ??
        themeExtension?.inlineStyle?.backgroundColor ??
        colors.card;
    final Color borderColor =
        style?.borderColor ??
        themeExtension?.inlineStyle?.borderColor ??
        (presetTokens.showsDefaultBorder
            ? colors.textPrimary
            : colors.borderDefault);
    final BorderRadius borderRadius =
        style?.borderRadius ??
        themeExtension?.inlineStyle?.borderRadius ??
        presetTokens.resolveBorderRadius(radius);
    final EdgeInsets padding =
        style?.padding ??
        themeExtension?.inlineStyle?.padding ??
        .all(spacing.md);
    final double borderWidth = presetTokens.borderWidth;

    final void Function(TimeOfDay value) effectiveOnChanged =
        onTimeSelected ?? _onTimeSelected;

    return Container(
      padding: widget.showContainer ? padding : .zero,
      decoration: widget.showContainer
          ? BoxDecoration(
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
            )
          : null,
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .center,
        children: <Widget>[
          // Header: Digital Time Readout + Mode Switch Button
          _buildPickerHeader(context, theme),
          SizedBox(height: spacing.sm),

          // Active Mode Engine
          switch (_currentMode) {
            .dial => TimePickerDial(
              selectedTime: _currentTime,
              onChanged: effectiveOnChanged,
              firstTime: widget.firstTime,
              lastTime: widget.lastTime,
              selectableTimePredicate: widget.selectableTimePredicate,
              timeFormat: widget.timeFormat,
              minuteInterval: widget.minuteInterval,
              activeSegment: _activeSegment,
              onSegmentChanged: (JustTimePickerSegment seg) =>
                  setState(() => _activeSegment = seg),
              autoAdvance: true,
              locale: widget.locale,
              style: widget.style,
              enableHaptic: widget.enableHaptic,
            ),
            .spinner => TimePickerSpinner(
              value: _currentTime,
              onChanged: effectiveOnChanged,
              firstTime: widget.firstTime,
              lastTime: widget.lastTime,
              selectableTimePredicate: widget.selectableTimePredicate,
              timeFormat: widget.timeFormat,
              minuteInterval: widget.minuteInterval,
              initialSegment: _activeSegment,
              locale: widget.locale,
              style: widget.style,
              enableHaptic: widget.enableHaptic,
            ),
            .input => TimePickerInput(
              selectedTime: _currentTime,
              onChanged: effectiveOnChanged,
              firstTime: widget.firstTime,
              lastTime: widget.lastTime,
              selectableTimePredicate: widget.selectableTimePredicate,
              timeFormat: widget.timeFormat,
              minuteInterval: widget.minuteInterval,
              locale: widget.locale,
              style: widget.style,
              enableHaptic: widget.enableHaptic,
            ),
          },
        ],
      ),
    );
  }

  Widget _buildPickerHeader(BuildContext context, JustThemeData theme) {
    final JustColorScheme colors = context.justColors;
    final JustTypographyScheme typo = context.justTypo;
    final JustSpacingScheme spacing = context.justSpacing;
    final JustRadiusScheme radius = theme.radius;
    final JustPresetTokens presetTokens = theme.presetTokens;
    final JustTimePickerStyle? style = widget.style;

    final int hourVal = widget.timeFormat == .twentyFourHour
        ? _currentTime.hour
        : (_currentTime.hourOfPeriod == 0 ? 12 : _currentTime.hourOfPeriod);
    final String hourStr = hourVal.toString().padLeft(2, '0');
    final String minuteStr = _currentTime.minute.toString().padLeft(2, '0');

    final bool isHourActive = _activeSegment == .hour;
    final bool isMinuteActive = _activeSegment == .minute;
    final bool isAm = _currentTime.period == DayPeriod.am;

    final BorderRadius resolvedRadius = presetTokens.resolveBorderRadius(
      radius,
    );
    final Color activeBg = style?.periodActiveColor ?? colors.borderFocus;
    final Color activeFg = style?.selectedTextColor ?? colors.textInverse;
    final Color inactiveBg = colors.muted;
    final Color inactiveFg = style?.dialTextColor ?? colors.textPrimary;
    final double borderWidth = presetTokens.borderWidth;

    final String modeTooltip = switch (_currentMode) {
      .dial => widget.locale.spinnerModeTooltip,
      .spinner => widget.locale.inputModeTooltip,
      .input => widget.locale.dialModeTooltip,
    };

    final IconData modeIcon = switch (_currentMode) {
      .dial => Icons.view_agenda_rounded,
      .spinner => Icons.keyboard_outlined,
      .input => Icons.access_time_rounded,
    };

    return Row(
      mainAxisAlignment: .spaceBetween,
      crossAxisAlignment: .center,
      children: <Widget>[
        // Digital Time Readout (Segment Switcher)
        Row(
          mainAxisSize: .min,
          children: <Widget>[
            // Hour Segment Button
            Semantics(
              button: true,
              label: '${widget.locale.hourLabel}: $hourStr',
              selected: isHourActive,
              child: JustPressable(
                onTap: () {
                  setState(() {
                    _activeSegment = .hour;
                  });
                },
                builder: (BuildContext context, JustInteractionState state) {
                  return Container(
                    padding: .symmetric(
                      horizontal: spacing.sm,
                      vertical: spacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: isHourActive ? activeBg : inactiveBg,
                      borderRadius: resolvedRadius,
                      border: Border.all(
                        color: isHourActive
                            ? (presetTokens.showsDefaultBorder
                                  ? colors.textPrimary
                                  : colors.borderFocus)
                            : (presetTokens.showsDefaultBorder
                                  ? colors.borderDefault
                                  : colors.borderDefault),
                        width: borderWidth,
                      ),
                    ),
                    child: Text(
                      hourStr,
                      style: typo.headingLg.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isHourActive ? activeFg : inactiveFg,
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: .symmetric(horizontal: spacing.xxs),
              child: Text(
                ':',
                style: typo.headingLg.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ),
            // Minute Segment Button
            Semantics(
              button: true,
              label: '${widget.locale.minuteLabel}: $minuteStr',
              selected: isMinuteActive,
              child: JustPressable(
                onTap: () {
                  setState(() {
                    _activeSegment = .minute;
                  });
                },
                builder: (BuildContext context, JustInteractionState state) {
                  return Container(
                    padding: .symmetric(
                      horizontal: spacing.sm,
                      vertical: spacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: isMinuteActive ? activeBg : inactiveBg,
                      borderRadius: resolvedRadius,
                      border: Border.all(
                        color: isMinuteActive
                            ? (presetTokens.showsDefaultBorder
                                  ? colors.textPrimary
                                  : colors.borderFocus)
                            : (presetTokens.showsDefaultBorder
                                  ? colors.borderDefault
                                  : colors.borderDefault),
                        width: borderWidth,
                      ),
                    ),
                    child: Text(
                      minuteStr,
                      style: typo.headingLg.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isMinuteActive ? activeFg : inactiveFg,
                      ),
                    ),
                  );
                },
              ),
            ),
            // AM / PM Segment Buttons (12-hour format only)
            if (widget.timeFormat == .twelveHour) ...<Widget>[
              SizedBox(width: spacing.xs),
              Container(
                decoration: BoxDecoration(
                  color: inactiveBg,
                  borderRadius: resolvedRadius,
                  border: Border.all(
                    color: presetTokens.showsDefaultBorder
                        ? colors.borderDefault
                        : colors.borderDefault,
                    width: borderWidth,
                  ),
                ),
                child: Row(
                  mainAxisSize: .min,
                  children: <Widget>[
                    Semantics(
                      button: true,
                      label: widget.locale.amLabel,
                      selected: isAm,
                      child: JustPressable(
                        onTap: () {
                          if (!isAm) {
                            final TimeOfDay toggled = _currentTime
                                .togglePeriod();
                            _onTimeSelected(toggled);
                          }
                        },
                        builder:
                            (BuildContext context, JustInteractionState state) {
                              return Container(
                                padding: .symmetric(
                                  horizontal: spacing.xs,
                                  vertical: spacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: isAm
                                      ? activeBg
                                      : const Color(0x00000000),
                                  borderRadius: resolvedRadius,
                                ),
                                child: Text(
                                  widget.locale.amLabel,
                                  style: typo.bodySm.copyWith(
                                    fontWeight: isAm
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isAm ? activeFg : inactiveFg,
                                  ),
                                ),
                              );
                            },
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: widget.locale.pmLabel,
                      selected: !isAm,
                      child: JustPressable(
                        onTap: () {
                          if (isAm) {
                            final TimeOfDay toggled = _currentTime
                                .togglePeriod();
                            _onTimeSelected(toggled);
                          }
                        },
                        builder:
                            (BuildContext context, JustInteractionState state) {
                              return Container(
                                padding: .symmetric(
                                  horizontal: spacing.xs,
                                  vertical: spacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: !isAm
                                      ? activeBg
                                      : const Color(0x00000000),
                                  borderRadius: resolvedRadius,
                                ),
                                child: Text(
                                  widget.locale.pmLabel,
                                  style: typo.bodySm.copyWith(
                                    fontWeight: !isAm
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: !isAm ? activeFg : inactiveFg,
                                  ),
                                ),
                              );
                            },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),

        // Mode Switcher Button
        if (widget.allowModeSwitch)
          Semantics(
            button: true,
            label: modeTooltip,
            child: JustPressable(
              onTap: _cycleNextMode,
              builder: (BuildContext context, JustInteractionState state) {
                return Container(
                  padding: .all(spacing.xs),
                  decoration: BoxDecoration(
                    color: colors.muted,
                    borderRadius: resolvedRadius,
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
                  child: Icon(
                    modeIcon,
                    size: 18.0,
                    color: colors.textSecondary,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Dropdown Variant (Floating Popover with dynamic positioning & animation)
  // ---------------------------------------------------------------------------

  Widget _buildDropdownVariant(BuildContext context) {
    final JustColorScheme colors = context.justColors;
    final JustTypographyScheme typo = context.justTypo;
    final JustSpacingScheme spacing = context.justSpacing;
    final JustRadiusScheme radius = context.justRadius;
    final JustThemeProviderState? themeState = JustThemeProvider.maybeOf(
      context,
    );
    final JustThemeData? theme = themeState?.theme;
    final JustPresetTokens presetTokens =
        (theme ?? context.justTheme).presetTokens;

    final String displayText = widget.value != null
        ? _formatTime(widget.value!)
        : (widget.placeholder ?? 'Select time');

    return OverlayPortal.overlayChildLayoutBuilder(
      controller: _overlayController,
      overlayChildBuilder:
          (BuildContext overlayContext, OverlayChildLayoutInfo info) {
            final Offset targetOffset = MatrixUtils.transformPoint(
              info.childPaintTransform,
              Offset.zero,
            );
            final double triggerHeight = info.childSize.height;
            final double triggerWidth = info.childSize.width;
            final Size screenSize = MediaQuery.sizeOf(overlayContext);
            final double screenWidth = screenSize.width;
            final double screenHeight = screenSize.height;

            const double margin = 16.0;
            final double pickerWidth = (screenWidth - margin * 2).clamp(
              280.0,
              320.0,
            );
            const double estimatedPickerHeight = 360.0;

            // Vertical flip logic
            final bool fitsBelow =
                targetOffset.dy +
                    triggerHeight +
                    spacing.xs +
                    estimatedPickerHeight <=
                screenHeight - margin;
            final bool fitsAbove =
                targetOffset.dy - spacing.xs - estimatedPickerHeight >= margin;

            final bool showAbove = !fitsBelow && fitsAbove;

            final double topPosition;
            if (fitsBelow || !fitsAbove) {
              topPosition = targetOffset.dy + triggerHeight + spacing.xs;
            } else {
              topPosition =
                  targetOffset.dy - estimatedPickerHeight - spacing.xs;
            }

            // Horizontal positioning logic with screen boundary clamping
            double leftPosition = targetOffset.dx;
            if (leftPosition + pickerWidth > screenWidth - margin) {
              leftPosition = targetOffset.dx + triggerWidth - pickerWidth;
            }

            final double maxLeft = screenWidth - pickerWidth - margin;
            if (maxLeft >= margin) {
              leftPosition = leftPosition.clamp(margin, maxLeft);
            } else {
              leftPosition = (screenWidth - pickerWidth) / 2;
            }

            final Widget pickerWidget = _buildTimePickerBody(context);

            final Widget themedPicker = theme != null
                ? JustThemeProvider(
                    lightTheme: theme,
                    darkTheme: theme,
                    initialThemeMode: themeState!.themeMode,
                    child: pickerWidget,
                  )
                : pickerWidget;

            return Stack(
              children: <Widget>[
                // Backdrop barrier to dismiss on tap outside
                Positioned.fill(
                  child: GestureDetector(
                    behavior: .translucent,
                    onTap: () {
                      if (_overlayController.isShowing) {
                        _overlayController.hide();
                      }
                    },
                  ),
                ),
                // Positioned Dropdown Picker with entrance animation
                Positioned(
                  left: leftPosition,
                  top: topPosition,
                  child: SizedBox(
                    width: pickerWidth,
                    child: JustOverlayTransition(
                      isVisible: true,
                      scaleAlignment: showAbove
                          ? Alignment.bottomCenter
                          : Alignment.topCenter,
                      child: themedPicker,
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
    final double screenWidth = MediaQuery.sizeOf(context).width;
    if (screenWidth >= JustBreakpoints.sm) {
      return _buildDropdownVariant(context);
    }
    return _buildMobileSheetTrigger(context);
  }

  Widget _buildMobileSheetTrigger(BuildContext context) {
    final JustColorScheme colors = context.justColors;
    final JustTypographyScheme typo = context.justTypo;
    final JustSpacingScheme spacing = context.justSpacing;
    final JustRadiusScheme radius = context.justRadius;
    final JustThemeProviderState? themeState = JustThemeProvider.maybeOf(
      context,
    );
    final JustThemeData? theme = themeState?.theme;
    final JustPresetTokens presetTokens =
        (theme ?? context.justTheme).presetTokens;

    final String displayText = widget.value != null
        ? _formatTime(widget.value!)
        : (widget.placeholder ?? 'Select time');

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
        final Widget pickerWidget = _buildTimePickerBody(
          context,
          onTimeSelected: (TimeOfDay time) {
            _onTimeSelected(time);
            try {
              JustSheetScope.of(context).dismiss();
            } catch (_) {
              // If no JustSheetScope, sheet was already dismissed
            }
          },
        );

        Widget content = SizedBox(width: .infinity, child: pickerWidget);

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
      children: <Widget>[
        if (widget.label != null) ...<Widget>[
          Text(
            widget.label!,
            style: typo.bodySm.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: spacing.xs),
        ],
        JustPressable(
          onTap: onTap ?? _toggleDropdown,
          builder: (BuildContext context, JustInteractionState state) {
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
                children: <Widget>[
                  Icon(
                    Icons.access_time_rounded,
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
                  if (showChevron) ...<Widget>[
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
  // Modal Variant Trigger Button
  // ---------------------------------------------------------------------------

  Widget _buildModalTriggerButton(BuildContext context) {
    final JustColorScheme colors = context.justColors;
    final JustTypographyScheme typo = context.justTypo;
    final JustSpacingScheme spacing = context.justSpacing;
    final JustRadiusScheme radius = context.justRadius;
    final JustThemeData theme = JustThemeProvider.of(context).theme;
    final JustPresetTokens presetTokens = theme.presetTokens;

    final String displayText = widget.value != null
        ? _formatTime(widget.value!)
        : (widget.placeholder ?? 'Select time');

    return JustPressable(
      onTap: () async {
        final TimeOfDay? selected = await showJustTimePicker(
          context: context,
          initialTime: widget.value,
          firstTime: widget.firstTime,
          lastTime: widget.lastTime,
          selectableTimePredicate: widget.selectableTimePredicate,
          mode: widget.mode,
          timeFormat: widget.timeFormat,
          minuteInterval: widget.minuteInterval,
          locale: widget.locale,
          style: widget.style,
          enableHaptic: widget.enableHaptic,
        );
        if (selected != null) {
          _onTimeSelected(selected);
        }
      },
      builder: (BuildContext context, JustInteractionState state) {
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
            children: <Widget>[
              Icon(
                Icons.access_time_rounded,
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

/// Content wrapper for modal dialogs and bottom sheets, including action buttons.
class _ModalTimePickerContent extends StatefulWidget {
  final TimeOfDay? initialTime;
  final TimeOfDay? firstTime;
  final TimeOfDay? lastTime;
  final bool Function(TimeOfDay)? selectableTimePredicate;
  final JustTimePickerMode mode;
  final JustTimeFormat timeFormat;
  final int minuteInterval;
  final JustTimePickerLocale locale;
  final JustTimePickerStyle? style;
  final bool? enableHaptic;
  final ValueChanged<TimeOfDay> onConfirm;
  final VoidCallback onCancel;

  const _ModalTimePickerContent({
    this.initialTime,
    this.firstTime,
    this.lastTime,
    this.selectableTimePredicate,
    this.mode = .dial,
    this.timeFormat = .twelveHour,
    this.minuteInterval = 1,
    this.locale = const JustTimePickerLocale(),
    this.style,
    this.enableHaptic,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<_ModalTimePickerContent> createState() =>
      _ModalTimePickerContentState();
}

class _ModalTimePickerContentState extends State<_ModalTimePickerContent> {
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime ?? const TimeOfDay(hour: 12, minute: 0);
  }

  @override
  Widget build(BuildContext context) {
    final JustSpacingScheme spacing = context.justSpacing;

    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .stretch,
      children: <Widget>[
        JustTimePicker.inline(
          value: _selectedTime,
          firstTime: widget.firstTime,
          lastTime: widget.lastTime,
          selectableTimePredicate: widget.selectableTimePredicate,
          mode: widget.mode,
          timeFormat: widget.timeFormat,
          minuteInterval: widget.minuteInterval,
          locale: widget.locale,
          showContainer: false,
          style: widget.style,
          enableHaptic: widget.enableHaptic,
          onChanged: (TimeOfDay time) {
            setState(() {
              _selectedTime = time;
            });
          },
        ),
        SizedBox(height: spacing.md),
        Row(
          mainAxisAlignment: .end,
          children: <Widget>[
            JustButton(
              label: widget.locale.cancelLabel,
              variant: .ghost,
              size: .sm,
              onPressed: widget.onCancel,
            ),
            SizedBox(width: spacing.sm),
            JustButton(
              label: widget.locale.confirmLabel,
              variant: .primary,
              size: .sm,
              onPressed: () => widget.onConfirm(_selectedTime),
            ),
          ],
        ),
      ],
    );
  }
}

/// Imperative helper to display a [JustTimePicker] inside an accessible modal layer.
///
/// Automatically uses a draggable bottom sheet ([JustSheetScope]) on mobile (< 640px)
/// and a centered dialog ([JustDialogScope]) on desktop/tablet (≥ 640px).
Future<TimeOfDay?> showJustTimePicker({
  required BuildContext context,
  TimeOfDay? initialTime,
  TimeOfDay? firstTime,
  TimeOfDay? lastTime,
  bool Function(TimeOfDay)? selectableTimePredicate,
  JustTimePickerMode mode = .dial,
  JustTimeFormat timeFormat = .twelveHour,
  int minuteInterval = 1,
  JustTimePickerLocale locale = const JustTimePickerLocale(),
  JustTimePickerStyle? style,
  bool? enableHaptic,
}) async {
  TimeOfDay? result;

  final JustThemeProviderState? themeState = JustThemeProvider.maybeOf(context);
  final JustThemeData? theme = themeState?.theme;

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

  final bool isMobile = MediaQuery.sizeOf(context).width < JustBreakpoints.sm;

  if (isMobile) {
    return showJustBottomSheet<TimeOfDay>(
      context: context,
      content: wrapWithTheme(
        SizedBox(
          width: .infinity,
          child: _ModalTimePickerContent(
            initialTime: initialTime,
            firstTime: firstTime,
            lastTime: lastTime,
            selectableTimePredicate: selectableTimePredicate,
            mode: mode,
            timeFormat: timeFormat,
            minuteInterval: minuteInterval,
            locale: locale,
            style: style,
            enableHaptic: enableHaptic,
            onConfirm: (TimeOfDay time) {
              result = time;
              final JustSheetController? scope = JustSheetScope.maybeOf(
                context,
              );
              if (scope != null) {
                scope.dismiss();
              } else {
                Navigator.of(context, rootNavigator: false).pop();
              }
            },
            onCancel: () {
              final JustSheetController? scope = JustSheetScope.maybeOf(
                context,
              );
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
    final JustDialogController dialogScope = JustDialogScope.of(context);
    await dialogScope.show<void>(
      content: wrapWithTheme(
        SizedBox(
          width: 340.0,
          child: _ModalTimePickerContent(
            initialTime: initialTime,
            firstTime: firstTime,
            lastTime: lastTime,
            selectableTimePredicate: selectableTimePredicate,
            mode: mode,
            timeFormat: timeFormat,
            minuteInterval: minuteInterval,
            locale: locale,
            style: style,
            enableHaptic: enableHaptic,
            onConfirm: (TimeOfDay time) {
              result = time;
              dialogScope.dismiss();
            },
            onCancel: () => dialogScope.dismiss(),
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
                  child: _ModalTimePickerContent(
                    initialTime: initialTime,
                    firstTime: firstTime,
                    lastTime: lastTime,
                    selectableTimePredicate: selectableTimePredicate,
                    mode: mode,
                    timeFormat: timeFormat,
                    minuteInterval: minuteInterval,
                    locale: locale,
                    style: style,
                    enableHaptic: enableHaptic,
                    onConfirm: (TimeOfDay time) {
                      result = time;
                      Navigator.of(dialogContext).pop();
                    },
                    onCancel: () => Navigator.of(dialogContext).pop(),
                  ),
                ),
              ),
            );
          },
    );
    return result;
  }
}

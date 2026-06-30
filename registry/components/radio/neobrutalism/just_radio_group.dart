import 'package:flutter/widgets.dart';
import '../../theme/default/_shared_theme_provider.dart';
import 'just_radio.dart';

/// Configuration option for [JustRadioGroup].
class JustRadioOption<T> {
  /// The value associated with this option.
  final T value;

  /// The label widget to show for this option.
  final Widget label;

  /// Whether this option is explicitly disabled.
  final bool isDisabled;

  /// Creates a [JustRadioOption].
  const JustRadioOption({
    required this.value,
    required this.label,
    this.isDisabled = false,
  });
}

/// A container that groups and lays out multiple [JustRadio] buttons.
class JustRadioGroup<T> extends StatelessWidget {
  /// The currently selected value in the group.
  final T? value;

  /// The list of options available in this radio group.
  final List<JustRadioOption<T>> options;

  /// Callback executed when any option is selected.
  final ValueChanged<T>? onChanged;

  /// The direction to lay out the radio options. Defaults to [.vertical].
  final Axis direction;

  /// Custom spacing between radio items. If null, falls back to theme spacing.
  final double? spacing;

  /// Whether the entire radio group is disabled.
  final bool isDisabled;

  /// Creates a [JustRadioGroup].
  const JustRadioGroup({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.direction = .vertical,
    this.spacing,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeSpacing = JustThemeProvider.of(context).theme.spacing;
    final resolvedSpacing = spacing ?? themeSpacing.md;

    return Flex(
      direction: direction,
      mainAxisSize: .min,
      crossAxisAlignment: direction == .vertical ? .start : .center,
      spacing: resolvedSpacing,
      children: [
        for (final option in options)
          JustRadio<T>(
            value: option.value,
            groupValue: value,
            onChanged: option.isDisabled || isDisabled ? null : onChanged,
            label: option.label,
            isDisabled: option.isDisabled || isDisabled,
          ),
      ],
    );
  }
}

// justui-meta: registry=379b38b4d42a89d5d9258fe5eac352ceca2d403366c5e2f00738023a4ac02d94 local=746634da9b7b77886a7a6095caf3d5e1dda27dfc76ad4ff387e9b366d149b0f9
import 'package:flutter/widgets.dart';
import 'package:showcase/core/theme/schemes/spacing_scheme.dart';

import 'package:showcase/core/just_ui_core.dart';

import '../radio/just_radio.dart';

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
    final JustSpacingScheme themeSpacing = JustThemeProvider.of(context)
        .theme
        .spacing;
    final double resolvedSpacing = spacing ?? themeSpacing.md;

    return Flex(
      direction: direction,
      mainAxisSize: .min,
      crossAxisAlignment: direction == .vertical ? .start : .center,
      spacing: resolvedSpacing,
      children: <Widget>[
        for (final JustRadioOption<T> option in options)
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

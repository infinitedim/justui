// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:just_ui_core/src/components/switch/just_switch.dart';
import 'package:just_ui_core/src/components/switch/just_switch_style.dart';

@widgetbook.UseCase(name: 'Default Switch', type: JustSwitch)
Widget buildJustSwitchDefaultUseCase(BuildContext context) {
  final isDisabled = context.knobs.boolean(
    label: 'Is Disabled',
    initialValue: false,
  );
  final size = context.knobs.object.dropdown<JustSwitchSize>(
    label: 'Size',
    options: JustSwitchSize.values,
    initialOption: JustSwitchSize.md,
  );
  final hasLabel = context.knobs.boolean(
    label: 'Has Label',
    initialValue: true,
  );

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: _InteractiveSwitchDemo(
        isDisabled: isDisabled,
        size: size,
        hasLabel: hasLabel,
      ),
    ),
  );
}

class _InteractiveSwitchDemo extends StatefulWidget {
  final bool isDisabled;
  final JustSwitchSize size;
  final bool hasLabel;

  const _InteractiveSwitchDemo({
    required this.isDisabled,
    required this.size,
    required this.hasLabel,
  });

  @override
  State<_InteractiveSwitchDemo> createState() => _InteractiveSwitchDemoState();
}

class _InteractiveSwitchDemoState extends State<_InteractiveSwitchDemo> {
  bool _value = true;

  @override
  Widget build(BuildContext context) {
    return JustSwitch(
      value: _value,
      onChanged: widget.isDisabled
          ? null
          : (val) {
              setState(() {
                _value = val;
              });
            },
      isDisabled: widget.isDisabled,
      size: widget.size,
      label: widget.hasLabel ? const Text('Enable Notifications') : null,
    );
  }
}

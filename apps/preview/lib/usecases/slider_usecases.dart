// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:just_ui_core/src/components/slider/just_slider.dart';
import 'package:just_ui_core/src/components/slider/just_slider_style.dart';

@widgetbook.UseCase(name: 'Default Slider', type: JustSlider)
Widget buildJustSliderDefaultUseCase(BuildContext context) {
  final showTooltip = context.knobs.boolean(
    label: 'Show Tooltip',
    initialValue: true,
  );
  final size = context.knobs.object.dropdown<JustSliderSize>(
    label: 'Size',
    options: JustSliderSize.values,
    initialOption: JustSliderSize.md,
  );

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360.0),
        child: _InteractiveSliderDemo(
          showTooltip: showTooltip,
          size: size,
        ),
      ),
    ),
  );
}

class _InteractiveSliderDemo extends StatefulWidget {
  final bool showTooltip;
  final JustSliderSize size;

  const _InteractiveSliderDemo({
    required this.showTooltip,
    required this.size,
  });

  @override
  State<_InteractiveSliderDemo> createState() => _InteractiveSliderDemoState();
}

class _InteractiveSliderDemoState extends State<_InteractiveSliderDemo> {
  double _value = 0.5;

  @override
  Widget build(BuildContext context) {
    return JustSlider(
      value: _value,
      onChanged: (val) {
        setState(() {
          _value = val;
        });
      },
      showTooltip: widget.showTooltip,
      size: widget.size,
    );
  }
}

@widgetbook.UseCase(name: 'Range Slider', type: JustSlider)
Widget buildJustSliderRangeUseCase(BuildContext context) {
  final showTooltip = context.knobs.boolean(
    label: 'Show Tooltip',
    initialValue: true,
  );
  final size = context.knobs.object.dropdown<JustSliderSize>(
    label: 'Size',
    options: JustSliderSize.values,
    initialOption: JustSliderSize.md,
  );

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360.0),
        child: _InteractiveRangeSliderDemo(
          showTooltip: showTooltip,
          size: size,
        ),
      ),
    ),
  );
}

class _InteractiveRangeSliderDemo extends StatefulWidget {
  final bool showTooltip;
  final JustSliderSize size;

  const _InteractiveRangeSliderDemo({
    required this.showTooltip,
    required this.size,
  });

  @override
  State<_InteractiveRangeSliderDemo> createState() =>
      _InteractiveRangeSliderDemoState();
}

class _InteractiveRangeSliderDemoState
    extends State<_InteractiveRangeSliderDemo> {
  JustRangeValues _values = const JustRangeValues(0.2, 0.8);

  @override
  Widget build(BuildContext context) {
    return JustSlider.range(
      rangeValues: _values,
      onRangeChanged: (val) {
        setState(() {
          _values = val;
        });
      },
      showTooltip: widget.showTooltip,
      size: widget.size,
    );
  }
}

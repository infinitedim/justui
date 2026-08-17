// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:just_ui_core/src/components/slider/just_slider.dart';
import 'package:just_ui_core/src/components/slider/just_slider_style.dart';

@widgetbook.UseCase(name: 'Default Slider', type: JustSlider)
Widget buildJustSliderDefaultUseCase(BuildContext context) {
  final value = context.knobs.double.slider(
    label: 'Value',
    initialValue: 0.5,
    min: 0.0,
    max: 1.0,
  );
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
        child: JustSlider(
          value: value,
          onChanged: (val) {},
          showTooltip: showTooltip,
          size: size,
        ),
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Range Slider', type: JustSlider)
Widget buildJustSliderRangeUseCase(BuildContext context) {
  final start = context.knobs.double.slider(
    label: 'Range Start',
    initialValue: 0.2,
    min: 0.0,
    max: 1.0,
  );
  final end = context.knobs.double.slider(
    label: 'Range End',
    initialValue: 0.8,
    min: 0.0,
    max: 1.0,
  );

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360.0),
        child: JustSlider.range(
          rangeValues: JustRangeValues(
            start < end ? start : end,
            end > start ? end : start,
          ),
          onRangeChanged: (val) {},
          showTooltip: true,
        ),
      ),
    ),
  );
}

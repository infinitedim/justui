// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/slider/just_slider.dart';

import '../scene.dart';

/// Part 26, slider: the volume control at 60%, like `KitPart` `slider`
/// (the React `KitSlider` default value). The 220 px cap is the demo's
/// `max-w-55`.
Widget sliderScene(BuildContext context, SceneContext scene) {
  return ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 220),
    child: _VolumeSlider(label: scene.strings.text('volume')),
  );
}

class _VolumeSlider extends StatefulWidget {
  const _VolumeSlider({required this.label});

  final String label;

  @override
  State<_VolumeSlider> createState() => _VolumeSliderState();
}

class _VolumeSliderState extends State<_VolumeSlider> {
  double _value = 60;

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle = context.justTypo.bodySm.copyWith(
      fontWeight: .w600,
      color: context.justColors.textPrimary,
    );
    final String percent = '${_value.round()}%';
    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .stretch,
      children: <Widget>[
        // Like the React demo, the visible percentage is not announced on
        // its own: the slider reports the value.
        ExcludeSemantics(
          child: Row(
            mainAxisAlignment: .spaceBetween,
            children: <Widget>[
              Text(widget.label, style: labelStyle),
              Text(
                percent,
                style: labelStyle.copyWith(
                  fontFeatures: const <FontFeature>[.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
        Semantics(
          label: widget.label,
          child: JustSlider(
            value: _value,
            min: 0,
            max: 100,
            onChanged: (double value) => setState(() => _value = value),
          ),
        ),
      ],
    );
  }
}

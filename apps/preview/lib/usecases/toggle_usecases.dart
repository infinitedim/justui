// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:just_ui_core/src/components/toggle/just_toggle.dart';
import 'package:just_ui_core/src/components/toggle/just_toggle_variants.dart';

@widgetbook.UseCase(name: 'Default Toggle', type: JustToggle)
Widget buildJustToggleDefaultUseCase(BuildContext context) {
  final size = context.knobs.object.dropdown<JustToggleSize>(
    label: 'Size',
    options: JustToggleSize.values,
    initialOption: JustToggleSize.md,
  );

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: _InteractiveToggleDemo(size: size),
    ),
  );
}

class _InteractiveToggleDemo extends StatefulWidget {
  final JustToggleSize size;

  const _InteractiveToggleDemo({required this.size});

  @override
  State<_InteractiveToggleDemo> createState() => _InteractiveToggleDemoState();
}

class _InteractiveToggleDemoState extends State<_InteractiveToggleDemo> {
  bool _selected = true;

  @override
  Widget build(BuildContext context) {
    return JustToggle(
      selected: _selected,
      onPressed: () {
        setState(() {
          _selected = !_selected;
        });
      },
      size: widget.size,
      child: Text(_selected ? 'Bold (On)' : 'Bold (Off)'),
    );
  }
}

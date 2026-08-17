// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:just_ui_core/src/components/select/just_select.dart';
import 'package:just_ui_core/src/components/select/just_select_variants.dart';

@widgetbook.UseCase(name: 'Default Select', type: JustSelect)
Widget buildJustSelectDefaultUseCase(BuildContext context) {
  final searchable = context.knobs.boolean(
    label: 'Searchable',
    initialValue: false,
  );
  final size = context.knobs.object.dropdown<JustSelectSize>(
    label: 'Size',
    options: JustSelectSize.values,
    initialOption: JustSelectSize.md,
  );

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340.0),
        child: _InteractiveSelectDemo(
          searchable: searchable,
          size: size,
        ),
      ),
    ),
  );
}

class _InteractiveSelectDemo extends StatefulWidget {
  final bool searchable;
  final JustSelectSize size;

  const _InteractiveSelectDemo({
    required this.searchable,
    required this.size,
  });

  @override
  State<_InteractiveSelectDemo> createState() => _InteractiveSelectDemoState();
}

class _InteractiveSelectDemoState extends State<_InteractiveSelectDemo> {
  String? _selectedValue = 'flutter';

  @override
  Widget build(BuildContext context) {
    return JustSelect<String>(
      value: _selectedValue,
      onChanged: (val) {
        setState(() {
          _selectedValue = val;
        });
      },
      searchable: widget.searchable,
      size: widget.size,
      label: 'Framework',
      options: const [
        JustSelectOption(value: 'flutter', label: 'Flutter'),
        JustSelectOption(value: 'react_native', label: 'React Native'),
        JustSelectOption.divider(),
        JustSelectOption(
          value: 'kotlin_multiplatform',
          label: 'Kotlin Multiplatform',
        ),
        JustSelectOption(value: 'swiftui', label: 'SwiftUI'),
      ],
    );
  }
}

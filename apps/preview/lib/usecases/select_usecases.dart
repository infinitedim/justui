// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:just_ui_core/src/components/select/just_select.dart';
import 'package:just_ui_core/src/components/select/just_select_variants.dart';

@widgetbook.UseCase(name: 'Default Select', type: JustSelect<String>)
Widget buildJustSelectDefaultUseCase(BuildContext context) {
  final bool searchable = context.knobs.boolean(
    label: 'Searchable',
    initialValue: false,
  );
  final JustSelectSize size = context.knobs.object.dropdown<JustSelectSize>(
    label: 'Size',
    options: JustSelectSize.values,
    initialOption: JustSelectSize.md,
  );

  return Center(
    child: Padding(
      padding: const .all(16.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340.0),
        child: _InteractiveSelectDemo(searchable: searchable, size: size),
      ),
    ),
  );
}

class _InteractiveSelectDemo extends StatefulWidget {
  final bool searchable;
  final JustSelectSize size;

  const _InteractiveSelectDemo({required this.searchable, required this.size});

  @override
  State<_InteractiveSelectDemo> createState() => _InteractiveSelectDemoState();
}

class _InteractiveSelectDemoState extends State<_InteractiveSelectDemo> {
  String? _selectedValue = 'flutter';

  @override
  Widget build(BuildContext context) {
    return JustSelect<String>(
      value: _selectedValue,
      onChanged: (String val) {
        setState(() {
          _selectedValue = val;
        });
      },
      searchable: widget.searchable,
      size: widget.size,
      label: 'Framework',
      options: const <JustSelectOption<String>>[
        JustSelectOption<String>(value: 'flutter', label: 'Flutter'),
        JustSelectOption<String>(value: 'react_native', label: 'React Native'),
        JustSelectOption<String>.divider(),
        JustSelectOption<String>(
          value: 'kotlin_multiplatform',
          label: 'Kotlin Multiplatform',
        ),
        JustSelectOption<String>(value: 'swiftui', label: 'SwiftUI'),
      ],
    );
  }
}

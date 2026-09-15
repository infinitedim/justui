// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:just_ui_core/src/components/table/just_table.dart';
import 'package:just_ui_core/src/components/table/just_table_variants.dart';

class _SampleRow {
  final String id;
  final String name;
  final String role;
  final String status;

  const _SampleRow(this.id, this.name, this.role, this.status);
}

@widgetbook.UseCase(name: 'Default Table', type: JustTable<_SampleRow>)
Widget buildJustTableDefaultUseCase(BuildContext context) {
  final bool selectable = context.knobs.boolean(
    label: 'Selectable',
    initialValue: true,
  );
  final JustTableVariant variant = context.knobs.object
      .dropdown<JustTableVariant>(
        label: 'Variant',
        options: JustTableVariant.values,
        initialOption: JustTableVariant.default_,
      );

  return Center(
    child: Padding(
      padding: const .all(16.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580.0, maxHeight: 360.0),
        child: _InteractiveTableDemo(selectable: selectable, variant: variant),
      ),
    ),
  );
}

class _InteractiveTableDemo extends StatefulWidget {
  final bool selectable;
  final JustTableVariant variant;

  const _InteractiveTableDemo({
    required this.selectable,
    required this.variant,
  });

  @override
  State<_InteractiveTableDemo> createState() => _InteractiveTableDemoState();
}

class _InteractiveTableDemoState extends State<_InteractiveTableDemo> {
  final Set<int> _selectedRows = <int>{};

  final List<_SampleRow> _rows = const <_SampleRow>[
    _SampleRow('101', 'Alice Vance', 'Lead Architect', 'Active'),
    _SampleRow('102', 'Bob Smith', 'Senior Developer', 'Active'),
    _SampleRow('103', 'Charlie Brown', 'UI Designer', 'Offline'),
  ];

  @override
  Widget build(BuildContext context) {
    return JustTable<_SampleRow>(
      selectable: widget.selectable,
      variant: widget.variant,
      selectedRows: _selectedRows,
      onSelectionChanged: (Set<int> selected) {
        setState(() {
          _selectedRows
            ..clear()
            ..addAll(selected);
        });
      },
      columns: <JustTableColumn<_SampleRow>>[
        JustTableColumn<_SampleRow>(
          header: 'ID',
          width: 80.0,
          cell: (_SampleRow row) => Text(row.id),
        ),
        JustTableColumn<_SampleRow>(
          header: 'Name',
          cell: (_SampleRow row) => Text(row.name),
        ),
        JustTableColumn<_SampleRow>(
          header: 'Role',
          cell: (_SampleRow row) => Text(row.role),
        ),
        JustTableColumn<_SampleRow>(
          header: 'Status',
          width: 100.0,
          cell: (_SampleRow row) => Text(row.status),
        ),
      ],
      rows: _rows,
    );
  }
}

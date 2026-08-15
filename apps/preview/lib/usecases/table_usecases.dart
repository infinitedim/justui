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

@widgetbook.UseCase(name: 'Default Table', type: JustTable)
Widget buildJustTableDefaultUseCase(BuildContext context) {
  final selectable = context.knobs.boolean(
    label: 'Selectable',
    initialValue: true,
  );
  final variant = context.knobs.object.dropdown<JustTableVariant>(
    label: 'Variant',
    options: JustTableVariant.values,
    initialOption: JustTableVariant.default_,
  );

  return SizedBox(
    width: 500.0,
    height: 300.0,
    child: JustTable<_SampleRow>(
      selectable: selectable,
      variant: variant,
      columns: [
        JustTableColumn(header: 'ID', width: 80.0, cell: (row) => Text(row.id)),
        JustTableColumn(header: 'Name', cell: (row) => Text(row.name)),
        JustTableColumn(header: 'Role', cell: (row) => Text(row.role)),
        JustTableColumn(
          header: 'Status',
          width: 100.0,
          cell: (row) => Text(row.status),
        ),
      ],
      rows: const [
        _SampleRow('101', 'Alice Vance', 'Lead Architect', 'Active'),
        _SampleRow('102', 'Bob Smith', 'Senior Developer', 'Active'),
        _SampleRow('103', 'Charlie Brown', 'UI Designer', 'Offline'),
      ],
    ),
  );
}

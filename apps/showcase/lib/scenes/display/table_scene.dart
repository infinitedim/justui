// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/src/components/table/just_table.dart';

import '../../theme/ink_paper_theme.dart';
import '../scene.dart';

/// Part 28, table: two columns, two rows of part folders, like `KitPart`
/// `table` (`max-w-62.5`).
///
/// The React table has no tab stops. Core makes every row a focusable
/// pressable even when rows are not selectable, which would add stops with
/// no action and no visible focus, so the table is kept out of focus
/// traversal.
Widget tableScene(BuildContext context, SceneContext scene) {
  const TextStyle mono = TextStyle(
    fontFamily: InkPaperTheme.monoFontFamily,
    fontSize: 12,
  );
  return ExcludeFocus(
    child: JustTable<List<String>>(
      stickyHeader: false,
      rowHeight: 34,
      variant: .minimal,
      columns: <JustTableColumn<List<String>>>[
        JustTableColumn<List<String>>(
          header: scene.strings.text('part'),
          width: 80,
          cell: (List<String> row) => Text(row[0], style: mono),
        ),
        JustTableColumn<List<String>>(
          header: scene.strings.text('folder'),
          width: 170,
          cell: (List<String> row) => Text(row[1], style: mono),
        ),
      ],
      rows: const <List<String>>[
        <String>['button', 'lib/widgets/button'],
        <String>['card', 'lib/widgets/card'],
      ],
    ),
  );
}

// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:just_ui_core/src/components/sheet/just_sheet.dart';
import 'package:just_ui_core/src/components/sheet/just_sheet_variants.dart';
import 'package:just_ui_core/src/components/button/just_button.dart';

final JustSheetController _sheetController = JustSheetController();

@widgetbook.UseCase(name: 'Bottom Sheet Trigger', type: JustSheetScope)
Widget buildJustSheetDefaultUseCase(BuildContext context) {
  final direction = context.knobs.object.dropdown<SheetDirection>(
    label: 'Direction',
    options: SheetDirection.values,
    initialOption: SheetDirection.bottom,
  );

  return JustSheetScope(
    controller: _sheetController,
    child: Builder(
      builder: (scopeContext) {
        return Center(
          child: JustButton.primary(
            label: 'Open ${direction.name} Sheet',
            onPressed: () {
              scopeContext.justSheet.show<void>(
                direction: direction,
                draggable: true,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sheet Header',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    const Text(
                      'This is a slide-in sheet overlay supporting drag to dismiss, keyboard navigation, and theme presets.',
                    ),
                    const Spacer(),
                    JustButton.primary(
                      label: 'Close Sheet',
                      isFullWidth: true,
                      onPressed: () => scopeContext.justSheet.dismiss(),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    ),
  );
}

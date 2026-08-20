// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:just_ui_core/src/components/dialog/just_dialog.dart';
import 'package:just_ui_core/src/components/button/just_button.dart';

final JustDialogController _dialogController = JustDialogController();

@widgetbook.UseCase(name: 'Modal Dialog Trigger', type: JustDialogScope)
Widget buildJustDialogDefaultUseCase(BuildContext context) {
  return JustDialogScope(
    controller: _dialogController,
    child: Builder(
      builder: (scopeContext) {
        return Center(
          child: JustButton.primary(
            label: 'Show Modal Dialog',
            onPressed: () {
              scopeContext.justDialog.show<void>(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Confirm Action',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    const Text(
                      'Are you sure you want to proceed with this operation? This action cannot be undone.',
                    ),
                    const SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        JustButton.secondary(
                          label: 'Cancel',
                          onPressed: () => scopeContext.justDialog.dismiss(),
                        ),
                        const SizedBox(width: 8.0),
                        JustButton.primary(
                          label: 'Confirm',
                          onPressed: () => scopeContext.justDialog.dismiss(),
                        ),
                      ],
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

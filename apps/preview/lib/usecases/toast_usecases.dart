// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:just_ui_core/src/components/toast/just_toast.dart';
import 'package:just_ui_core/src/components/toast/just_toast_variants.dart';
import 'package:just_ui_core/src/components/button/just_button.dart';

final JustToastController _toastController = JustToastController();

@widgetbook.UseCase(name: 'Toast Notification Trigger', type: JustToastScope)
Widget buildJustToastDefaultUseCase(BuildContext context) {
  final variant = context.knobs.object.dropdown<ToastVariant>(
    label: 'Variant',
    options: ToastVariant.values,
    initialOption: ToastVariant.success,
  );
  final message = context.knobs.string(
    label: 'Message',
    initialValue: 'Changes saved successfully!',
  );

  return JustToastScope(
    controller: _toastController,
    child: Builder(
      builder: (scopeContext) {
        return Center(
          child: JustButton.primary(
            label: 'Trigger ${variant.name} Toast',
            onPressed: () {
              scopeContext.justToast.show(message: message, variant: variant);
            },
          ),
        );
      },
    ),
  );
}

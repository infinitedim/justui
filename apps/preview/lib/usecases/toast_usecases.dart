// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:just_ui_core/src/components/toast/just_toast.dart';
import 'package:just_ui_core/src/components/toast/just_toast_variants.dart';
import 'package:just_ui_core/src/components/button/just_button.dart';

@widgetbook.UseCase(name: 'Toast Notification Trigger', type: JustToastScope)
Widget buildJustToastDefaultUseCase(BuildContext context) {
  final ToastVariant variant = context.knobs.object.dropdown<ToastVariant>(
    label: 'Variant',
    options: ToastVariant.values,
    initialOption: ToastVariant.success,
  );
  final String message = context.knobs.string(
    label: 'Message',
    initialValue: 'Changes saved successfully!',
  );
  final int limit = context.knobs.int.slider(
    label: 'Max Toast Limit',
    initialValue: 3,
    min: 1,
    max: 10,
  );
  final ToastBehavior behavior = context.knobs.object.dropdown<ToastBehavior>(
    label: 'Behavior',
    options: ToastBehavior.values,
    initialOption: ToastBehavior.stacked,
  );
  final ToastPosition position = context.knobs.object.dropdown<ToastPosition>(
    label: 'Position',
    options: ToastPosition.values,
    initialOption: ToastPosition.bottomCenter,
  );

  return _ToastDemoView(
    variant: variant,
    message: message,
    limit: limit,
    behavior: behavior,
    position: position,
  );
}

class _ToastDemoView extends StatelessWidget {
  final ToastVariant variant;
  final String message;
  final int limit;
  final ToastBehavior behavior;
  final ToastPosition position;

  const _ToastDemoView({
    required this.variant,
    required this.message,
    required this.limit,
    required this.behavior,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return JustToastScope(
      key: ValueKey<String>(
        'toast_scope_${limit}_${behavior.name}_${position.name}',
      ),
      limit: limit,
      behavior: behavior,
      position: position,
      child: Builder(
        builder: (BuildContext scopeContext) {
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
}

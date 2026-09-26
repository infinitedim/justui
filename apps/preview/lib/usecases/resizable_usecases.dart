// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/resizable/just_resizable.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Two Panels', type: JustResizable)
Widget buildJustResizableTwoPanelsUseCase(BuildContext context) {
  final bool vertical = context.knobs.boolean(
    label: 'Vertical',
    initialValue: false,
  );
  final JustResizableHandleVariant handle = context.knobs.object
      .dropdown<JustResizableHandleVariant>(
        label: 'Handle',
        options: JustResizableHandleVariant.values,
        initialOption: JustResizableHandleVariant.grip,
      );

  return ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 560.0, maxHeight: 320.0),
    child: JustResizable(
      direction: vertical ? .vertical : .horizontal,
      handleVariant: handle,
      children: const <JustResizablePanel>[
        JustResizablePanel(
          initialSize: 0.35,
          minSize: 0.2,
          child: _PanelLabel(label: 'Sidebar'),
        ),
        JustResizablePanel(
          initialSize: 0.65,
          child: _PanelLabel(label: 'Content'),
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(name: 'Collapsible Panels', type: JustResizable)
Widget buildJustResizableCollapsibleUseCase(BuildContext context) {
  return ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 640.0, maxHeight: 320.0),
    child: const JustResizable(
      doubleTapBehavior: .collapse,
      children: <JustResizablePanel>[
        JustResizablePanel(
          initialSize: 0.25,
          collapsible: true,
          child: _PanelLabel(label: 'Navigation'),
        ),
        JustResizablePanel(
          initialSize: 0.5,
          child: _PanelLabel(label: 'Editor'),
        ),
        JustResizablePanel(
          initialSize: 0.25,
          collapsible: true,
          snapPoints: <double>[0.25, 0.4],
          child: _PanelLabel(label: 'Inspector'),
        ),
      ],
    ),
  );
}

class _PanelLabel extends StatelessWidget {
  final String label;

  const _PanelLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final JustColorScheme colors = context.justColors;
    return ColoredBox(
      color: colors.card,
      child: Center(
        child: Text(
          label,
          style: context.justTypo.bodyMd.copyWith(color: colors.textSecondary),
        ),
      ),
    );
  }
}

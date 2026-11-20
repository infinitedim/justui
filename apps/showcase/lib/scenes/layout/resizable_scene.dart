// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/resizable/just_resizable.dart';

import '../scene.dart';
import 'control_box.dart';

/// Part resizable: Files and Editor panes split 40 / 60, like `KitPart`
/// `resizable`.
///
/// Uses core's `grip` handle variant (centered pill with dots) and a 24 px
/// interactive hit target to meet WCAG 2.2 AA target-size minimums while
/// matching the visual look of the React fallback.
Widget resizableScene(BuildContext context, SceneContext scene) {
  final JustColorScheme colors = context.justColors;
  final TextStyle label = context.justTypo.caption.copyWith(
    color: colors.textSecondary,
    fontWeight: .w600,
  );
  return ControlBox(
    // w-55 h-18 of the docs demo.
    width: 220,
    height: 72,
    child: JustResizable(
      handleVariant: .grip,
      handleHitSize: 24.0,
      splitterSemanticsLabel: scene.strings.text('splitterLabel'),
      children: <JustResizablePanel>[
        JustResizablePanel(
          initialSize: 0.4,
          child: _Pane(
            color: colors.card,
            child: Text(scene.strings.text('files'), style: label),
          ),
        ),
        JustResizablePanel(
          initialSize: 0.6,
          child: _Pane(
            color: colors.muted,
            child: Text(scene.strings.text('editor'), style: label),
          ),
        ),
      ],
    ),
  );
}

/// One pane: a fill with its label centered.
class const _Pane({required final Color color, required final Widget child})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: color,
    child: Center(child: child),
  );
}

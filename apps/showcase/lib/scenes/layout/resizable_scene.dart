// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/resizable/just_resizable.dart';

import '../scene.dart';
import 'control_box.dart';

/// Part resizable: Files and Editor panes split 40 / 60, like `KitPart`
/// `resizable`.
///
/// The split starts fixed so the golden is stable; the handle stays a real
/// core splitter (focusable, arrow keys resize, Enter toggles). It uses
/// core's default line handle: core's grip variant is laid out inside the
/// divider's own width and does not show.
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

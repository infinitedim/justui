// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/scroll/just_scroll_area.dart';

import '../../theme/ink_paper_theme.dart';
import '../scene.dart';
import 'control_box.dart';

const List<String> _componentPaths = <String>[
  'lib/widgets/button/',
  'lib/widgets/card/',
  'lib/widgets/input/',
  'lib/widgets/select/',
  'lib/widgets/dialog/',
  'lib/widgets/toast/',
];

/// Part scroll-area: 210 x 86 bordered viewport of six monospace component
/// paths with an always-visible scrollbar, like `KitPart` `scroll-area`.
Widget scrollAreaScene(BuildContext context, SceneContext scene) {
  final JustColorScheme colors = context.justColors;
  final double borderWidth = context.justPresetTokens.borderWidth;
  final TextStyle pathStyle = TextStyle(
    fontFamily: InkPaperTheme.monoFontFamily,
    fontSize: 12,
    height: 22 / 12,
    color: colors.textSecondary,
  );

  // Layer ControlBox behind JustScrollArea in an unclipped Stack so
  // JustScrollArea's outer focus indicator is never clipped by ControlBox.
  return SizedBox(
    width: 210,
    height: 86,
    child: Stack(
      clipBehavior: .none,
      children: <Widget>[
        const Positioned.fill(
          child: IgnorePointer(child: ControlBox(child: SizedBox.expand())),
        ),
        Positioned.fill(
          child: Padding(
            padding: .all(borderWidth),
            child: JustScrollArea(
              semanticsLabel: scene.strings.text('scrollAreaLabel'),
              thumbVisibility: true,
              trackVisibility: true,
              child: Padding(
                padding: const .fromLTRB(12, 8, 22, 8),
                child: Column(
                  mainAxisSize: .min,
                  crossAxisAlignment: .start,
                  children: <Widget>[
                    for (final String path in _componentPaths)
                      Text(path, style: pathStyle, maxLines: 1),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/bottom_nav/just_bottom_nav.dart';

import '../scene.dart';

/// Part 21, bottom-nav: three destinations with the first current, like
/// `KitPart` `bottom-nav` (`KitBottomNav`, `max-w-62.5` = 250 px).
///
/// The React demo has no icons, only an ink indicator bar on the current
/// item, so the icon slot holds that bar (shown for the active item only).
Widget bottomNavScene(BuildContext context, SceneContext scene) {
  return Semantics(
    label: scene.strings.text('bottomNavLabel'),
    container: true,
    explicitChildNodes: true,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 250),
      child: _BottomNav(items: scene.strings.list('bottomNav')),
    ),
  );
}

/// Holds the current destination; core's bottom nav is controlled.
class const _BottomNav({required final List<String> items})
    extends StatefulWidget {
  @override
  State<_BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<_BottomNav> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    // A 2 px rounded bar like the tabs indicator; neobrutalism uses the
    // React `neo:h-1 neo:rounded-none` (4 px, square).
    final bool neo = context.justPreset == .neobrutalism;
    final Size bar = Size(20, neo ? 4 : 2);
    return JustBottomNav(
      selectedIndex: _current,
      onItemSelected: (int index) => setState(() => _current = index),
      hapticFeedback: false,
      items: <JustBottomNavItem>[
        for (final String item in widget.items)
          JustBottomNavItem(
            label: item,
            icon: SizedBox.fromSize(size: bar),
            activeIcon: _IndicatorBar(size: bar, square: neo),
          ),
      ],
    );
  }
}

/// The ink bar under the current item, in the nav's active icon color.
class const _IndicatorBar({
  required final Size size,
  required final bool square,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: IconTheme.of(context).color,
        borderRadius: square ? null : .circular(size.height / 2),
      ),
    );
  }
}

// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/src/components/tabs/just_tabs.dart';

import '../scene.dart';

/// Part tabs: underlined tab bar (`Account`, `Billing`, `Team`), like
/// `KitPart` `tabs` (`KitTabs`).
Widget tabsScene(BuildContext context, SceneContext scene) =>
    _TabsDemo(scene: scene);

class const _TabsDemo({required final SceneContext scene})
    extends StatefulWidget {
  @override
  State<_TabsDemo> createState() => _TabsDemoState();
}

class _TabsDemoState extends State<_TabsDemo> {
  late JustTabController _controller;

  List<String> get _labels {
    final List<String> raw = widget.scene.strings.list('tabs');
    return raw.isEmpty ? const <String>['Account', 'Billing', 'Team'] : raw;
  }

  @override
  void initState() {
    super.initState();
    _controller = JustTabController(length: _labels.length, initialIndex: 0);
  }

  @override
  void didUpdateWidget(covariant _TabsDemo oldWidget) {
    super.didUpdateWidget(oldWidget);
    final int nextLength = _labels.length;
    if (nextLength != _controller.length) {
      final int clamped = _controller.index.clamp(0, nextLength - 1);
      _controller.dispose();
      _controller = JustTabController(
        length: nextLength,
        initialIndex: clamped,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<JustTab> tabs = <JustTab>[
      for (final String label in _labels)
        JustTab(label: label, content: const SizedBox.shrink()),
    ];
    // Column(mainAxisSize: .min) gives JustTabs unbounded vertical constraints
    // so its internal Center shrink-wraps to the tab bar height instead of
    // stretching to the viewport height.
    return SizedBox(
      width: 240,
      child: Column(
        mainAxisSize: .min,
        children: <Widget>[
          JustTabs(
            controller: _controller,
            variant: .line,
            showContent: false,
            semanticsLabel: widget.scene.strings.text('tabsLabel'),
            tabs: tabs,
          ),
        ],
      ),
    );
  }
}

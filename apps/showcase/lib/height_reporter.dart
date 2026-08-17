import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

class HeightReporter extends StatefulWidget {
  final Widget child;
  const HeightReporter({super.key, required this.child});

  @override
  State<HeightReporter> createState() => _HeightReporterState();
}

class _HeightReporterState extends State<HeightReporter> {
  final GlobalKey _key = GlobalKey();
  Timer? _debounce;
  double _lastReportedHeight = 0;

  void _reportHeight() {
    if (!mounted) return;
    final renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final height = renderBox.size.height;
    if (height == _lastReportedHeight || height <= 0) return;

    _lastReportedHeight = height;
    web.window.parent?.postMessage(
      {'type': 'justui-showcase-height', 'height': height}.jsify()!,
      '*'.toJS,
    );
  }

  void _scheduleReport() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 50), _reportHeight);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportHeight());
  }

  @override
  void didUpdateWidget(covariant HeightReporter oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleReport();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleReport());
    return KeyedSubtree(key: _key, child: widget.child);
  }
}

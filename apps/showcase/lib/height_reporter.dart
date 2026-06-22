import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class HeightReporter extends StatefulWidget {
  final Widget child;
  const HeightReporter({super.key, required this.child});

  @override
  State<HeightReporter> createState() => _HeightReporterState();
}

class _HeightReporterState extends State<HeightReporter> {
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportHeight());
  }

  void _reportHeight() {
    final context = _key.currentContext;
    if (context != null) {
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final height = renderBox.size.height;
        // Kirim tinggi widget ke Next.js parent
        web.window.parent?.postMessage(
          '{"type": "RESIZE_IFRAME", "height": $height}'.toJS,
          '*'.toJS, // Pada produksi, ganti dengan target origin domain spesifik
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(key: _key, child: widget.child);
  }
}

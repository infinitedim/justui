import 'dart:js_interop';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:just_ui_core/just_ui_core.dart';
import 'package:web/web.dart' as web;
import 'widgets/showcase_grid.dart';
import 'height_reporter.dart';

@JS()
extension type MessagePayload(JSObject _) implements JSObject {
  external String? get type;
  external String? get preset;
  external String? get mode;
}

void main() {
  runApp(const ShowcaseApp());
}

class ShowcaseApp extends StatefulWidget {
  const ShowcaseApp({super.key});

  @override
  State<ShowcaseApp> createState() => _ShowcaseAppState();
}

class _ShowcaseAppState extends State<ShowcaseApp> {
  JustThemePreset _preset = JustThemePreset.neobrutalism;
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    web.window.addEventListener('message', _handleParentMessage.toJS);
  }

  void _handleParentMessage(web.Event event) {
    if (!event.isA<web.MessageEvent>()) return;
    final messageEvent = event as web.MessageEvent;
    final data = messageEvent.data;
    if (data == null) return;
    try {
      if (data.isA<JSObject>()) {
        final payload = MessagePayload(data as JSObject);
        if (payload.type == 'justui-theme') {
          final isDark = payload.mode == 'dark';
          final isNeobrutalism = payload.preset == 'neobrutalism';

          setState(() {
            _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
            _preset = isNeobrutalism
                ? JustThemePreset.neobrutalism
                : JustThemePreset.default_;
          });
        }
      }
    } catch (e) {
      // ignore silently
    }
  }

  @override
  Widget build(BuildContext context) {
    final lightTheme = _preset == JustThemePreset.neobrutalism
        ? JustThemeData.neobrutalismLight
        : JustThemeData.light;
    final darkTheme = _preset == JustThemePreset.neobrutalism
        ? JustThemeData.neobrutalismDark
        : JustThemeData.dark;

    return JustThemeProvider(
      key: ValueKey('${_preset.name}-${_themeMode.name}'),
      lightTheme: lightTheme,
      darkTheme: darkTheme,
      initialThemeMode: _themeMode,
      child: const HeightReporter(child: ShowcaseGrid()),
    );
  }
}

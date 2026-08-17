import 'dart:js_interop';

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart'
    show MaterialApp, Scaffold, ThemeData, ThemeMode, ColorScheme;
import 'package:just_ui_core/just_ui_core.dart';
import 'package:web/web.dart' as web;

import 'widgets/showcase_marquee.dart';
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

final class _ShowcaseTypographyScheme extends JustTypographyScheme {
  const _ShowcaseTypographyScheme();

  static const String _font = 'IBM Plex Sans';

  @override
  TextStyle get displayLg => JustTypo.displayLg.copyWith(fontFamily: _font);
  @override
  TextStyle get displayMd => JustTypo.displayMd.copyWith(fontFamily: _font);
  @override
  TextStyle get displaySm => JustTypo.displaySm.copyWith(fontFamily: _font);
  @override
  TextStyle get headingLg => JustTypo.headingLg.copyWith(fontFamily: _font);
  @override
  TextStyle get headingMd => JustTypo.headingMd.copyWith(fontFamily: _font);
  @override
  TextStyle get headingSm => JustTypo.headingSm.copyWith(fontFamily: _font);
  @override
  TextStyle get bodyLg => JustTypo.bodyLg.copyWith(fontFamily: _font);
  @override
  TextStyle get bodyMd => JustTypo.bodyMd.copyWith(fontFamily: _font);
  @override
  TextStyle get bodySm => JustTypo.bodySm.copyWith(fontFamily: _font);
  @override
  TextStyle get caption => JustTypo.caption.copyWith(fontFamily: _font);
  @override
  TextStyle get overline => JustTypo.overline.copyWith(fontFamily: _font);
}

class ShowcaseApp extends StatefulWidget {
  const ShowcaseApp({super.key});

  @override
  State<ShowcaseApp> createState() => _ShowcaseAppState();
}

class _ShowcaseAppState extends State<ShowcaseApp> {
  JustThemePreset _preset = .default_;
  ThemeMode _themeMode = .light;

  @override
  void initState() {
    super.initState();
    web.window.addEventListener('message', _handleParentMessage.toJS);
    web.window.parent?.postMessage({'type': 'justui-ready'}.jsify()!, '*'.toJS);
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
            _themeMode = isDark ? .dark : .light;
            _preset = isNeobrutalism ? .neobrutalism : .default_;
          });
        }
      }
    } catch (e) {
      // ignore silently
    }
  }

  @override
  Widget build(BuildContext context) {
    final lightTheme =
        (_preset == .neobrutalism
                ? JustThemeData.neobrutalismLight
                : JustThemeData.light)
            .copyWith(typography: const _ShowcaseTypographyScheme());

    final darkTheme =
        (_preset == .neobrutalism
                ? JustThemeData.neobrutalismDark
                : JustThemeData.dark)
            .copyWith(typography: const _ShowcaseTypographyScheme());

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: const Color(0x00000000),
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0x00000000),
        colorScheme: const ColorScheme.light(surface: Color(0x00000000)),
      ),
      home: Scaffold(
        body: JustThemeProvider(
          key: ValueKey('${_preset.name}-${_themeMode.name}'),
          lightTheme: lightTheme,
          darkTheme: darkTheme,
          initialThemeMode: _themeMode,
          child: Builder(
            builder: (context) {
              final theme = JustThemeProvider.of(context).theme;
              return SizedBox(
                height: 180.0,
                child: DefaultTextStyle(
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans',
                    color: theme.colors.textPrimary,
                  ),
                  child: const HeightReporter(child: ShowcaseMarquee()),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

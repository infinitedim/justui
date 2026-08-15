import 'package:flutter/material.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'main.directories.g.dart';

void main() {
  runApp(const WidgetbookApp());
}

@widgetbook.App()
class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: directories,
      addons: [
        ThemeAddon<JustThemeData>(
          themes: [
            WidgetbookTheme(name: 'Light', data: .light),
            WidgetbookTheme(name: 'Dark', data: .dark),
            WidgetbookTheme(
              name: 'Neobrutalism Light',
              data: .neobrutalismLight,
            ),
            WidgetbookTheme(name: 'Neobrutalism Dark', data: .neobrutalismDark),
          ],
          themeBuilder: (context, theme, child) {
            return JustThemeProvider(
              lightTheme: theme,
              darkTheme: theme,
              initialThemeMode: .light,
              child: ColoredBox(
                color: theme.colors.background,
                child: Center(
                  child: Padding(padding: const .all(16.0), child: child),
                ),
              ),
            );
          },
        ),
        AlignmentAddon(initialAlignment: .center),
        ViewportAddon([IosViewports.iPhone13, MacosViewports.macbookPro]),
      ],
    );
  }
}

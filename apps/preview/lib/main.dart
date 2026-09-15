// ignore_for_file: implementation_imports
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
      addons: <WidgetbookAddon<dynamic>>[
        ThemeAddon<JustThemeData>(
          themes: <WidgetbookTheme<JustThemeData>>[
            WidgetbookTheme<JustThemeData>(name: 'Light', data: .light),
            WidgetbookTheme<JustThemeData>(name: 'Dark', data: .dark),
            WidgetbookTheme<JustThemeData>(
              name: 'Neobrutalism Light',
              data: .neobrutalismLight,
            ),
            WidgetbookTheme<JustThemeData>(
              name: 'Neobrutalism Dark',
              data: .neobrutalismDark,
            ),
          ],
          themeBuilder:
              (BuildContext context, JustThemeData theme, Widget child) {
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
        ViewportAddon(<ViewportData>[
          IosViewports.iPhone13,
          MacosViewports.macbookPro,
        ]),
      ],
    );
  }
}

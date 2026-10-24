import 'dart:io';

import 'package:flutter/material.dart' show ThemeExtension;
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:showcase/theme/ink_paper_extensions.dart';
import 'package:showcase/theme/ink_paper_theme.dart';

/// Theme extension classes declared by core (`just_<name>_theme.dart`).
Set<String> coreThemeClasses() {
  final RegExp decl = RegExp(r'class const (Just\w+Theme)\(');
  return Directory('../../packages/core/lib/src/components')
      .listSync(recursive: true)
      .whereType<File>()
      .where((File f) => RegExp(r'just_\w+_theme\.dart$').hasMatch(f.path))
      .expand((File f) => decl.allMatches(f.readAsStringSync()))
      .map((RegExpMatch m) => m.group(1)!)
      .toSet();
}

void main() {
  test('the bridge registers every core component theme once', () {
    for (final JustThemePreset preset in JustThemePreset.values) {
      final List<ThemeExtension<dynamic>> extensions = inkPaperExtensions(
        preset,
        InkPaperTheme.roles(.light),
      );
      final List<String> names = extensions
          .map((ThemeExtension<dynamic> e) => e.runtimeType.toString())
          .toList();
      expect(names.toSet().length, names.length, reason: 'duplicate extension');
      expect(names.toSet(), coreThemeClasses());
    }
  });
}

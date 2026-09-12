import 'package:flutter/material.dart' show Color;
import '../just_ui_core.dart';

/// Dynamically generated light theme from brand seed color.
final JustThemeData justThemeLight = JustThemeData.fromSeed(
const Color(0xFFA3E635),
isDark: false,
  preset: JustThemePreset.neobrutalism,
  colorSpace: JustColorSpaceEngine.oklch,
);

/// Dynamically generated dark theme from brand seed color.
final JustThemeData justThemeDark = JustThemeData.fromSeed(
const Color(0xFFA3E635),
isDark: true,
  preset: JustThemePreset.neobrutalism,
  colorSpace: JustColorSpaceEngine.oklch,
);

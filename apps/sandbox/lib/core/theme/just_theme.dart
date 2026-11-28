import 'package:flutter/widgets.dart' show Color;

import '../just_ui_core.dart' show JustThemeData;

/// Dynamically generated light theme from brand seed color.
final JustThemeData justThemeLight = .fromSeed(
  const Color(0xFF3B82F6),
  isDark: false,
  preset: .neobrutalism,
  colorSpace: .oklch,
);

/// Dynamically generated dark theme from brand seed color.
final JustThemeData justThemeDark = .fromSeed(
  const Color(0xFF3B82F6),
  isDark: true,
  preset: .neobrutalism,
  colorSpace: .oklch,
);

/// Default bootstrap theme matching configuration.
final JustThemeData justTheme = justThemeLight;

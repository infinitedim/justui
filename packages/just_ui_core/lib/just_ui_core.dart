import 'package:flutter/widgets.dart';
import 'package:just_ui_tokens/just_ui_tokens.dart';
import 'src/theme/theme_data.dart';
import 'src/theme/theme_provider.dart';

export 'src/theme/theme_aspects.dart';
export 'src/theme/theme_data.dart';
export 'src/theme/theme_provider.dart';
export 'src/components/components.dart';

/// Extension methods on [BuildContext] to simplify access to JustUI themes.
extension JustThemeContext on BuildContext {
  /// Retrieves the active [JustThemeData] configuration and subscribes the context
  /// to rebuild on any theme updates.
  JustThemeData get justTheme => JustThemeProvider.of(this).theme;

  /// Retrieves the active [JustColorScheme] and subscribes the context
  /// to rebuild *only* when the color aspect changes.
  ///
  /// This optimizes rendering performance in  large widget trees by avoiding rebuilds
  /// when other static aspects (e.g. spacing, typography) are modified.
  JustColorScheme get justColors =>
      JustThemeProvider.of(this, aspect: .colors).theme.colors;

  /// Retrieves the active [JustTypographyScheme] and subscribes the context
  /// to rebuild *only* when the typography aspect changes.
  JustTypographyScheme get justTypo =>
      JustThemeProvider.of(this, aspect: .typography).theme.typography;

  /// Retrieves the active [JustSpacingScheme] and subscribes the context
  /// to rebuild *only* when the spacing aspect changes.
  JustSpacingScheme get justSpacing =>
      JustThemeProvider.of(this, aspect: .spacing).theme.spacing;

  /// Reads the active theme configuration without registering a rebuild dependency.
  ///
  /// Ideal for use within callbacks or static configurations.
  JustThemeData readTheme() => JustThemeProvider.read(this).theme;
}

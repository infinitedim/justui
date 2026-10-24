import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/widgets.dart';
import 'package:sandbox/tokens/just_ui_tokens.dart';

import 'preset_tokens.dart';
import 'theme_aspects.dart';
export 'theme_aspects.dart';
import 'theme_data.dart';

/// A stateful provider that manages the theme mode and active theme data for JustUI.
///
/// Under the hood, it propagates the active theme down the tree using an [InheritedModel],
/// enabling widgets to subscribe to specific theme components (aspects) for optimal rendering performance.
class JustThemeProvider extends StatefulWidget {
  final Widget child;
  final void Function(ThemeMode)? onThemeChanged;
  final ThemeMode? initialThemeMode;
  final JustThemeData? lightTheme;
  final JustThemeData? darkTheme;
  final Duration transitionDuration;
  final Curve transitionCurve;

  const JustThemeProvider({
    super.key,
    required this.child,
    this.onThemeChanged,
    this.initialThemeMode,
    this.lightTheme,
    this.darkTheme,
    this.transitionDuration = JustDuration.normal,
    this.transitionCurve = JustCurves.default_,
  });

  @override
  State<JustThemeProvider> createState() => JustThemeProviderState();

  /// Retrieves the active state of this provider, or null if not found in the widget tree.
  static JustThemeProviderState? maybeOf(
    BuildContext context, {
    JustThemeAspect? aspect,
  }) {
    final _JustThemeModel? model = InheritedModel.inheritFrom<_JustThemeModel>(
      context,
      aspect: aspect,
    );
    return model?.state;
  }

  /// Retrieves the active state of this provider and registers a rebuild dependency on the context.
  ///
  /// Specify an [aspect] (e.g., [JustThemeAspect.colors]) to restrict rebuilds to changes in that component only.
  static JustThemeProviderState of(
    BuildContext context, {
    JustThemeAspect? aspect,
  }) {
    final JustThemeProviderState? state = maybeOf(context, aspect: aspect);
    if (state == null) {
      throw FlutterError('JustThemeProvider was not found in the widget tree.');
    }
    return state;
  }

  /// Retrieves the active state without registering a rebuild dependency, or null if not found.
  static JustThemeProviderState? maybeRead(BuildContext context) {
    final InheritedElement? element = context
        .getElementForInheritedWidgetOfExactType<_JustThemeModel>();
    return (element?.widget as _JustThemeModel?)?.state;
  }

  /// Retrieves the active state without registering a rebuild dependency.
  ///
  /// Ideal for callbacks, event handlers, or initialization.
  static JustThemeProviderState read(BuildContext context) {
    final JustThemeProviderState? state = maybeRead(context);
    if (state == null) {
      throw FlutterError('JustThemeProvider was not found in the widget tree.');
    }
    return state;
  }
}

/// The active state of [JustThemeProvider].
class JustThemeProviderState extends State<JustThemeProvider>
    with WidgetsBindingObserver {
  late ThemeMode _themeMode;
  late JustThemeData _lightTheme;
  late JustThemeData _darkTheme;

  /// Retrieves the active theme mode.
  ThemeMode get themeMode => _themeMode;

  /// The transition duration used when switching themes.
  Duration get transitionDuration => widget.transitionDuration;

  /// The easing curve used when switching themes.
  Curve get transitionCurve => widget.transitionCurve;

  JustThemeData? _cachedResolvedTheme;
  double? _cachedWidth;
  bool? _cachedHighContrast;
  Brightness? _cachedPlatformBrightness;

  void _invalidateThemeCache() {
    _cachedResolvedTheme = null;
  }

  JustThemeData _computeResolvedTheme() {
    final JustThemeData baseTheme;
    switch (_themeMode) {
      case .light:
        baseTheme = _lightTheme;
        break;
      case .dark:
        baseTheme = _darkTheme;
        break;
      case .system:
        final Brightness brightness =
            WidgetsBinding.instance.platformDispatcher.platformBrightness;
        baseTheme = brightness == .dark ? _darkTheme : _lightTheme;
        break;
    }

    final bool isHighContrast =
        WidgetsBinding
            .instance
            .platformDispatcher
            .accessibilityFeatures
            .highContrast ||
        (MediaQuery.maybeHighContrastOf(context) ?? false);

    final JustThemeData resolvedTheme = isHighContrast
        ? baseTheme.applyHighContrastOverrides()
        : baseTheme;

    final double width = MediaQuery.maybeSizeOf(context)?.width ?? 1024.0;
    final JustMotionProfile resolvedAnimations = resolvedTheme.animations
        .resolve(context);

    return resolvedTheme.copyWith(
      spacing: resolvedTheme.spacing.resolve(width),
      radius: resolvedTheme.radius.resolve(width),
      animations: resolvedAnimations,
    );
  }

  /// Retrieves the active resolved [JustThemeData] based on [themeMode] and system brightness.
  JustThemeData get theme {
    final double width = MediaQuery.maybeSizeOf(context)?.width ?? 1024.0;
    final bool isHighContrast =
        WidgetsBinding
            .instance
            .platformDispatcher
            .accessibilityFeatures
            .highContrast ||
        (MediaQuery.maybeHighContrastOf(context) ?? false);
    final Brightness brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;

    if (_cachedResolvedTheme != null &&
        _cachedWidth == width &&
        _cachedHighContrast == isHighContrast &&
        _cachedPlatformBrightness == brightness) {
      return _cachedResolvedTheme!;
    }

    final JustThemeData newTheme = _computeResolvedTheme();
    _cachedResolvedTheme = newTheme;
    _cachedWidth = width;
    _cachedHighContrast = isHighContrast;
    _cachedPlatformBrightness = brightness;
    return newTheme;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _themeMode = widget.initialThemeMode ?? .system;
    _lightTheme = widget.lightTheme ?? .light;
    _darkTheme = widget.darkTheme ?? .dark;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _invalidateThemeCache();
  }

  @override
  void didUpdateWidget(covariant JustThemeProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lightTheme != oldWidget.lightTheme) {
      _lightTheme = widget.lightTheme ?? .light;
      _invalidateThemeCache();
    }
    if (widget.darkTheme != oldWidget.darkTheme) {
      _darkTheme = widget.darkTheme ?? .dark;
      _invalidateThemeCache();
    }
  }

  @override
  void didChangePlatformBrightness() {
    if (_themeMode == .system) {
      _invalidateThemeCache();
      setState(() {});
    }
  }

  @override
  void didChangeAccessibilityFeatures() {
    _invalidateThemeCache();
    setState(() {});
  }

  /// Updates the active theme mode.
  ///
  /// Triggers [JustThemeProvider.onThemeChanged] if provided.
  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _invalidateThemeCache();
    setState(() {
      _themeMode = mode;
    });
    widget.onThemeChanged?.call(mode);
  }

  /// Toggles between light and dark themes.
  void toggleTheme() {
    setThemeMode(_themeMode == .light ? .dark : .light);
  }

  /// Replaces the active light/dark themes dynamically.
  void applyTheme({JustThemeData? light, JustThemeData? dark}) {
    _invalidateThemeCache();
    setState(() {
      if (light != null) _lightTheme = light;
      if (dark != null) _darkTheme = dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _JustThemeModel(
      state: this,
      themeMode: _themeMode,
      themeData: theme,
      child: widget.child,
    );
  }
}

class _JustThemeModel extends InheritedModel<JustThemeAspect> {
  final JustThemeProviderState state;
  final ThemeMode themeMode;
  final JustThemeData themeData;

  const _JustThemeModel({
    required super.child,
    required this.state,
    required this.themeMode,
    required this.themeData,
  });

  @override
  bool updateShouldNotify(_JustThemeModel oldWidget) {
    return themeMode != oldWidget.themeMode || themeData != oldWidget.themeData;
  }

  @override
  bool updateShouldNotifyDependent(
    _JustThemeModel oldWidget,
    Set<JustThemeAspect> dependencies,
  ) {
    return dependencies.any(
      (JustThemeAspect aspect) => switch (aspect) {
        .colors => themeData.colors != oldWidget.themeData.colors,
        .typography => themeData.typography != oldWidget.themeData.typography,
        .spacing => themeData.spacing != oldWidget.themeData.spacing,
        .radius => themeData.radius != oldWidget.themeData.radius,
        .shadows => themeData.shadows != oldWidget.themeData.shadows,
        .animations => themeData.animations != oldWidget.themeData.animations,
        .preset => themeData.preset != oldWidget.themeData.preset,
      },
    );
  }
}

/// Extension methods on [BuildContext] to simplify access to JustUI themes.
extension JustThemeContext on BuildContext {
  /// Retrieves the active [JustThemeData] configuration and subscribes the context
  /// to rebuild on any theme updates.
  JustThemeData get justTheme => JustThemeProvider.of(this).theme;

  /// Retrieves the active [JustColorScheme] and subscribes the context
  /// to rebuild *only* when the color aspect changes.
  JustColorScheme get justColors =>
      JustThemeProvider.of(this, aspect: JustThemeAspect.colors).theme.colors;

  /// Retrieves the active [JustTypographyScheme] and subscribes the context
  /// to rebuild *only* when the typography aspect changes.
  JustTypographyScheme get justTypo => JustThemeProvider.of(
    this,
    aspect: JustThemeAspect.typography,
  ).theme.typography;

  /// Retrieves the active [JustSpacingScheme] and subscribes the context
  /// to rebuild *only* when the spacing aspect changes.
  JustSpacingScheme get justSpacing =>
      JustThemeProvider.of(this, aspect: JustThemeAspect.spacing).theme.spacing;

  /// Retrieves the active [JustRadiusScheme] and subscribes the context
  /// to rebuild *only* when the radius aspect changes.
  JustRadiusScheme get justRadius =>
      JustThemeProvider.of(this, aspect: JustThemeAspect.radius).theme.radius;

  /// Retrieves the active [JustShadowScheme] and subscribes the context
  /// to rebuild *only* when the shadows aspect changes.
  JustShadowScheme get justShadows =>
      JustThemeProvider.of(this, aspect: JustThemeAspect.shadows).theme.shadows;

  /// Retrieves the active [JustMotionProfile] and subscribes the context
  /// to rebuild *only* when the animations aspect changes.
  JustMotionProfile get justAnimations => JustThemeProvider.of(
    this,
    aspect: JustThemeAspect.animations,
  ).theme.animations;

  /// Retrieves the active resolved [JustMotionProfile] and subscribes the context
  /// to rebuild *only* when the animations aspect changes.
  JustMotionProfile get justMotion => justAnimations.resolve(this);

  /// Retrieves the active [JustPresetTokens] configuration and subscribes the context
  /// to rebuild *only* when the preset aspect changes.
  JustPresetTokens get justPresetTokens => JustThemeProvider.of(
    this,
    aspect: JustThemeAspect.preset,
  ).theme.presetTokens;

  /// Retrieves the active [JustThemePreset] enum value.
  JustThemePreset get justPreset =>
      JustThemeProvider.of(this, aspect: JustThemeAspect.preset).theme.preset;

  /// Returns true if the active theme background is dark (luminance < 0.5).
  bool get isDarkMode =>
      JustThemeProvider.of(
        this,
        aspect: JustThemeAspect.colors,
      ).theme.colors.background.computeLuminance() <
      0.5;

  /// Reads the active theme configuration without registering a rebuild dependency.
  JustThemeData readTheme() => JustThemeProvider.read(this).theme;
}

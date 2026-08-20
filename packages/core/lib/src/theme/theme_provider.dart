import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/widgets.dart';
import 'package:just_ui_tokens/just_ui_tokens.dart';

import 'theme_aspects.dart';
export 'theme_aspects.dart';
import 'theme_data.dart';

/// A stateful provider that manages the theme mode and active theme data for JustUI.
///
/// Under the hood, it propagates the active theme down the tree using an [InheritedModel],
/// enabling widgets to subscribe to specific theme components (aspects) for optimal rendering performance.
class const JustThemeProvider({
  super.key,
  required final Widget child,
  final void Function(ThemeMode)? onThemeChanged,
  final ThemeMode? initialThemeMode,
  final JustThemeData? lightTheme,
  final JustThemeData? darkTheme,
  final Duration transitionDuration = JustDuration.normal,
  final Curve transitionCurve = JustCurves.default_,
}) extends StatefulWidget {
  @override
  State<JustThemeProvider> createState() => JustThemeProviderState();

  /// Retrieves the active state of this provider and registers a rebuild dependency on the context.
  ///
  /// Specify an [aspect] (e.g., [JustThemeAspect.colors]) to restrict rebuilds to changes in that component only.
  static JustThemeProviderState of(
    BuildContext context, {
    JustThemeAspect? aspect,
  }) {
    final model = InheritedModel.inheritFrom<_JustThemeModel>(
      context,
      aspect: aspect,
    );
    if (model == null) {
      throw FlutterError('JustThemeProvider was not found in the widget tree.');
    }
    return model.state;
  }

  /// Retrieves the active state without registering a rebuild dependency.
  ///
  /// Ideal for callbacks, event handlers, or initialization.
  static JustThemeProviderState read(BuildContext context) {
    final element = context
        .getElementForInheritedWidgetOfExactType<_JustThemeModel>();
    if (element == null) {
      throw FlutterError('JustThemeProvider was not found in the widget tree.');
    }
    return (element.widget as _JustThemeModel).state;
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

  /// Retrieves the active resolved [JustThemeData] based on [themeMode] and system brightness.
  JustThemeData get theme {
    final JustThemeData baseTheme;
    switch (_themeMode) {
      case .light:
        baseTheme = _lightTheme;
        break;
      case .dark:
        baseTheme = _darkTheme;
        break;
      case .system:
        final brightness =
            WidgetsBinding.instance.platformDispatcher.platformBrightness;
        baseTheme = brightness == .dark ? _darkTheme : _lightTheme;
        break;
    }

    final isHighContrast =
        WidgetsBinding
            .instance
            .platformDispatcher
            .accessibilityFeatures
            .highContrast ||
        (MediaQuery.maybeHighContrastOf(context) ?? false);

    final resolvedTheme = isHighContrast
        ? baseTheme.applyHighContrastOverrides()
        : baseTheme;

    final double width = MediaQuery.maybeSizeOf(context)?.width ?? 1024.0;
    final resolvedAnimations = resolvedTheme.animations.resolve(context);

    return resolvedTheme.copyWith(
      spacing: resolvedTheme.spacing.resolve(width),
      radius: resolvedTheme.radius.resolve(width),
      animations: resolvedAnimations,
    );
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
  void didUpdateWidget(covariant JustThemeProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lightTheme != oldWidget.lightTheme) {
      _lightTheme = widget.lightTheme ?? .light;
    }
    if (widget.darkTheme != oldWidget.darkTheme) {
      _darkTheme = widget.darkTheme ?? .dark;
    }
  }

  @override
  void didChangePlatformBrightness() {
    if (_themeMode == .system) {
      setState(() {});
    }
  }

  @override
  void didChangeAccessibilityFeatures() {
    setState(() {});
  }

  /// Updates the active theme mode.
  ///
  /// Triggers [JustThemeProvider.onThemeChanged] if provided.
  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    setState(() {
      _themeMode = mode;
    });
    widget.onThemeChanged?.call(mode);
  }

  /// Toggles between light and dark themes.
  void toggleTheme() {
    if (_themeMode == .light) {
      setThemeMode(.dark);
    } else {
      setThemeMode(.light);
    }
  }

  /// Replaces the active light/dark themes dynamically.
  void applyTheme({JustThemeData? light, JustThemeData? dark}) {
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

class const _JustThemeModel({
  required super.child,
  required final JustThemeProviderState state,
  required final ThemeMode themeMode,
  required final JustThemeData themeData,
}) extends InheritedModel<JustThemeAspect> {
  @override
  bool updateShouldNotify(_JustThemeModel oldWidget) {
    return themeMode != oldWidget.themeMode || themeData != oldWidget.themeData;
  }

  @override
  bool updateShouldNotifyDependent(
    _JustThemeModel oldWidget,
    Set<JustThemeAspect> dependencies,
  ) {
    if (dependencies.contains(JustThemeAspect.colors) &&
        themeData.colors != oldWidget.themeData.colors) {
      return true;
    }
    if (dependencies.contains(JustThemeAspect.typography) &&
        themeData.typography != oldWidget.themeData.typography) {
      return true;
    }
    if (dependencies.contains(JustThemeAspect.spacing) &&
        themeData.spacing != oldWidget.themeData.spacing) {
      return true;
    }
    if (dependencies.contains(JustThemeAspect.radius) &&
        themeData.radius != oldWidget.themeData.radius) {
      return true;
    }
    if (dependencies.contains(JustThemeAspect.shadows) &&
        themeData.shadows != oldWidget.themeData.shadows) {
      return true;
    }
    if (dependencies.contains(JustThemeAspect.animations) &&
        themeData.animations != oldWidget.themeData.animations) {
      return true;
    }
    if (dependencies.contains(JustThemeAspect.preset) &&
        themeData.preset != oldWidget.themeData.preset) {
      return true;
    }
    return false;
  }
}

import 'dart:async' show scheduleMicrotask;
import 'dart:ui' show ViewFocusDirection, ViewFocusEvent, ViewFocusState;

import 'package:flutter/material.dart'
    show Material, MaterialApp, MaterialType, ThemeMode;
import 'package:flutter/scheduler.dart' show SchedulerBinding;
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/just_ui_core.dart';

import '../scenes/scene.dart';
import '../scenes/scene_registry.dart';
import '../scenes/strings.dart';
import '../theme/ink_paper_extensions.dart';
import '../theme/ink_paper_theme.dart';
import 'bridge.dart';
import 'view_config.dart';

/// Everything one docs host element shows: the scene named in its
/// `initialData`, in its own preset, mode and locale.
///
/// Each view gets its own [MaterialApp] with `title: null`: on the web a
/// title would overwrite the host page's `document.title`, and the app's
/// route scope is what lets Tab move out of the view to the next element of
/// the page instead of looping inside it.
class const ViewHost({
  super.key,

  /// Id of the `FlutterView` this host renders into.
  required final int viewId,

  /// Config to use when the page sent none (standalone runs and tests).
  final ViewConfig? fallbackConfig,
}) extends StatefulWidget {
  @override
  State<ViewHost> createState() => _ViewHostState();
}

class _ViewHostState extends State<ViewHost> with WidgetsBindingObserver {
  ViewConfig? _config;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _config =
        ViewConfig.parse(bridgePlatform.initialConfig(widget.viewId)) ??
        widget.fallbackConfig;
    // The controller goes out once, after the first frame, so the page
    // swaps its fallback only when the view has painted.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted && _config != null) {
        bridgePlatform.announce(widget.viewId, _update);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Tab from the page into this view must land on its first control
  /// (Shift+Tab on its last).
  ///
  /// The framework's `View` focuses the first traversal node of the view,
  /// which is the route's focus scope. Each view's route takes the startup
  /// autofocus in turn, so only the last view mounted remembers a focused
  /// child there; in every other view the scope itself takes focus and the
  /// DOM focus stays on the empty flutter-view element. This runs after the
  /// framework's handler and moves on to the control.
  @override
  void didChangeViewFocus(ViewFocusEvent event) {
    if (event.viewId != widget.viewId ||
        event.state != ViewFocusState.focused) {
      return;
    }
    scheduleMicrotask(() => _focusEdge(event.direction));
  }

  void _focusEdge(ViewFocusDirection direction) {
    if (!mounted) return;
    final FocusScopeNode view = FocusScope.of(context);
    final FocusNode? primary = FocusManager.instance.primaryFocus;
    final bool onControl =
        primary != null &&
        primary is! FocusScopeNode &&
        primary.ancestors.contains(view);
    if (onControl) return;
    // Tree order is the scenes' Tab order: they use the default reading
    // order and lay out their controls in it.
    final List<FocusNode> controls = view.traversalDescendants
        .where((FocusNode node) => node is! FocusScopeNode)
        .toList();
    if (controls.isEmpty) return;
    (direction == .backward ? controls.last : controls.first).requestFocus();
  }

  Future<void> _update(Object? patch) {
    final ViewConfig? current = _config;
    if (!mounted || current == null) return Future<void>.value();
    setState(() => _config = current.merge(patch));
    return SchedulerBinding.instance.endOfFrame;
  }

  @override
  Widget build(BuildContext context) {
    final ViewConfig? config = _config;
    final SceneBuilder? scene = config == null
        ? null
        : sceneRegistry[config.scene];
    if (config == null || scene == null) return const SizedBox.shrink();
    final JustThemeData theme = InkPaperTheme.build(config.preset, config.mode);
    return JustThemeProvider(
      lightTheme: theme,
      darkTheme: theme,
      initialThemeMode: ThemeMode.light,
      transitionDuration: Duration.zero,
      child: MaterialApp(
        title: null,
        debugShowCheckedModeBanner: false,
        // The page awaits update() until the frame shows the new theme, so
        // the switch must not animate (the docs crossfade covers it).
        themeAnimationDuration: Duration.zero,
        theme: theme.toThemeData(
          additionalExtensions: inkPaperExtensions(
            config.preset,
            InkPaperTheme.roles(config.mode),
          ),
        ),
        // Transparent Material gives text its default style (no debug
        // underline) and lets the docs stage show through.
        home: Material(
          type: MaterialType.transparency,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Builder(
              builder: (BuildContext context) => scene(
                context,
                SceneContext(
                  strings: KitStrings(values: config.strings),
                  props: config.props,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

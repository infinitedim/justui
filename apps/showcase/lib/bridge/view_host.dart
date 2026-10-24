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

class _ViewHostState extends State<ViewHost> {
  ViewConfig? _config;

  @override
  void initState() {
    super.initState();
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

# JustUI Core 🚀

The core engine and primitive components of JustUI, a high-performance copy-paste component library for Flutter.

## Theme & MaterialApp Requirement

JustUI components are strictly **zero-Material** (they do not render Material design widgets like `ElevatedButton` or `TextField` internally, using core Flutter primitives instead). However, theme resolution relies on Flutter's built-in `Theme` framework.

> [!IMPORTANT]
> **MaterialApp or Theme Ancestor Requirement**
> JustUI components require a `MaterialApp` or standard `Theme` widget ancestor in the widget tree for `ThemeExtension`-based customization (such as `JustButtonTheme`, `JustCheckboxTheme`, `JustRadioTheme`, and `JustSwitchTheme`) to function.
>
> If you are using `WidgetsApp` or `CupertinoApp`, ensure that you wrap your app tree in a `Theme` widget using `JustThemeData.toThemeData()`:
>
> ```dart
> CupertinoApp(
>   builder: (context, child) {
>     return Theme(
>       data: JustThemeData.light.toThemeData(),
>       child: child!,
>     );
>   },
>   home: const MyHomeScreen(),
> )
> ```

## Features & Utilities

1. **Aspect-Based Rebuilds (`InheritedModel`):** Rebuilds only the widgets that depend on modified theme aspects (e.g. colors, spacing, or typography) when a theme updates.
2. **Lazy-Cached Material ThemeData:** Translates and caches custom themes into Flutter `ThemeData` to eliminate rendering overhead.
3. **Dynamic Contrast Enforcement:** Automatically scales primary colors at runtime to guarantee WCAG AA accessibility contrast ratios ($\ge$ 3.0:1) against the active background.

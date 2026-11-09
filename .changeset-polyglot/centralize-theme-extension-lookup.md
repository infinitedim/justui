---
"just_ui_core": minor
"justui_cli": patch
---

Add `BuildContext.justThemeExtension<T>()` helper to centralize `ThemeExtension` lookups, update all core components and the `justui create component` template to use it, and wire `JustBreadcrumbTheme` and `JustInputTheme` into `JustBreadcrumb` and `JustInput`.

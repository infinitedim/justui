---
"just_ui_core": patch
---

refactor(core): simplify button, select and input internals

- `JustButton` and `JustIconButton` are now `StatelessWidget`s and share one
  color resolver (`resolveJustButtonColors`) plus `JustButtonTheme.styleFor`.
- `JustSelect` and `JustInput` builds are split into focused private helpers
  and widgets. No visual or API changes.
- `JustThemeData.buildPressEffect` delegates to the preset token
  implementation instead of duplicating it.

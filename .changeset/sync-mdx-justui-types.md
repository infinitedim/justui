---
"docs": patch
---

docs(docs): sync MDX code snippets with JustUI types and add validation guards

- Update `quick-start.mdx` to use `JustThemeMode.system` on `JustThemeProvider.initialThemeMode`.
- Update `date-range-picker.mdx` to use `JustDateTimeRange`, `JustDateRangePreset.resolve`, and widget imports.
- Update `time-picker.mdx` to use `JustTimeOfDay`, widget imports, and `.inline` default variant.
- Add snippet and API props validation guards in Vitest and `tools/validate_mdx_snippets.dart`.

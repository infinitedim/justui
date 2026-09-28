---
"justui_cli": patch
---

fix(cli): make installed components compile and verify self-upgrades

- Preserve subdirectories when rewriting `package:just_ui_core/src/...` and `package:just_ui_tokens/src/...` imports so they match the layout extracted by `justui init` (e.g. `core/theme/preset_tokens.dart`).
- Add a primary → standard constructor transpiler and apply it for `dart_target: standard` in `add`, `update`, `diff` and `init` (core/tokens extraction), including `new`-style named constructors.
- Fix `registryDependencies` for `avatar`, `date-picker`, `time-picker`, `date-range-picker` and `_shared_tooltip_overlay`; `tools/generate_checksums.dart` and a new Rust test now fail when declarations drift from actual imports.
- `justui upgrade` now verifies the downloaded archive against the release `SHA256SUMS` manifest before replacing the executable.

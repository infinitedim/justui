---
"justui_cli": patch
---

feat(cli): harden registry input validation and trust management

- Validate registry component names, file names, and paths against traversal attacks.
- Enforce cycle detection in component dependency resolution.
- Validate pub dependency names and semver constraints before updating pubspec.yaml.
- Manage per-user trusted registries with interactive confirmation and `--trust-registry` non-interactive CLI flag.
- Display registry source and trust state in `justui doctor`.
- Enable `clippy::join_absolute_paths` lint.

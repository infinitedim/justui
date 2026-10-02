---
trigger: manual
description: "Constraints for running inside an offline sandbox or a container with a read-only HOME. Mention @sandbox to load."
---

# Sandbox constraints

Load this only when you run in a restricted container (CI-like sandbox,
remote agent), not on the developer's own machine.

## Offline

- The container may not reach pub.dev, npm or crates.io. Do not try to
  install or upgrade packages; report what you would need instead.
- Local package links are pre-resolved in `.dart_tool/package_config.json`.
  Do not delete or regenerate `.dart_tool`.

## Read-only HOME

Dart writes telemetry and caches under HOME. If HOME is read-only, prefix Dart
commands with a writable HOME (it is git-ignored):

```bash
export HOME=$PWD/.home
dart analyze packages/core
dart analyze packages/tokens
dart run tools/generate_checksums.dart --dry-run
```

## Limits

- Flutter widget tests may fail to start without a display or sockets. Run
  what you can, and report the rest as `not verified: flutter test (no
  display in sandbox)`. Never report them as passing.
- Playwright and browser checks may be unavailable; report them the same way.

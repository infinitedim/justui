---
"justui_cli": patch
---

fix(cli): exit non-zero on failure, support quiet and no-color, and fix CI test

- Commands now exit with status code 1 instead of 0 upon failures.
- Global flags --quiet and --no-color now properly suppress logs and ANSI color codes.
- Updated dart_formatter unit tests to gracefully handle CI environments without Dart on PATH.

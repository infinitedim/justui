# Polyglot Changesets

This directory contains changesets for non-npm packages (Dart/Flutter and Rust).
These are processed by `tools/apply_changesets.dart` and `tools/apply_changesets_cargo.sh`
instead of `@changesets/cli`.

## Format

Identical to standard Changesets frontmatter format:

```markdown
---
"just_ui_core": patch
"just_ui_tokens": minor
"justui_cli": patch
---

Detailed description of changes following Conventional Commits.
```

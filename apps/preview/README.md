# JustUI Preview App (Widgetbook Workbench)

Interactive component catalog and workbench for **JustUI** built with **Widgetbook 3**.

Components are imported directly from `packages/core` and `packages/tokens` and previewed inside Widgetbook with support for Light, Dark, and Neobrutalism theme presets.

## Running Widgetbook

### 1. Run on Web
```bash
flutter run -d chrome
```

### 2. Run on Desktop (macOS / Linux / Windows)
```bash
flutter run -d macos
```

## Regenerating Component Use Cases

When adding or updating `@UseCase` annotated functions in `lib/usecases/`, run `build_runner` to update `lib/main.directories.g.dart`:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Or watch for live file changes:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

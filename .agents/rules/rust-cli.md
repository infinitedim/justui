---
trigger: glob
globs: "packages/cli/**, Cargo.toml, Cargo.lock, .cargo/**"
description: "Rust rules for the justui CLI: error handling, exit codes, output, safety of install/update paths, tests."
---

# Rust CLI (`packages/cli`)

## Layout

- `src/main.rs` - clap definitions and dispatch
- `src/commands/` - one file (or folder) per subcommand: init, add, diff,
  update, upgrade, create, view, search, info, preset, doctor, list
- `src/utils/` - transpiler, import rewriter, pubspec editor, theme editor,
  env resolver, FVM detection, logger, prompts, diff and syntax output
- `src/registry.rs`, `src/config.rs` - registry fetch and `justui.config.yaml`
- Tests: `*_tests.rs` next to the code, integration tests in `tests/`

## Errors

- No `.unwrap()` or `.expect()` in non-test code you write or change. Use `?`
  with `anyhow::Context` (`.with_context(|| format!("reading {}", path.display()))`).
  Existing calls are legacy: replace them only in functions you already edit.
- Every error path ends in a non-zero exit code. Never print an error and
  return `Ok(())`. If a command can partially succeed, return an error that
  says what failed.
- Error messages say what failed, on which path or component, and what the
  user can do next.

## Output

- Print through `utils::logger`, not raw `println!`/`eprintln!`, so output
  can respect the global `--quiet`, `--no-color` and `--json` flags.
- With `--json`, stdout carries only JSON. Spinners, colors and boxes go to
  stderr or are suppressed.
- Interactive prompts use `inquire` and must have a non-interactive path
  (`-y` / `--yes`, or a clear error when stdin is not a TTY).
- Network operations show an `indicatif` spinner unless quiet or JSON.

## Code quality

- `cargo clippy --all-targets --all-features -- -D warnings` must be clean.
- `cargo fmt` formatting.
- Keep functions under 60 lines in new code; split helpers into
  `src/utils/` when shared by more than one command.
- Public functions get `///` docs that say what they do and how they fail.

## Red zone (plan + approval + tests first)

These paths protect users' machines and projects. See `security.md`.

- `src/commands/add.rs` (checksum verification, conflict matrix, file writes)
- `src/commands/update.rs`, `src/commands/diff.rs` (local edit detection)
- `src/commands/upgrade.rs` (binary download, magic bytes and arch check,
  atomic replace, rollback)
- `src/utils/pubspec_editor.rs` (edits user `pubspec.yaml`, writes `.bak`)
- `src/utils/theme_editor.rs` (`// CLI:REGISTER_EXTENSIONS` injection)
- `src/utils/import_rewriter.rs`, `src/utils/constructor_transpiler.rs`
  (rewrite user code)
- `src/registry.rs`, `install/install.sh`, `install/install.ps1`

Rules for the red zone:
- Never remove, skip or weaken a verification (checksum, magic bytes,
  architecture, size, signature) to make a test or a flow pass.
- Any change that writes to a user's project must keep it idempotent and keep
  a backup or a safe failure (no half-written files).
- Add tests for the failure path, not only the happy path.

## Transpiler and rewriters

They are regex based. When you extend them:
- Fail safe: return the input unchanged when a pattern does not match.
- Add a test with the exact Dart input and expected output for each new case.
- Output must pass `dart format` unchanged and `flutter analyze` with no
  `unnecessary_import` infos. Check against `apps/showcase` regeneration.

## Tests

- Unit tests next to the code, integration tests with `assert_cmd` and
  `predicates` in `tests/`.
- Tests must not assume tools that CI does not install. If a test needs
  `dart` or `flutter`, detect it and skip with a printed reason, or move it to
  a job that installs the SDK.
- Bug fix = failing test first (see `workflow.md`).

## Dependencies and audit

- New crates or version bumps need approval (see `security.md`).
- Never add an entry to `.cargo/audit.toml` `ignore`. If `cargo audit` fails,
  report it and propose the upgrade.

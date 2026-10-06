---
trigger: glob
globs: "packages/cli/**, Cargo.toml, Cargo.lock, .cargo/**, rust-toolchain.toml, rustfmt.toml, clippy.toml, deny.toml"
description: "Rust rules for the justui CLI: toolchain, lints, errors, exit codes, file and network safety, output, tests, dependencies."
---

# Rust CLI (`packages/cli`)

Each rule says why. A named lint wins over your reading of the prose.

## Layout

- `src/main.rs` clap and dispatch; `src/commands/` one file or folder each.
- `src/utils/` - transpiler, import rewriter, pubspec and theme editors, env
  resolver, FVM detection, logger, prompts, diff and syntax output.
- `src/registry.rs`, `src/config.rs` - registry fetch, `justui.config.yaml`.
- Modules use `mod.rs` folders. Do not convert them. Why: churn and broken
  blame for no behavior change.
- Items are `pub(crate)` by default. Use `pub` only for items that
  integration tests in `tests/` call. Why: lets `dead_code` find unused code
  and keeps internals free to refactor.

## Toolchain and lints

- Rust version is pinned in `rust-toolchain.toml`; `rust-version` in
  `Cargo.toml` matches it. Edition 2024. Never change either unless that is
  the task. Why: local, CI and agent must run the same compiler and clippy.
- Lints live in `[workspace.lints]` in the root `Cargo.toml`; thresholds in
  `clippy.toml`. Never silence a lint with a bare `#[allow]`: add
  `#[allow(clippy::x, reason = "...")]` on the smallest item
  (`clippy::allow_attributes_without_reason`). Why: the reason is reviewed
  with the code instead of living in someone's head.
- Enabled on top of default: `clippy::pedantic` (warn, CI turns it into
  errors), `redundant_clone` (warn), and as deny: `unwrap_used`, `panic`, `todo`, `dbg_macro`,
  `print_stdout`, `print_stderr`; `unsafe_code` is forbid (need it? stop
  and ask).
- Legacy code: some files start with a module-level
  `#![expect(clippy::x, reason = "legacy: fix when touched")]`. When you
  change a function in such a file, fix that function's violations. When the
  last one is gone, the compiler reports the expectation as unfulfilled:
  delete that line. Never add a new legacy `expect`. Why: lint stays on for
  new code without a giant migration (boy-scout rule), and stale exceptions
  cannot linger.

## Errors

- `unwrap()` is banned outside tests (`clippy::unwrap_used`).
- `expect()` is allowed only for real invariants, and the message starts with
  `invariant:` and says why it cannot fail:
  `.expect("invariant: regex literal is valid")`. Not for IO, network,
  parsing user files or anything the user can influence. Why: the message
  documents the proof; everything else must become an error the user can act on.
- Library-like modules (`registry.rs`, `config.rs`, `utils/*` red-zone files)
  return typed errors defined with `thiserror`. Commands use
  `anyhow::Result` and add context. Why: callers can match on
  `ChecksumMismatch`, `PathEscape`, `Conflict` to pick exit codes and test them.
- Error and context messages are lowercase with no trailing period, and say
  what failed and on which path or component:
  `.with_context(|| format!("reading {}", path.display()))`.
- Advice for the user goes in a separate `hint:` line printed by the logger,
  never inside the error chain. Every user-facing error should have a hint
  unless the next step is obvious.
- Never print an error and return `Ok(())`. A partial success returns an error
  that lists what failed.
- Every public function documents `# Errors` (and `# Panics` if it has an
  `expect`). Enforced by `clippy::missing_errors_doc`/`missing_panics_doc`.

## Exit codes

| Code | Meaning                                                    |
| ---- | ---------------------------------------------------------- |
| 0    | success                                                    |
| 1    | other error                                                |
| 2    | usage error (clap), or a prompt needed without a TTY       |
| 3    | network or registry unreachable                            |
| 4    | integrity failure (checksum, binary magic, arch, size)     |
| 5    | file conflict the user must resolve                        |
| 130  | cancelled by the user (Ctrl-C, Esc in a prompt)            |

Map typed errors to codes in one place in `main.rs`. Add a code only by
updating this table and the docs. Why: users' CI scripts depend on these.

## Panics

A custom panic hook prints a short message with the CLI version and the issue
link (`https://github.com/infinitedim/justui/issues/new`), restores the
terminal through `utils::terminal_guard`, and shows the full report only with
`RUST_BACKTRACE=1`. Keep `panic = "unwind"` so drop guards run. Why: a raw
panic in a user's terminal gives them nothing to act on.

## Ownership and style

- Take borrowed inputs (`&str`, `&Path`, `impl AsRef<Path>`), return owned
  values. Why: callers stay flexible and ownership stays obvious.
- Clone freely outside hot loops; `clippy::redundant_clone` catches waste.
  Why: the CLI is IO bound, readability beats micro-optimisation.
- Iterator chains for simple transforms; a `for` loop when the body has side
  effects or uses `?`. Why: `collect::<Result<_>>` chains get hard to read.
- Regexes used more than once are `static` with `std::sync::LazyLock`, built
  with `.expect("invariant: regex literal is valid")`, and each has a unit
  test that forces it. Why: compile once; the test turns the runtime panic
  into a test failure.
- Formatting: `cargo fmt` with the repo `rustfmt.toml` (stable options only).
- Functions stay under 60 lines (`clippy::too_many_lines`, threshold in
  `clippy.toml`). New files stay under 400 lines. Why: small units are easier
  to test and to review.
- Every module file starts with `//!` docs: what the module does and the
  invariants a caller must not break. Why: agents read the header before
  editing red-zone files.

## Domain types

Security-sensitive values are newtypes validated once at the boundary:
`ProjectRelPath` (a path proven to stay inside the project root) and
`Sha256Hex` (64 hex chars, stored lowercase). Functions that write files or compare
checksums take these types, never `String`/`PathBuf`. Why: an unchecked path
or hash cannot reach a write call by accident.

## Files in the user's project

- All writes go through the path helper in `src/utils/` (`safe_join`): lexical
  normalisation, reject `..` escape, reject any symlink in the target path.
  Why: one audited choke point; canonicalize fails on new files and mangles
  Windows paths.
- All writes are atomic: `tempfile::NamedTempFile::new_in(parent)`, write,
  flush, then `persist`, and stay idempotent (a second run changes nothing).
  Why: Ctrl-C or a crash never leaves a half-written file.

## Network

- One shared HTTP client builder sets connect and total timeouts and the
  `User-Agent: justui/<version>` header. Never build a client inline.
- GET requests retry 2 to 3 times with exponential backoff on connect errors,
  timeouts and 5xx. Never retry 4xx or integrity failures.
- Registry URLs must be `https://`, except local paths and
  `http://localhost`/`127.0.0.1`. Why: no silent downgrade to plain HTTP.
- Network code is async on `tokio` with `reqwest` async. Do not call blocking
  IO inside async tasks; use `tokio::fs` or `spawn_blocking`. Parallel
  downloads use a `JoinSet` bounded by a `Semaphore` (default 4). Why:
  `add --all` is network bound; unbounded fan-out hits rate limits.
- Until the async migration lands, existing blocking code stays blocking.
  Never call `reqwest::blocking` inside a tokio runtime (it panics).

## Output

- Print only through `utils::logger` (`print_stdout`/`print_stderr` are
  denied; the logger module carries the one allowed exception). Why: global
  `--quiet`, `--no-color`, `--json` and `-v` must apply everywhere.
- Global `-v`/`-vv` raise the log level (info, debug, trace).
- With `--json`, stdout carries only JSON. Each command's JSON has a top-level
  `"version"` field and a documented shape, and has an `insta` snapshot test.
  Changing the shape is a breaking change: bump `version` and add a changeset.
- Color decisions come from one function that honours `NO_COLOR`,
  `CLICOLOR_FORCE`, `--no-color` and whether the stream is a TTY.
- Network work shows an `indicatif` spinner unless quiet or JSON. Prompts
  use `inquire`. When stdin is not a TTY and no `-y` is given, fail
  with exit code 2 and the hint "use -y to run non-interactively". Never pick
  a default silently. Why: a silent default can overwrite user files in CI.

## clap

- Help text comes from `///` doc comments on the derive structs; no separate
  help strings. Write them for users.
- Fixed choices (preset, color space, dart target) are `ValueEnum`.
- A unit test calls `Cli::command().debug_assert()`. Why: catches conflicting
  flags at test time, not in a user's terminal.

## Config (`justui.config.yaml`)

- The config has a `version` field. Format changes add a migration function
  from the previous version and a test for it.
- Unknown fields are accepted but each one prints a warning naming the field.
  Why: typos get noticed, and older CLIs still read newer configs.
- YAML is parsed with the maintained `serde_yaml` fork in `Cargo.toml`, not
  `serde_yaml` 0.9 (deprecated upstream) or `serde_yml` (has an advisory).

## Red zone (plan + approval + tests first)

These paths protect users' machines and projects. See `security.md`.

- `src/commands/add.rs` (checksum verification, conflict matrix, file writes)
- `src/commands/update.rs`, `src/commands/diff.rs` (local edit detection)
- `src/commands/upgrade.rs` (binary download, magic bytes and arch check,
  atomic replace, rollback)
- `src/utils/pubspec_editor.rs`, `src/utils/theme_editor.rs`,
  `src/utils/import_rewriter.rs`, `src/utils/constructor_transpiler.rs`
- `src/registry.rs`, the path helper, `install/install.sh`,
  `install/install.ps1`

Rules for the red zone:
- Never remove, skip or weaken a verification (checksum, magic bytes,
  architecture, size, signature) to make a test or a flow pass.
- Writes keep a safe failure (atomic write, no half-written files).
- Add tests for the failure path, not only the happy path.

## Transpiler and rewriters

They are regex based. When you extend them:
- Fail safe: return the input unchanged when a pattern does not match.
- Add an `insta` snapshot with the exact Dart input and expected output.
- Add or extend a `proptest` that unknown input comes back unchanged.
- Output must pass `dart format` unchanged and `flutter analyze` with no
  `unnecessary_import` infos. Check against `apps/showcase` regeneration.

## Tests

- Small tests inline in `#[cfg(test)] mod tests` at the bottom of the file.
  When a test module passes about 150 lines, move it to a sibling
  `<name>_tests.rs`. Integration tests go in `tests/`.
- Tests may use `unwrap`/`expect`/`panic` (`allow-*-in-tests` in `clippy.toml`).
- Every subcommand has `assert_cmd` tests for: one happy path, one failure
  path with its exit code, `--json` output, and running without a TTY.
- Snapshot tests (`insta`) for transpiler, import rewriter, diff output and
  every `--json` shape. Review every snapshot before accepting it.
- `proptest` for path normalisation, `safe_join`, the import path resolver and
  transpiler fail-safety.
- Network tests use a local mock HTTP server (`wiremock`), never the real
  registry. Cover timeout, 404, 5xx retry, and a checksum mismatch.
- Red-zone modules have a minimum line coverage gate (`cargo llvm-cov`) in CI.
  Do not lower the gate; add tests.
- Tests must not assume tools CI does not install. If a test needs `dart` or
  `flutter`, detect it and skip with a printed reason.
- CI runs tests on Linux and Windows; macOS builds only. Path code must use
  `std::path` APIs, never string concatenation with `/`.
- Bug fix = failing test first (see `workflow.md`).

## Dependencies and supply chain

- New crates or version bumps need approval (see `security.md`).
- `cargo deny check` (advisories, licenses, bans, sources) must pass. Never
  add an advisory ignore to `deny.toml`; report the advisory and propose the
  upgrade. Why: an ignore hides the risk from every later reader.
- `cargo machete` must report no unused dependencies. When you remove the last
  use of a crate, remove the crate in the same commit.
- Release profile: `lto = "thin"`, `codegen-units = 1`, `strip = true`,
  `opt-level = 3`. Do not change it without approval (binary size and build
  time are tracked).

## Checks for this area

Run from the repo root and paste the results (a missing tool is reported as
`not verified: <tool> (not installed)`):

```bash
cargo fmt --all --check
cargo clippy --all-targets --all-features -- -D warnings
cargo test --all-targets
cargo deny check
cargo machete
```

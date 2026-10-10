# Setup tasks that the new rules assume

The rules describe the target state. These changes make the repo match it.
Each item is one task; most fit one commit. Items marked (red zone) need a
plan first under the new rules.

## Install the rules

1. Replace root `AGENTS.md` with the new one. Add `GEMINI.md`,
   `.agents/rules/*.md` and `.agents/skills/justui-design/SKILL.md`.
2. Remove `.agents/skills/taste-skill` (replaced by `justui-design`) and
   `.agents/skills/senior-architect` (already marked for removal).
3. Done: `.gitignore`: add `.agents/tmp/`.
4. Move `justui-audit.md` out of the repo into `.agents/tmp/` (git-ignored).
   Note: deleting it from HEAD does not remove it from git history. Rewriting
   history needs a force-push, which the rules forbid for the agent; decide
   yourself whether it is worth it.
5. Done: Fix `CONTRIBUTING.md` step 4 (barrel export) to forbid
   exporting components from `just_ui_core.dart`.

## Docs site config (apps/docs)

6. `eslint.config.js`: `@typescript-eslint/no-explicit-any` from `warn` to
   `error` (current usage is 0, so this should pass as is).
7. `tsconfig.json`: add `"noUncheckedIndexedAccess": true`, then fix the
   errors it reports (expect a fair number in parsers and data maps).
8. `next.config.ts`: `reactCompiler: true`. Add the compiler lint rules
   (check whether the installed `eslint-plugin-react-hooks` v7 config already
   ships them) and run the full test and e2e suite.
9. Remove `react-icons`. Add a local GitHub mark component under
   `src/components/atoms/`, use it in `organisms/footer/footer.tsx` and
   `molecules/github-pill/github-pill.tsx`.
10. Migrate Indonesian copy from "Anda" to "kamu": `content/docs/id/**`
    (137 occurrences) and the ID strings in `src/lib/*-translations.ts`.
11. Add Playwright visual snapshot tests (`toHaveScreenshot`) for landing,
    catalog, one docs page and Studio, each in default/neobrutalism x
    light/dark.
12. Add a test that validates every Dart snippet in MDX and in
    `code-generators.ts` against `packages/core` (class, constructor and
    parameter names; import paths).
13. Give every page `generateMetadata` (unique title, description,
    `alternates.languages`, Open Graph).

## CI and tooling (red zone)

14. Done: CI: run `bun run generate:components -- --check` in `nextjs-ci`.
15. Done: CI: align the Bun pin with the `bun.lock` format (audit #62).
16. Done: `tools/generate_checksums.dart --dry-run`: exit non-zero on drift so the
    CI step catches it (audit #63).

## MCP setup (do these yourself in Antigravity, via "Open MCP Config")

The agent may not change MCP config, so these are manual.

20. Turn off `cloudrun`, `android-management-api` and `gopls-mcp-server`
    while you work on JustUI. The toggles are probably global, so turn
    `cloudrun` back on when you work on the portfolio backend.
21. Playwright args: add isolation, the origin allowlist and the output dir.
    `--allowed-origins` is semicolon-separated and is not a security
    boundary (redirects are not checked); it only keeps the agent on-site.

    ```json
    "playwright": {
      "command": "npx",
      "args": [
        "@playwright/mcp@latest",
        "--isolated",
        "--allowed-origins", "http://localhost:3000;https://justui.vercel.app",
        "--output-dir", ".agents/tmp/screenshots"
      ]
    }
    ```

    Replace `https://justui.vercel.app` if your production domain differs
    (it is the fallback for `NEXT_PUBLIC_SITE_URL` in `src/lib/site.ts`).
    If the config is global, add the dev-server origins of your other
    projects too, or they will be blocked.
22. Disable `browser_run_code_unsafe` in the Playwright tool list (the panel
    shows per-server tool counts, so per-tool toggles are likely; if not,
    the rule in `mcp.md` is the only guard).
23. dart-mcp-server: enable `run_tests`, `launch_app`, `stop_app`,
    `get_app_logs`, `list_devices`. Keep `dart_fix` off.
24. Add a library docs server (Context7). Check its README for the current
    package name and config before adding it. An API key is optional for
    light use.
25. mem0: if your gateway lets you, restrict this workspace to `app_id`
    `justui` and block `invoke` / `request_access` at the gateway level, so
    the rule is not the only guard.

## Larger projects (plan separately)

26. Flutter web embed for live component demos, replacing the React mocks in
    `src/components/organisms/simulators/`. Needs a CSP change
    (`frame-src`/`wasm`), bundle budget, loading state and fallback.
27. Dropped (rules questionnaire, T26): keep `'unsafe-inline'` in
    `script-src`. Nonces need `proxy.ts`, which makes every page dynamic and
    loses static rendering and CDN caching; hashes do not work because the
    inline RSC payload scripts differ per page.
28. Release checksums: done (`SHA256SUMS` + attestations in `release.yaml`).
    Pinned install script URLs: see item 60.

## Rust rules (questionnaire 2026-10-05; `rust-cli.md` assumes these)

The new crates and tools below were approved in the questionnaire. Each item
still needs a plan first, and items touching red-zone files follow
`security.md`.

Baseline measured on `development` (`667670c`) with rustc 1.97 and the
proposed lint set at default thresholds: 1139 clippy warnings across all
targets. Outside test files: about 300 `unwrap`/`expect`/`panic` calls, 242
`uninlined_format_args` (auto-fixable), 37 missing `# Errors`/`# Panics`
sections, 35 `must_use` suggestions, 7 functions over 100 lines (largest 351).

29. Done: `rust-toolchain.toml`: pin the current stable version (check the Rust
    release blog; rustc 1.97 was installed in the sandbox) with components
    `clippy` and `rustfmt`. Set `rust-version` in `packages/cli/Cargo.toml`
    to the same version. Make CI install the pinned version instead of
    floating `stable`.
30. Done: Edition 2024: `cargo fix --edition`, set `edition = "2024"`, run the full
    test suite. Own commit, no other changes.
31. Lints: `[workspace.lints]` in the root `Cargo.toml` with
    `rust.unsafe_code = "forbid"`, `clippy.pedantic = { level = "warn",
    priority = -1 }`, deny `unwrap_used`, `panic`, `todo`, `dbg_macro`,
    `print_stdout`, `print_stderr`, `allow_attributes_without_reason`,
    warn `redundant_clone` (it lives in nursery, so pedantic does not turn
    it on), allow `must_use_candidate` (noise). Add
    `[lints] workspace = true` to the crate. `clippy.toml`:
    `too-many-lines-threshold = 60` and the `allow-*-in-tests` options for
    unwrap, expect, panic, print and dbg. `expect_used` is NOT enabled: the
    questionnaire chose "expect allowed with an `invariant:` message" (R6),
    which clippy cannot check, so it is a written rule.
    Migration order: `cargo clippy --fix` for machine-applicable fixes
    first, then add module-level
    `#![expect(clippy::x, reason = "legacy: fix when touched")]` to each file
    that still fails, so `-D warnings` passes.
32. Done: `rustfmt.toml` with stable options only: `use_field_init_shorthand =
    true`, `use_try_shorthand = true`. Add `cargo fmt --all --check` to CI.
33. Errors: add `thiserror`; typed errors in `registry.rs`, `config.rs` and
    red-zone utils; map them to the exit code table in `main.rs`; `hint:`
    output in the logger; custom panic hook. Add `[profile.release]`
    (`lto = "thin"`, `codegen-units = 1`, `strip = true`, `opt-level = 3`).
34. (red zone) `safe_join` path helper with symlink rejection,
    `ProjectRelPath` and `Sha256Hex` newtypes, atomic writes via
    `NamedTempFile::new_in(parent)` + `persist` for every write into a
    user's project. Tests first, including Windows paths.
35. (red zone) Shared HTTP client: connect and total timeouts,
    `User-Agent: justui/<version>`, retry with backoff for GET (connect
    errors, timeouts, 5xx), `https://` only except local paths and localhost.
36. (red zone) Async migration: `tokio` (minimal features) + async `reqwest`,
    bounded parallel downloads (`JoinSet` + `Semaphore`). Watch the
    `list` TUI path that installs from inside the UI. Do this after 35.
37. Output: global `-v`/`-vv`; one color-decision function (`NO_COLOR`,
    `CLICOLOR_FORCE`, `--no-color`, TTY); non-TTY prompts fail with exit 2;
    `"version"` field in every `--json` output and its shape documented in
    the docs site. Replace the 15 raw `println!`/`eprintln!`.
38. clap: `ValueEnum` for preset, color space and dart target (none today);
    `Cli::command().debug_assert()` test.
39. Config: `version` field with a migration hook; warn on unknown fields.
    Replace `serde_yaml` 0.9 with a maintained fork after checking its
    status (candidates: `serde_yaml_ng`, `serde_norway`; not `serde_yml`).
40. Tests: dev-dependencies `insta`, `proptest`, `wiremock` (wiremock needs
    tokio, so after 36; use blocking-friendly `mockito` if tests are needed
    earlier). `assert_cmd` tests per subcommand: happy path, failure exit
    code, `--json`, no TTY. Move test modules over ~150 lines to
    `<name>_tests.rs`; keep small ones inline.
41. CI: run `cargo test` on `windows-latest` too, build-only on macOS;
    `cargo llvm-cov` with a minimum line coverage for red-zone modules (set
    the first threshold at the measured value, round down).
42. Supply chain: replace `cargo audit` with `cargo deny` (`deny.toml` with
    advisories, licenses, bans, sources). Decide yourself whether the
    existing `RUSTSEC-2025-0141` (bincode) ignore moves to `deny.toml` with
    its justification; the rules forbid agents adding new ignores. Then
    update the Rust row in `AGENTS.md` section 6 to the command list at the
    end of `rust-cli.md` (the security rules already name `deny.toml`).
43. Done: Remove `dialoguer` from `Cargo.toml`: it has zero uses in `src/`.
    Remaining: `cargo machete` in CI.

## Docs rules (questionnaire 2026-10-05; `docs-web.md` assumes these)

Items 6, 7, 8 and 12 above still apply. These are the additions.

44. `tsconfig.json`: add `noFallthroughCasesInSwitch` and
    `verbatimModuleSyntax` (with item 7's `noUncheckedIndexedAccess`).
45. ESLint, with a legacy `eslint-disable ... -- legacy: fix when touched`
    for existing violations so lint passes:
    - `parserOptions.projectService: true` and
      `tseslint.configs.recommendedTypeChecked`, plus `no-floating-promises`,
      `no-misused-promises`, `switch-exhaustiveness-check`,
      `prefer-nullish-coalescing`.
    - `consistent-type-assertions` (`assertionStyle: 'never'`),
      `no-non-null-assertion` (error), `consistent-type-definitions`
      (`interface`; the translation dictionaries currently use `type X = {`),
      `consistent-type-imports`, `import/order`.
    - `explicit-module-boundary-types` and `jsdoc/require-jsdoc`
      (`publicOnly`) for `src/lib/**`.
    - `import/no-default-export` with overrides for Next special files and
      configs; `no-restricted-imports` for `../`; `no-restricted-properties`
      for `process.env` outside `src/lib/env.ts` and configs;
      `no-restricted-syntax` for `TSEnumDeclaration` and the `'use server'`
      directive.
    - `max-lines` 200 for `src/components/**/*.tsx`, `max-lines-per-function`
      80 (skip blank lines and comments).
    - `react-hooks` v7 `recommended` config and `exhaustive-deps` as error.
    - Test overrides: allow assertions and non-null in `test/` and `e2e/`.
46. `src/lib/env.ts` (zod-parsed); move the 3 current `process.env` reads
    (`site.ts`, `github.ts`, `providers/theme-provider.tsx`) to it.
47. `src/lib/result.ts` with the `Result<T, E>` union and small helpers.
48. Translation modules: dictionary `interface` +
    `satisfies Record<Locale, Dict>`.
49. Move the inline MDX `components={{...}}` map from
    `src/app/[lang]/docs/[[...slug]]/page.tsx` into one exported module.
50. `format:check` script (`prettier --check .`) and a CI step for it.
51. Tests: add `@axe-core/playwright` (approved) and axe checks on main
    pages in 4 preset/theme combinations; keyboard tests for dialogs, search
    and Studio; `expect.toHaveScreenshot` defaults in `playwright.config.ts`
    (`maxDiffPixelRatio: 0.01`, `animations: 'disabled'`); coverage
    thresholds for `src/lib` in `vitest.config.ts` (start at the measured
    value); `expectTypeOf` tests for generated data and i18n helpers.
52. Snippet validation (with item 12): a CI job that extracts Dart snippets
    into a scratch Flutter project created by the CLI and runs
    `dart analyze`.
53. Bun: `"packageManager": "bun@<version>"` in `apps/docs/package.json` and
    the CI setup step reading it (check that `oven-sh/setup-bun` supports
    `bun-version-file` with `package.json` in the pinned action version).
54. Renovate: `renovate.json` with weekly grouped updates for bun/npm,
    cargo, pub and GitHub Actions. Installing the Renovate app is manual.
55. Bundle budget: per-route JS budget checked after `bun run build`. Verify
    first what Next 16 still prints: recent versions dropped the per-route
    size columns, so the script may have to read the build manifests.
56. Route handlers: explicit route config exports, `Content-Type` and
    `Cache-Control`, zod-parsed query params with 400 on bad input.

## Security (questionnaire 2026-10-05, evening; `security*.md` assume these)

Do item 57 first, before every other setup item. Red-zone items need a plan
and tests first. Items 3 and 4 above (ignore `.agents/tmp/`, move
`justui-audit.md` there) are confirmed: delete it from HEAD, keep history.

57. (red zone, do first) Registry input validation in `registry.rs`,
    `add.rs` and `pubspec_editor.rs`, test-first with hostile `index.json`
    fixtures: component names `^_?[a-z][a-z0-9_-]*$` (the `_shared_*`
    internals need the leading underscore), file names `^[a-z0-9_]+\.dart$`,
    relative registry paths without `..`; target paths must stay inside the
    install dir (a minimal guard now, folded into `safe_join` by item 34);
    pub dependency name and constraint validation plus a confirmation list
    before editing `pubspec.yaml`; `registryDependencies` must exist in the
    index, no cycles; response size cap. Add `clippy::join_absolute_paths`.
58. (red zone) Default registry URL pinned to the tag of the running CLI
    (`v` + `CARGO_PKG_VERSION`). Trust prompt for non-default
    `registry_url`, stored per user (decide the config dir lookup without a
    new crate if possible, or ask for `dirs`), `--trust-registry` for
    non-TTY. `justui doctor` prints the registry source and trust state.
59. Workflows: pin every action to a full SHA with a version comment;
    `permissions: {}` at the top, minimal per job; `persist-credentials:
    false`; no caches in `release.yaml`; release builds with
    `cargo auditable build --release --locked` (install the tool pinned);
    `bun ci` everywhere; release jobs use `environment: release`; add a
    `zizmor` job (fail on high). Do this before turning on the SHA-pinning
    repo setting (item 69) or CI breaks.
60. (red zone) Attach `install.sh` and `install.ps1` to every release. The
    docs routes serve `releases/latest/download/install.{sh,ps1}`; replace
    the `main` URLs in `upgrade.rs`, README and docs snippets with the docs
    route.
61. (red zone) Install scripts: run `gh attestation verify <archive> --repo
    infinitedim/justui` when `gh` is installed and logged in; otherwise
    print that it was skipped.
62. Renovate: `renovate.json` with weekly grouped updates for cargo, bun,
    pub and GitHub Actions, `minimumReleaseAge: "7 days"`, action digests
    with version comments, vulnerability alerts without delay. Remove the
    version-update config in `.github/dependabot.yaml` (keep Dependabot
    alerts and security updates on in settings). `bunfig.toml`:
    `minimumReleaseAge = 604800` (check the section name in the Bun docs for
    the pinned Bun version).
63. Hidden-Unicode check: a small dependency-free Dart script in `tools/`
    run by CI over all tracked text files; rejects bidi controls and
    zero-width characters (BOM only allowed at offset 0).
64. Docs: Vitest test that locks security headers and the CSP baseline;
    `public/.well-known/security.txt` (Contact = the repo's advisory page,
    Expires under a year) plus a test that fails 30 days before Expires;
    `/api/search` query length cap with 400.
65. Rate limit for `/api/search`: check whether the Vercel plan in use
    offers WAF rate limiting; if not, Upstash needs a new dependency and an
    env secret (approval). Pick one and document it in `security.md`.
66. Done: `SECURITY.md`: GitHub private vulnerability reporting as the only
    channel (drop `support@justui.dev`), best-effort response wording,
    supported versions = latest release.
67. Done: Remove `.agents/skills/cc-skill-security-review` (replaced by
    `justui-security`).

## Security settings (do these yourself on GitHub and in Antigravity)

68. Settings > General: enable immutable releases. First change
    `release.yaml` so the release is created as a draft, all assets are
    uploaded, and only then published: assets cannot be added to a
    published immutable release. Check how the pinned
    `softprops/action-gh-release` version orders create and upload.
69. Settings > Actions: require actions to be pinned to a full-length commit
    SHA (after item 59).
70. Rulesets: (a) tags `v*`: restrict creations, updates and deletions to
    you, block force pushes. (b) `main`: block force pushes and deletion,
    require CI status checks, require a pull request with review. You
    cannot approve your own PR, so add yourself to the bypass list (or set
    required approvals to 0 and rely on the PR plus checks). The
    `apply-changesets` job pushes straight to `main` with `GITHUB_TOKEN`,
    which this ruleset will reject: either let it open a PR instead, or add
    the GitHub Actions app to the bypass list (weaker).
71. Environment `release`: you as required reviewer, deployment limited to
    `v*` tags.
72. Code security: confirm secret scanning, push protection, Dependabot
    alerts, Dependabot security updates and private vulnerability reporting
    are on.
73. `PROJECT_PAT`: fine-grained, this repo only, Projects permission only,
    90-day expiry. Check that fine-grained tokens support the owner type of
    project 2; if not, use a classic token with only the `project` scope and
    the same expiry.
74. Antigravity: terminal allowlist as listed in `security-agent.md`
    (Commands); everything else on review.
75. While agents work, `.env.local` holds dummy values only; real values
    live in Vercel.
76. `index.json` signing is not planned (registry is pinned to release
    tags instead). If you add it later, the rule in
    `security-supply-chain.md` (Ed25519 key in the `release` environment)
    applies.

## Team mode (2026-10-06; `orchestration.md` and `.agents/agents/` assume these)

77. Item 3 is done (`.agents/tmp/` added to `.gitignore` on 2026-10-06), so
    run folders, screenshots and reports stay out of git. Item 4 (move
    `justui-audit.md` there) is still open.
78. Use the Antigravity 2.0 app or the CLI for team mode. A 2026-08 report
    says custom agents do not run in the IDE yet; check your version. Select
    `orchestrator` as the main agent.
79. Run the probe once: ask the orchestrator for a setup check (invoke the
    `probe` subagent) and show `.agents/tmp/runs/probe/report.md`. It tells you whether
    subagents see `AGENTS.md` and the always-on rules, the exact tool names,
    and whether the `skills:` paths in `.agents/agents/*.md` resolve.
80. From the probe report: if the `skills:` entries did not resolve, change
    them to the form the probe lists. Optionally add `tools:` lists to
    `researcher`, `research-reviewer` and the reviewers so they are read-only
    by configuration, not only by instruction. Copy tool names exactly; a
    misspelled tool name can hang a subagent.
81. Run tasks 1-8 of `.agents/evals/team-eval.md` (solo vs team) and adjust
    the split test in `orchestration.md` from the results.
82. Commits: the orchestrator commits each unit before review, so team runs
    make more local commits than before. `git add` and `git commit` are not
    on the auto-run list in `security-agent.md`, so each one asks you. Either
    accept the prompts or add those two (never `git push`) to the Antigravity
    terminal allowlist; if you add them, update `security-agent.md`
    (Commands) in the same commit.

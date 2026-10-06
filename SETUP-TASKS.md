# Setup tasks that the new rules assume

The rules describe the target state. These changes make the repo match it.
Each item is one task; most fit one commit. Items marked (red zone) need a
plan first under the new rules.

## Install the rules

1. Replace root `AGENTS.md` with the new one. Add `GEMINI.md`,
   `.agents/rules/*.md` and `.agents/skills/justui-design/SKILL.md`.
2. Remove `.agents/skills/taste-skill` (replaced by `justui-design`) and
   `.agents/skills/senior-architect` (already marked for removal).
3. `.gitignore`: add `.agents/tmp/`.
4. Move `justui-audit.md` out of the repo into `.agents/tmp/` (git-ignored).
   Note: deleting it from HEAD does not remove it from git history. Rewriting
   history needs a force-push, which the rules forbid for the agent; decide
   yourself whether it is worth it.
5. Fix `CONTRIBUTING.md` step 4 (barrel export) so the warning in `AGENTS.md`
   can be dropped later.

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

14. CI: run `bun run generate:components -- --check` in `nextjs-ci`.
15. CI: align the Bun pin with the `bun.lock` format (audit #62).
16. `tools/generate_checksums.dart --dry-run`: exit non-zero on drift so the
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
28. Release checksums and pinned install script URLs (supply chain items in
    `security.md`).

## Rust rules (questionnaire 2026-10-05; `rust-cli.md` assumes these)

The new crates and tools below were approved in the questionnaire. Each item
still needs a plan first, and items touching red-zone files follow
`security.md`.

Baseline measured on `development` (`667670c`) with rustc 1.97 and the
proposed lint set at default thresholds: 1139 clippy warnings across all
targets. Outside test files: about 300 `unwrap`/`expect`/`panic` calls, 242
`uninlined_format_args` (auto-fixable), 37 missing `# Errors`/`# Panics`
sections, 35 `must_use` suggestions, 7 functions over 100 lines (largest 351).

29. `rust-toolchain.toml`: pin the current stable version (check the Rust
    release blog; rustc 1.97 was installed in the sandbox) with components
    `clippy` and `rustfmt`. Set `rust-version` in `packages/cli/Cargo.toml`
    to the same version. Make CI install the pinned version instead of
    floating `stable`.
30. Edition 2024: `cargo fix --edition`, set `edition = "2024"`, run the full
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
32. `rustfmt.toml` with stable options only: `use_field_init_shorthand =
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
    update `security.md` (red zone and supply chain lines mention
    `.cargo/audit.toml`) and the Rust row in `AGENTS.md` section 6 to the
    command list at the end of `rust-cli.md`.
43. `cargo machete` in CI. Remove `dialoguer` from `Cargo.toml`: it has zero
    uses in `src/`.

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

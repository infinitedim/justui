---
trigger: model_decision
description: "Apply when handling external input, URLs, postMessage, storage, headers or CSP, secrets, dependencies, tool versions, CI, or the CLI install/upgrade/registry paths."
---

# Security

## Red zones (plan + approval + tests before any edit)

- CLI: `packages/cli/src/commands/{add,update,diff,upgrade}.rs`,
  `src/registry.rs`, `src/utils/{pubspec_editor,theme_editor,import_rewriter,constructor_transpiler}.rs`
- Install scripts: `packages/cli/install/install.sh`, `install.ps1`, and the
  docs routes that serve them: `apps/docs/src/app/install.sh/route.ts`,
  `apps/docs/src/app/install.ps1/route.ts`
- Registry and checksums: `registry/`, `tools/generate_checksums.dart`
- Headers and CSP: `apps/docs/next.config.ts` `headers()`, `apps/docs/vercel.json`
- CI and release: `.github/workflows/`, `tools/apply_changesets*`,
  `.cargo/audit.toml`
- The inline preset script in `apps/docs/src/app/layout.tsx`

## Never weaken a check

Do not remove, skip, loosen or bypass: checksum or signature verification,
binary magic-byte or architecture checks, input validation, origin checks,
CSP directives, `cargo audit`, lint or type rules. If a check blocks you,
stop and report. Making something "work" by weakening a check is a failed
task.

## External input

Everything that crosses a trust boundary is parsed before use:
URL path segments (`[lang]`, slugs), search params (Studio state), form input,
`postMessage` data, `localStorage`/`sessionStorage`, fetched JSON, registry
JSON, user `pubspec.yaml` and `justui.config.yaml`.

- Web: parse with a zod schema or an explicit whitelist (like
  `src/lib/theme/url-serializer.ts`). Invalid input falls back to a default
  or returns `notFound()`. Never a 500.
- Storage access is wrapped in try/catch; storage can throw or be empty.
- `postMessage`: check `event.origin` and parse with the schema in
  `src/lib/stage-bridge.ts`. Send with an explicit target origin. Do not add
  new `'*'` target origins; the existing `'*'` fallback for opaque origins in
  `stage-bridge.ts` gets revisited when the Flutter embed lands.
- Rust: validate before writing anything to the user's disk; paths stay
  inside the project root (no `..` escape after normalization).
- No `dangerouslySetInnerHTML` with anything that is not a constant string you
  wrote. No `eval`, `new Function`, or HTML built from user input.

## CSP, headers, secrets

- Do not add domains, `unsafe-*` keywords, inline scripts or new
  `frame-src`/`connect-src` entries without approval. If a feature needs one,
  put the exact CSP diff in the plan.
- `'unsafe-inline'` in `script-src` exists only for theme and preset
  bootstrapping. Do not rely on it for new code.
- Never hardcode secrets, tokens or keys. Read them from typed env. Never log
  env values or full request headers. Never commit `.env*` files.

## Supply chain

- New dependencies (npm, pub, cargo) and version bumps need approval. The
  plan names the package, version, why, size or license impact, and the
  no-dependency alternative.
- `packages/core` and `packages/tokens` never get third-party dependencies.
- Prefer exact or caret-locked versions already used in the repo. Commit the
  lockfile change in the same commit as the manifest change.
- Install scripts and routes that serve them must point to a pinned release,
  not a moving branch, once releases publish checksums. Until then, do not
  make them fetch from additional locations.
- Never add `ignore` entries to `.cargo/audit.toml`, `overrides` or
  `resolutions` to hide a vulnerable package. Report the advisory instead.

## Tool versions

Flutter is pinned in `.fvmrc` and CI (`flutter-version`), Bun in CI
(`bun-version`). Do not change a tool version unless that is the task. When
it is, change every place together (`.fvmrc`, CI, lockfiles) and verify the
lockfile still installs with the pinned version.

## Security findings

- Write audit or vulnerability findings only to a git-ignored location
  (for example `.agents/tmp/`). Never commit them, never paste exploit
  details into commit messages, PR text, changesets or docs.
- Report findings to the user in the task summary.

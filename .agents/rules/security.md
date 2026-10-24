---
trigger: model_decision
description: "Apply when handling external input (registry JSON, config, URLs, postMessage, storage), file writes into user projects, headers or CSP, secrets, or any red-zone path."
---

# Security

Three files cover security. This one: threat model, red zones, input and
output safety, web hardening, findings. `security-supply-chain.md`: CI,
release, dependencies, secrets in the repo. `security-agent.md`: how you, the
agent, treat untrusted content. Each rule says why.

## Threat model

What we protect, in order:
1. The machines and projects of people who run the `justui` CLI. The CLI
   downloads code, writes files and edits `pubspec.yaml`, so a bad registry
   or a bad release reaches every user.
2. The release pipeline and the maintainer's GitHub account. Whoever controls
   them controls (1).
3. Visitors of the docs site (XSS, clickjacking, script injection).
4. The developer machine the agent runs on (credentials, git config, shell).

Who attacks, and how:
- A compromised or malicious registry, including a custom `registry_url`
  that a cloned project's `justui.config.yaml` points to.
- A stolen token or moved tag that publishes a fake release (the Trivy
  incident, March 2026: 76 of 77 tags force-pushed with a leftover token).
- A hijacked dependency (npm worms such as Shai-Hulud, compromised actions).
- Pull requests, issues and fetched content that carry instructions for an
  agent, including hidden Unicode.

## Red zones (plan + approval + tests before any edit)

- CLI: `packages/cli/src/commands/{add,update,diff,upgrade}.rs`,
  `src/registry.rs`, `src/config.rs`, the path helper (`safe_join`),
  `src/utils/{pubspec_editor,theme_editor,import_rewriter,constructor_transpiler}.rs`
- Install scripts `packages/cli/install/install.{sh,ps1}` and the docs routes
  that serve them (`apps/docs/src/app/install.{sh,ps1}/route.ts`)
- Registry and checksums: `registry/`, `tools/generate_checksums.dart`
- Docs: `next.config.ts` `headers()`, `vercel.json`, `src/lib/env.ts`,
  `public/.well-known/security.txt`
- CI, release and repo config: `.github/`, `tools/apply_changesets*`,
  `deny.toml`, `rust-toolchain.toml`, `bunfig.toml`, `renovate.json`
- Flutter bridge: `apps/docs/src/lib/flutter-bridge/`,
  `apps/docs/src/components/molecules/live-part/`,
  `apps/showcase/lib/bridge/`, `apps/showcase/web/`, and the bundle build
  scripts `apps/docs/scripts/{build-flutter.ts,vercel-build.sh,flutter-cache-key.ts}`
- Agent instructions: `AGENTS.md`, `GEMINI.md`, `.agents/` except the
  git-ignored scratch folder `.agents/tmp/` (see
  `security-agent.md`)

## Never weaken a check

Do not remove, skip, loosen or bypass: checksum or signature verification,
binary magic-byte, architecture or size checks, input validation, origin
checks, trust prompts, CSP directives or security headers, `cargo deny`,
secret scanning, zizmor, lint or type rules, or the tests that lock any of
these. If a check blocks you, stop and report. Making something "work" by
weakening a check is a failed task.

## Registry input (CLI)

Treat everything from a registry as hostile, including the default one.
Validate before any value reaches a path, a URL, a file or `pubspec.yaml`:

- Component names match `^_?[a-z][a-z0-9_-]*$`. File names match
  `^[a-z0-9_]+\.dart$`: no separators, no `..`, never absolute. Registry
  paths are relative, use `/` only, and contain no `..` segment.
- The final target path is built only through `safe_join` and must stay
  inside the configured install directory (`clippy::join_absolute_paths`
  catches the classic `Path::join` mistake). Why: `Path::join` with an
  absolute or `..` path silently escapes the project.
- Pub dependencies requested by a component: name matches
  `^[a-z_][a-z0-9_]*$`, constraint is a plain semver constraint (no git, path,
  url, hosted, newline or quote). Show the full list and ask before editing
  `pubspec.yaml`; non-TTY needs `-y`. Why: the value lands in YAML, so an
  unescaped string can add arbitrary dependencies.
- Registry dependencies (`registryDependencies`) must name components that
  exist in the same index; detect cycles.
- Downloads have a size cap and a timeout; `index.json` is rejected if it is
  not valid against the expected shape.
- The default registry is the release tag that matches the CLI version
  (`.../v<version>/registry`), never `main`. Why: release tags are immutable,
  `main` is not, and the components must match the CLI that installs them.
- A non-default `registry_url` shows the URL and asks for trust once per URL.
  Trust is stored in a user-level file (not in the project), and non-TTY runs
  need `--trust-registry`. Only `https://`, local paths and localhost are
  accepted. Why: a cloned project must not be able to switch the code source
  silently.

## Files and processes on the user's machine

- Writes into a user project go through `safe_join` and are atomic (see
  `rust-cli.md`). Never write outside the project root, never follow a
  symlink out of it.
- The CLI never runs shell commands built from registry or config values,
  and never runs `flutter pub get` or similar without the user asking.
- Backups (`.bak`) stay next to the original and are mentioned in output.

## Web input (docs)

Everything that crosses a trust boundary is parsed before use: URL segments
(`[lang]`, slugs), search params, route handler query params,
`postMessage` data, `localStorage`/`sessionStorage`, fetched JSON.

- Parse with zod or an explicit whitelist (like `isPreset` in
  `src/lib/presets.ts`). Invalid input falls back to a default,
  `notFound()` or a 400. Never a 500.
- Storage access is wrapped in try/catch; it can throw or be empty.
- `postMessage`: none today. Any new use checks `event.origin`, parses
  every message with a zod schema, and sends with an explicit target
  origin. No `'*'` targets.
- Flutter bridge (JS interop between the docs page and `apps/showcase`):
  the Flutter loader and the Dart controller stay private to the bridge
  module. The bridge adds no globals (Flutter's own `_flutter` and
  `_flutter_skwasmInstance` are the only ones) and uses no `postMessage`.
  Every value is validated twice: `zod/mini` in TS before it is sent and a
  whitelist in Dart when it arrives. Free text (playground labels) is
  printable ASCII with a length cap.
- No `dangerouslySetInnerHTML` except constant strings you wrote. No `eval`,
  `new Function`, or HTML built from input.
- `/api/search`: query length is capped and over-long queries get a 400; the
  endpoint is rate limited (Vercel WAF or Upstash, see setup tasks). Keep the
  CDN cache headers.

## Headers and CSP

- A Vitest test locks the security headers and the CSP baseline: every
  header present, and no new source, scheme or keyword in any directive
  without changing that test. A CSP change therefore shows up as a test diff
  that needs approval.
- Do not add domains, `unsafe-*` keywords, inline scripts or new
  `frame-src`/`connect-src` entries without approval; put the exact CSP diff
  in the plan.
- `'unsafe-inline'` in `script-src` stays (the App Router inline RSC payload
  and the next-themes bootstrap need it without nonces; nonces would make every page
  dynamic). New code must not rely on it.
- `worker-src 'self' blob:` exists for the Flutter bridge: multi-threaded
  skwasm starts its workers from `blob:` URLs, and the site is already
  cross-origin isolated (COOP/COEP). It allows no other origin.
- `/.well-known/security.txt` exists with `Contact` (the GitHub advisory
  page) and `Expires` under one year away. A test fails 30 days before
  `Expires`; renewing it is a normal task.

## Secrets

- Never hardcode secrets, tokens or keys. Read them through `src/lib/env.ts`
  (docs) or the environment (CLI, CI).
- Never print or store a secret: not in logs, error messages, CLI `--json`
  output, test snapshots, artifacts, commit messages or PR text. Never log
  env values or full request headers.
- Never commit `.env*` files. `.env.example` holds names and dummy values
  only.
- The CLI sends `GITHUB_TOKEN` only to `api.github.com`, never to a registry.

## Framework advisories

A critical or high advisory in a framework the docs or CLI run on (Next.js,
React, Fumadocs, reqwest, rustls, and similar) is patched within 48 hours,
bypassing the update cooldown. Example: CVE-2025-55182 (React2Shell, Dec
2025). Everything else follows the update bot's schedule.

## Security findings

- Write audit or vulnerability findings only under `.agents/tmp/`
  (git-ignored). Never commit them; never put exploit details in commit
  messages, PR text, changesets, docs or issue comments.
- Report findings to the user in the task summary: what, where, severity,
  and the proposed fix. Public disclosure happens only through a GitHub
  security advisory (see `SECURITY.md`).

---
trigger: glob
globs: ".github/**, Cargo.toml, Cargo.lock, deny.toml, rust-toolchain.toml, .cargo/**, package.json, bun.lock, bunfig.toml, apps/docs/package.json, renovate.json, pubspec.yaml, pubspec.lock, packages/cli/install/**, apps/docs/src/app/install.*/**, tools/**, SECURITY.md"
description: "Supply chain security: GitHub Actions, the release pipeline, registry distribution, dependencies, update bots, secrets in the repo, tool versions."
---

# Supply chain security

Read `security.md` first for the threat model. Each rule says why. Some
controls live in GitHub repo settings that agents cannot change; they are
listed at the end so you know they exist and can report drift.

## GitHub Actions

- Every `uses:` is pinned to a full 40-character commit SHA with the version
  as a comment: `uses: actions/checkout@<sha> # v7.0.1`. Never a tag or a
  branch (`@stable`, `@cross`, `@v2`). The repo setting "require SHA
  pinning" enforces this. Why: tags and branches can be moved by whoever
  controls the action repo; a SHA cannot.
- Verify a new SHA comes from the action's own repository and matches the
  tag in the comment. An update whose SHA changes but whose tag does not is
  a red flag (moved tag): stop and report.
- Every workflow starts with `permissions: {}` and each job asks only for
  what it needs. `contents: write`, `id-token: write` and
  `attestations: write` exist only in the release jobs that use them. Why:
  a compromised step can only use the token its job has.
- `actions/checkout` uses `persist-credentials: false`, except in the one job
  that pushes, which says why in a comment.
- No `pull_request_target`, no `workflow_run` that checks out PR code, no
  `issue_comment` triggers that run code. Fork PRs never get secrets.
- Never interpolate `${{ github.event.* }}`, `github.head_ref` or other
  attacker-controlled context directly in `run:`. Pass it through `env:` and
  quote it: `env: TITLE: ${{ ... }}` then `"$TITLE"`. Why: script injection.
- No `actions/cache` (or tool `cache: true`) in release workflows. Why: a
  poisoned cache from another run would flow into the shipped binary.
- No writes to `GITHUB_ENV`/`GITHUB_PATH` from untrusted values.
- `zizmor` runs in CI and fails on high findings. Never silence a finding
  without an inline `# zizmor: ignore[<audit>]` comment that says why.
- Secrets are referenced only in the job that needs them, never with
  `secrets: inherit`. `PROJECT_PAT` is a fine-grained PAT for this repo with
  Projects scope only and a 90-day expiry.

## Release pipeline

- Releases are created only from `v*` tags, through the `release`
  environment, which needs the maintainer's approval. Why: a leaked token
  cannot publish without that click.
- Release builds run `cargo auditable build --release --locked` on every
  target. `--locked` ships exactly the tested `Cargo.lock`; auditable embeds
  the dependency list so `cargo audit bin` and scanners can check installed
  binaries.
- Release jobs install JS dependencies with `bun ci` (frozen lockfile).
- Every release publishes: the archives, `SHA256SUMS`, build provenance
  attestations, and `install.sh`/`install.ps1` as release assets.
  Releases are immutable (repo setting): assets and tags cannot change after
  publishing, so the workflow creates a draft, uploads every asset, then
  publishes. A broken release is fixed by a new version, never by editing.
- The tag version must equal `packages/cli/Cargo.toml` (existing
  `validate-tag-version` job). Do not remove that guard.
- If `index.json` signing is added later, use an Ed25519 key stored as a
  secret of the `release` environment, with the public key embedded in the
  CLI. Do not add signing without a plan.

## Install scripts and distribution

- The docs routes `/install.sh` and `/install.ps1` serve the assets of the
  latest release (`releases/latest/download/...`), never a file from a
  branch. `upgrade.rs` and every doc snippet point to the docs route or a
  release asset, never to `raw.githubusercontent.com/.../main/...`. Why: a
  bad commit on `main` must not reach every new install.
- Install scripts verify `SHA256SUMS` and abort on any mismatch or missing
  entry. Keep that path hard-failing.
- If `gh` is installed and logged in, the scripts also run
  `gh attestation verify <archive> --repo infinitedim/justui` and abort on
  failure; otherwise they print one line saying attestation was skipped.
- The registry the CLI uses by default is the matching release tag (see
  `security.md`). Changing the default registry URL is a red-zone change.

## Dependencies

- New dependencies (npm, pub, cargo) and version bumps need approval. The
  plan names the package, version, why, size or license impact, and the
  no-dependency alternative.
- `packages/core` and `packages/tokens` never get third-party dependencies.
- Lockfiles are committed in the same commit as the manifest change. CI and
  release install with frozen lockfiles (`bun ci`, `cargo --locked`).
- New versions are taken only after 7 days: `minimumReleaseAge` in
  `bunfig.toml` for local installs, `minimumReleaseAge` in Renovate.
  Security fixes skip the wait. Why: most hijacked packages are found and
  pulled within days.
- Bun does not run dependency lifecycle scripts by default. Do not add
  `trustedDependencies` without approval and a comment saying why the
  package needs its script.
- Never add advisory ignores (`deny.toml`), `overrides` or `resolutions` to
  hide a vulnerable package. Report the advisory and propose the upgrade.
- Renovate opens version updates (grouped weekly, SHA-pinned action updates
  with version comments). Dependabot stays enabled for alerts and security
  updates only; there is no Dependabot version-update config.

## Secrets in the repo

- GitHub secret scanning and push protection are on. Never bypass push
  protection; if it blocks a push, the secret is real until proven otherwise:
  stop and report.
- A leaked secret is revoked first and removed second. Removing it from the
  history does not make it safe.
- `justui-audit.md` and any other findings live in `.agents/tmp/` (git
  ignored), never in the tree.

## Hidden Unicode

A CI test rejects bidi control characters (U+202A-U+202E, U+2066-U+2069) and
zero-width characters (U+200B-U+200D, U+FEFF outside a file start) in code,
workflows, `AGENTS.md`, `GEMINI.md` and everything under `.agents/`. Never
add an exception without approval. Why: hidden characters can make code or
agent instructions read differently from what reviewers see.

## Tool versions

Rust is pinned in `rust-toolchain.toml`, Flutter in `.fvmrc` and CI, Bun in
`packageManager`. Do not change a tool version unless that is the task. When
it is, change every place together and verify the lockfile still installs
with the pinned version.

The Vercel build downloads the Flutter SDK in
`apps/docs/scripts/vercel-build.sh`. That script pins the same version as
`.fvmrc` plus the SHA-256 of the official archive, and aborts on a mismatch.
Change the version there together with `.fvmrc` and CI. Font files in
`packages/tokens/assets/fonts/` come from the upstream releases named in its
README, with their SHA-256; a font change updates both.

## Repo settings (maintainer-managed, agents cannot change)

Report it if you notice one of these is off:
- Immutable releases on.
- Ruleset on `v*` tags: create, update and delete restricted to the
  maintainer; force push blocked.
- Ruleset on `main`: no force push or delete, CI status checks required, pull
  request with review required (the maintainer is on the bypass list).
  Automation that writes to `main` (changesets) opens a PR instead of
  pushing.
- Actions setting "require actions to be pinned to a full-length commit SHA".
- Environment `release` with the maintainer as required reviewer, deployable
  from `v*` tags only.
- Secret scanning, push protection, Dependabot alerts and security updates,
  private vulnerability reporting.

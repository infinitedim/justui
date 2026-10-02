# JustUI - Agent Rules (core)

This file is always active. It holds the rules that apply to every task.
Area rules live in `.agents/rules/` and load by file path or by task type.
Write and reply in English (chat replies, commits, code comments, docs).
Use plain ASCII in everything you write: no em dashes, curly quotes or emoji.
Keep chat replies casual and conversational (avoid being overly formal).

## 1. What JustUI is

JustUI is a Flutter UI component library distributed shadcn-style: users run the
`justui` CLI, which copies component source into their own project. It is a
polyglot monorepo:

| Path              | Stack                                           | Role                                                                   |
| ----------------- | ----------------------------------------------- | ---------------------------------------------------------------------- |
| `packages/tokens` | Dart                                            | Tokens, OKLCH/HSLuv color engines, motion, typography                  |
| `packages/core`   | Flutter                                         | Theme engine and components (4-file convention)                        |
| `packages/cli`    | Rust                                            | `justui` CLI: init, add, diff, update, preset, create, doctor, upgrade |
| `apps/docs`       | Next.js 16, React 19, Fumadocs, Tailwind 4, Bun | Docs site, catalog, Studio                                             |
| `apps/preview`    | Flutter + Widgetbook                            | Component workbench                                                    |
| `apps/showcase`   | Flutter                                         | CLI sandbox; `lib/core`, `lib/tokens`, `lib/widgets` are generated     |
| `registry/`       | JSON + Dart                                     | What the CLI downloads; generated from `packages/core`                 |
| `tools/`          | Dart, Bash                                      | Checksums, changesets                                                  |

## 2. Area rules (read the matching file before you edit)

| File                        | Loads when                                                                      |
| --------------------------- | ------------------------------------------------------------------------------- |
| `.agents/rules/workflow.md` | Always                                                                          |
| `.agents/rules/mcp.md`      | Always                                                                          |
| `.agents/rules/flutter.md`  | Files under `packages/core`, `packages/tokens`, `apps/preview`, `apps/showcase` |
| `.agents/rules/rust-cli.md` | Files under `packages/cli`                                                      |
| `.agents/rules/docs-web.md` | Files under `apps/docs`                                                         |
| `.agents/rules/design.md`   | Any UI, visual, copy or layout work                                             |
| `.agents/rules/security.md` | Input handling, headers, CSP, install/upgrade/registry, deps, CI                |
| `.agents/rules/sandbox.md`  | Only when you run in an offline or read-only-HOME sandbox                       |

If a task spans areas, read every matching file.

## 3. Skills

Pick skills by the path and the kind of task. Use at most 2 skills per task.
Do not load a skill "just in case".

| Task                                   | Skills                                         |
| -------------------------------------- | ---------------------------------------------- |
| Flutter component or token work        | `flutter-expert`, `ui-a11y`                    |
| Any UI or visual work (Flutter or web) | `justui-design`                                |
| Rust CLI                               | `rust-pro`                                     |
| Docs site code                         | `typescript-expert` or `senior-frontend` (one) |
| Docs i18n or copy                      | `i18n-localization`                            |
| SEO, metadata, sitemap                 | `nextjs-seo-indexing`                          |
| Security review                        | `cc-skill-security-review`                     |
| Dependency audit                       | `security-scanning-security-dependencies`      |
| Release, changelog                     | `changelog-generator`                          |
| Monorepo structure                     | `monorepo-architect`                           |

`taste-skill` is a generic landing-page skill and is not used in this repo.
`justui-design` is its JustUI fork.

## 4. Invariants (never break these)

1. Never remove, rename or reformat `// CLI:REGISTER_EXTENSIONS` in
   `packages/core/lib/src/theme/theme_data_material.dart`. The CLI uses it as
   an anchor to register component themes.
2. `packages/core` and `packages/tokens` have zero third-party pub
   dependencies. Flutter SDK only.
3. Never export component files from `packages/core/lib/just_ui_core.dart`.
   `CONTRIBUTING.md` step 4 says otherwise; it is wrong, do not follow it.
4. `registry/` is generated from `packages/core` by
   `tools/generate_checksums.dart`. Never hand-edit registry component files.
5. Never hand-edit `apps/showcase/lib/{core,tokens,widgets}` or any
   `*.generated.ts`. Regenerate them (see the area rules).
6. Every file under `apps/docs/src`, `apps/docs/content` and `apps/docs/test`
   must be 100% ASCII. `test/ascii-purity.test.ts` fails the build otherwise.
7. Never weaken a security check to make something pass (checksums, binary
   validation, CSP, input validation, audit ignores). See `security.md`.
8. Never commit audit or security reports, ad-hoc screenshots or scratch
   output. Playwright visual baselines next to their spec are the exception.

## 5. How to work (summary; details in `workflow.md`)

- Plan first, and wait for approval, when a change touches more than 3 files
  or any red-zone path (listed in `security.md`).
- Do only the task. Small same-kind fixes (lint, typo) in files you already
  touch are allowed if you list them. Report everything else, do not fix it.
- Ambiguity: ask only when the decision is hard to reverse (public component
  API, registry format, tool versions, CSP, deleting files). Otherwise pick the
  most reasonable reading and state it in your summary.
- Bug fixes are test-first: write a test that fails, then fix, then show it
  passes.
- Never skip, delete or loosen a failing test unless you prove the test is
  wrong and explain why in your summary.
- Commit locally after each working step using Conventional Commits. Never
  push. Never force-push. Never rewrite pushed history.
- User-facing changes to `just_ui_core`, `just_ui_tokens`, `justui_cli` or
  `docs` need a changeset (see `workflow.md`).
- Do not add, remove or upgrade any dependency (pub, npm, cargo) without
  approval. Do not change tool versions or lockfiles unless that is the task.
- Do not edit these rule files. Propose rule changes as a patch in your
  summary when you notice a rule is wrong or outdated.

## 6. Definition of done

A task is done only when the checks for every area you touched pass, and you
paste the command and its result in your summary. If a check cannot run in
your environment, say "not verified: <check> (<reason>)". Never claim a check
passed that you did not run.

| Area                     | Commands (run from repo root unless noted)                                                                     |
| ------------------------ | -------------------------------------------------------------------------------------------------------------- |
| Dart/Flutter             | `melos exec --flutter -- "flutter analyze ."` and `melos exec --flutter --dir-exists="test" -- "flutter test"` |
| Tokens (pure Dart tests) | `melos exec --no-flutter --dir-exists="test" -- "dart test"`                                                   |
| Registry sync            | `dart run tools/generate_checksums.dart --dry-run` (read the output: it can report drift and still exit 0)     |
| Formatting               | `dart format --set-exit-if-changed .`                                                                          |
| Rust CLI                 | `cargo clippy --all-targets --all-features -- -D warnings` and `cargo test --all-targets`                      |
| Docs                     | in `apps/docs`: `bun run lint`, `bun run type-check`, `bun run test`, `bun run build`                          |
| Docs UI                  | in `apps/docs`: `bun run test:e2e`                                                                             |
| Generated docs data      | in `apps/docs`: `bun run generate:components -- --check`                                                       |

## 7. Summary format at the end of every task

1. What changed (files, one line each).
2. Checks run, with results (or "not verified" with reason).
3. Assumptions you made.
4. Things you noticed but did not fix.
5. Proposed rule changes, if any.

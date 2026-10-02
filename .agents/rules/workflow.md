---
trigger: always_on
description: "How to plan, scope, test, commit and report any task in the JustUI repo."
---

# Workflow

## Planning

Write a plan and stop for approval before editing when the task:
- touches more than 3 files, or
- touches any red-zone path listed in `security.md`, or
- changes a public component API, the registry format, CSP or headers, a tool
  version, a lockfile, or deletes files.

A plan lists: the goal in one line, files to change, the approach, the tests
you will add, the checks you will run, and the risks. Use the
`sequentialthinking` tool to build the plan when there are several possible
approaches or more than two hypotheses for a bug.

For smaller tasks, start directly and state your assumptions in the summary.

## Scope

- Do the task you were given. Nothing else.
- Allowed extras: lint fixes, typos and dead imports inside files you already
  edit for the task. List them in the summary.
- Anything else you notice (bugs, smells, outdated docs, wrong rules): report
  it under "Things you noticed", do not fix it.
- Do not reformat files you did not otherwise change.

## Ambiguity

Ask before acting only when the decision is hard to undo:
public component API, registry or config schema, tool or SDK versions, CSP and
headers, deleting or moving files, anything in `security.md` red zones.
For everything else, choose the most reasonable reading, do it, and write the
assumption in the summary.

## Tests

- Bug fix: write a test that reproduces the bug and fails first. Run it and
  show the failure. Then fix. Then show it passes. This applies to every area
  (Dart widget tests, Rust tests, Vitest, Playwright).
- New behavior gets tests in the same change.
- New docs page or new component demo: add or update a Playwright visual
  snapshot test for it (see `docs-web.md`).
- A failing test may only be skipped, deleted or have its expectation changed
  if you show the test itself is wrong. Explain why in the summary.
- Never mark a check as passed if you did not run it. If a check cannot run
  (missing SDK, no display, no network), write `not verified: <check>
  (<reason>)`.

## Verification

Run the commands from the Definition of done table in `AGENTS.md` for every
area you touched. Paste the command and the relevant result. For UI work, also
do the visual check in `design.md`.

## Git

- Commit locally after each step that builds and passes its checks.
- Conventional Commits: `type(scope): subject`, imperative, lowercase subject,
  no trailing period. Types: feat, fix, refactor, perf, test, docs, style,
  chore, ci, build. Scopes: core, tokens, cli, docs, preview, showcase,
  registry, tools, ci, rules.
- One logical change per commit. Do not mix refactors with behavior changes.
- Never push. Never force-push. Never amend or rebase commits that already
  exist on the remote.
- Never commit: audit or security reports, ad-hoc screenshots, `.env*`
  files, scratch files, build output. Playwright visual baselines next to
  their spec are allowed.

## Changesets

User-facing changes need a changeset in the same commit series:
- `docs` package: `.changeset/<short-name>.md`
- `just_ui_core`, `just_ui_tokens`, `justui_cli`:
  `.changeset-polyglot/<short-name>.md`

```markdown
---
"just_ui_core": minor
---

One or two sentences describing the change for users.
```

Use `patch` for fixes, `minor` for new features or new components, `major` only
with approval.

## Single source of truth

- The component list, slugs, categories, files and dependencies come from
  `registry/index.json`. In the docs, use the generated data
  (`apps/docs/src/lib/components.generated.ts`) and regenerate it with
  `bun run generate:components`. Never type a component list by hand.
- When a fact already lives in code (versions, default paths, token values),
  read it from there or generate it. Do not copy it into a second place.

## Code shape (all languages)

- New files stay under 400 lines, new functions and methods under 60 lines.
  Existing large files are split only when you change them substantially.
- No swallowed errors. An empty `catch`/`catch (_)` or ignored `Result` is
  allowed only for an intentional fallback, with a comment saying what the
  fallback is and why it is safe.
- Comments explain why, not what. No narration, no duplicated doc comments.

## Rules maintenance

Do not edit `AGENTS.md`, `GEMINI.md` or anything in `.agents/rules/` or
`.agents/skills/`. If a rule is wrong, outdated or conflicts with the code,
add a "Proposed rule changes" section to your summary with the exact patch.

## Summary

End every task with the 5-part summary from `AGENTS.md` section 7.

---
name: justui-team
description: JustUI's planning and team procedure. Use for every Tier 1 or Tier 2 task (see .agents/rules/orchestration.md) - writing the detailed plan, deciding solo vs team, briefing researcher/coder/reviewer subagents, running the review loop and closing the task. Invoke as /justui-team to force a full plan and team assessment.
---

# justui-team

`orchestration.md` holds the rules (tiers, split test, approval, commits,
review, stop conditions). This skill is the procedure and the templates.
When they disagree, the rule wins.

Files in this skill:
- `references/plan-template.md`: the plan every Tier 1 and 2 task writes.
- `references/brief-template.md`: what every subagent receives, including
  the fix brief.
- `references/report-formats.md`: what every subagent returns.
- `references/research-basis.md`: why the rules look like this (for humans;
  you do not need to read it to do the work).

The team, defined in `.agents/agents/`:

| Agent | Does | Must not (by instruction) |
| ----- | ---- | ------------------------- |
| `orchestrator` | Plans, splits, briefs, commits units, adjudicates findings, runs final checks | Delegate the final verification |
| `researcher` | Answers one question with cited claims | Edit repo files |
| `research-reviewer` | Tries to refute each claim against its source | Add research beyond counter-evidence |
| `coder` | Implements one unit inside its allowed files | Commit, touch files outside the brief |
| `code-reviewer` | Tests the unit against the acceptance criteria, blind to the coder's reasoning | Edit source files or existing tests |
| `security-reviewer` | Runs the `justui-security` review on the diff | Edit source files or existing tests |
| `design-reviewer` | Runs the `design.md` visual and a11y check | Edit source files |
| `probe` | Reports what a subagent can see (setup check only) | Anything else |

Reviewers may add new test files that demonstrate a finding.

## Phase 1: Understand

1. Read the request twice. Write down what "done" means for the user in one
   line. If two readings lead to different work and the choice is hard to
   undo, ask now (`workflow.md`, Ambiguity). Otherwise pick one and record
   it as an assumption.
2. Read the code you will touch and the area rules for it. Find the tests
   that cover it. Check `SETUP-TASKS.md` when the task matches an item there.
3. If facts are missing (library behavior, a version, an external spec),
   list them as research questions. Repo code answers first; Context7 for
   library APIs; the web last.

## Phase 2: Plan

1. Run `sequentialthinking` (`mcp.md`).
2. Fill `references/plan-template.md`. Every acceptance criterion must be
   checkable by a command, a test or a file:line. "Works correctly" is not a
   criterion.
3. Build the step list with dependencies. Then run the split test from
   `orchestration.md` on it and pick the tier. Write the reason, including
   why you did not pick the other tiers. Tier 1 has a single unit, `U1`.
4. Record the base commit (`git log -1 --format=%H`) in the plan.
5. Save the plan to `.agents/tmp/runs/<YYYY-MM-DD>-<slug>/plan.md` and show
   it as an artifact. Apply the approval rule.

## Phase 3: Research (when the plan has research questions)

1. Answer single-source questions yourself. Give each independent question
   to its own `researcher`, in parallel, with a brief from
   `references/brief-template.md`.
2. When an answer drives a hard-to-undo decision (API choice, version,
   security behavior), send the report to a `research-reviewer` and act only
   on claims it marked Verified.
3. Other research may be used unreviewed; mark those claims "unreviewed" in
   the plan. Unsupported, Contradicted or Outdated claims become open points.
   Update the plan if the research changed it, and say what changed.

## Phase 4: Build

Tier 1: implement yourself following `workflow.md` (commit per step), or
brief one `coder` when the context you hold is already large.

Tier 2:
1. Check the split test again on the final unit table: allowed files must
   not overlap. Nothing enforces this except you.
2. Brief one `coder` per unit. Coders run file-level checks and the tests
   for their own files, not package-wide analyzers, dev servers or e2e.
3. While coders run, do not edit their files.
4. When a coder reports, check the report against the brief: files touched
   are inside the allowed list (`git status --porcelain`), claimed checks show
   output. A report that fails this goes back once with the gap named.
5. Re-run the unit's file-level checks and tests, then commit only that
   unit's files (`git add <files>`, Conventional Commit). Record the commit
   in the plan's unit table.
6. When every unit in a package is committed, run that package's analyzers
   (`flutter analyze`, `bun run lint`, `bun run type-check`). A failure goes
   to the unit that caused it as a fix round.

## Phase 5: Review

For each unit:
1. Brief a `code-reviewer` with the acceptance criteria and the commit range
   (`git diff <before>..<unit commit>`; the range includes new files). Do not
   pass the coder's report, and tell the reviewer not to open `reports/`.
2. Add `security-reviewer` when the diff touches a red-zone path or a trust
   boundary, and `design-reviewer` when it changes anything visible. Code
   and security reviewers run in parallel; anything that needs a dev server
   or app runs one at a time.
3. Adjudicate every finding as the rule says: confirmed, rejected or
   deferred. To confirm, re-run the evidence yourself (the failing test or
   the command). Write the decisions to `reviews/decisions.md`.
4. Confirmed findings go back to the same `coder` (or to you in Tier 1) as a
   fix brief (template in `brief-template.md`) that quotes the evidence. The
   coder may contest a finding only with counter-evidence; decide on the
   evidence.
5. Commit the fix, then re-review only the fix commit range plus the
   confirmed findings. Max 2 fix rounds per unit, then stop and report to
   the user.

## Phase 6: Close

1. Run the generators once (`tools/generate_checksums.dart`,
   `bun run generate:components`), then add changesets.
2. Review the generated diff yourself: only the expected files changed, and
   `generate_checksums.dart --dry-run` reports no drift. If `registry/`
   changed, give that diff to the `security-reviewer` too. Commit it.
3. Review tests: a test that demonstrated a confirmed finding stays, renamed
   to the normal test naming of its package. Other reviewer tests stay only
   if they add coverage the unit lacks (rename them too); delete the rest. No
   `*_review_test*` or `review_*` names in the final commits.
4. Run the Definition of done for every area touched (`AGENTS.md` section 6)
   on the whole repo, not per unit. Paste the results.
5. Walk the acceptance criteria one by one and point to the evidence for
   each. A criterion without evidence is not met.
6. Write the 5-part summary. Item 2 adds: agents used, review rounds,
   findings confirmed/rejected/deferred. Item 3 adds every assumption from
   the plan that turned out wrong.

## Effort guide

| Task shape | Typical setup |
| ---------- | ------------- |
| One question with a known source | You, no subagent |
| 2-5 independent questions | One researcher each; research-reviewer if a hard-to-undo decision depends on it |
| Change in one package, steps depend on each other | Tier 1: you + code-reviewer |
| Same change across many independent components, pages or packages | Tier 2: up to 4 coders, one reviewer each |
| Red-zone change | Tier 1 or 2 plus security-reviewer, always with approval |

## Common mistakes

- Splitting a sequential change because it is big. Big is not parallel.
- Passing the coder's summary to the reviewer "for context".
- Reviewing with `git diff <base>` on an uncommitted tree: new files are
  missing from it. Commit the unit first.
- Sending a reviewer's suspicion to the coder as if it were a finding.
- Letting two units edit the same generated file.
- Marking a criterion met because a subagent said so. Re-run it.

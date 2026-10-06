# Plan template

Copy this into `.agents/tmp/runs/<YYYY-MM-DD>-<slug>/plan.md` and fill every
section. Write "none" rather than deleting a section, so the reader knows you
thought about it. Keep it concrete: paths, names, commands.

```markdown
# Plan: <one-line goal>

Run folder: .agents/tmp/runs/<YYYY-MM-DD>-<slug>/
Base commit: <git log -1 --format=%H>
Tier: 0 | 1 | 2
Approval needed: yes | no (<which trigger>)

## 1. Request as understood
<One paragraph: what the user asked, in your words, and what done means for
them.>

## 2. Context read
- Files: <paths you read, with what you learned in a few words each>
- Rules: AGENTS.md, <area rule files>
- Skills: <skills you will use, max 2 besides justui-team>
- Existing tests that cover this: <paths, or "none">

## 3. Assumptions
- <Each assumption, and what changes if it is wrong.>

## 4. Out of scope
- <What you will not do, even if it looks related.>

## 5. Acceptance criteria
Each one is checkable. Say how it will be checked.
| ID | Criterion | Checked by |
| -- | --------- | ---------- |
| AC1 | <observable result> | <test name, command, or file:line> |

## 6. Research questions
| ID | Question | Why it matters | Where to look first |
| -- | -------- | -------------- | ------------------- |
<or "none">

## 7. Steps
| ID | Step | Files | Depends on | Unit | Check |
| -- | ---- | ----- | ---------- | ---- | ----- |
| S1 | <what> | <paths> | - | U1 | <command> |

## 8. Tier decision
- Split test: 1) independent units? 2) disjoint files? 3) each unit worth a
  handoff? 4) checkable separately (different packages, or file-level
  checks)? <answer each>
- Chosen tier and why. Why not the tier above and below.
- Units: U1 = S1, S2 (files ...); U2 = ... (Tier 1 is one unit, U1)
- Unit commits (filled in during the build): U1 = <sha>, U2 = <sha>
- Shared or generated outputs produced after merge: <list or none>
- Reviewers: code-reviewer <yes/no>, security-reviewer <yes/no: which red-zone
  path>, design-reviewer <yes/no>

## 9. Tests to add
- <Test file and case. Bug fix: the failing test comes first.>

## 10. Verification
- Definition of done commands for: <areas>
- Extra checks: <visual check, dry runs, manual steps>

## 11. Risks and rollback
| Risk | Likelihood | Impact | Mitigation |
| ---- | ---------- | ------ | ---------- |
Rollback: <how to undo: revert commits X..Y, regenerate Z>

## 12. Stop and escalate if
- <Task-specific stop conditions on top of orchestration.md.>

## 13. Changesets and commits
- Changesets: <package: patch|minor, or none>
- Commits: <planned Conventional Commit subjects in order>

## 14. Open questions for the user
- <Only hard-to-undo decisions. "none" is a fine answer.>
```

## Tier 0 short form

For Tier 0, write three lines in chat instead:

```
Goal: <one line>
File: <path>
Check: <command or what you will look at>
```

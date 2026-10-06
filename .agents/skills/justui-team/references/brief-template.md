# Brief template

Save each brief to `<run folder>/briefs/<agent>-<unit or question>.md` and
pass the path (and the same text) to the subagent. The subagent starts with
no memory of this conversation, so the brief must stand on its own.

```markdown
# Brief: <agent> - <unit or question id>

## Objective
<One or two sentences. What to produce and why it matters for the task.>

## Read first
- AGENTS.md
- <area rule files that match the files below>
- <skills to load, if any>
- Plan: <run folder>/plan.md (sections 5 and 7 only, unless told otherwise)
- <specific source files or reports>

## Inputs
- <paths, question text, or for reviewers the commit range:
  `git diff <before>..<unit commit>`>

## Scope
- May edit: <exact file paths, or "nothing outside the run folder">
- Must not touch: <paths, generated files, other units' files>
- Out of scope: <related things to leave alone>

## Acceptance criteria
<Copy the relevant rows from plan section 5, with their IDs.>

## Output
- Write to: <run folder>/<reports|reviews>/<file>.md
- Format: <section name> in .agents/skills/justui-team/references/report-formats.md

## Sources and tools (research and review)
- Look first in: <repo paths, Context7 library ids, official docs>
- Avoid: <sources that are known to be wrong or out of date>

## Stop and report back when
- The brief contradicts the code or the rules.
- You would need to edit a file outside "May edit".
- A check would have to be weakened to pass.
- You tried the same step twice without progress.
```

## Rules for the orchestrator when writing briefs

- One objective per brief. Two objectives mean two briefs.
- Name files, never "the relevant files".
- Reviewer briefs never include the coder's report, notes or reasoning, and
  say: "Do not open `<run folder>/reports/`."
- Paste acceptance criteria verbatim with their IDs, so findings can cite
  them.
- If a brief gets longer than about 80 lines, the unit is too big.

## Fix brief (after review)

Save as `briefs/coder-<unit>-fix<round>.md`.

```markdown
# Fix brief: <unit> round <1|2>

## Confirmed findings
| ID | Claim | Evidence (as re-run by the orchestrator) |
| -- | ----- | ---------------------------------------- |
| U1-code-1 | <claim> | <test name + failing output, or command + output> |

## Scope
- May edit: <same list as the unit brief, plus the reviewer test files named
  in the findings>
- Fix only these findings. Contest one only with counter-evidence.

## Output
Append a "Fix round <n>" section to your coder report: per finding, fixed or
contested, with the test or command output.
```

# BRIEFING — 2026-06-23T11:00:39+07:00

## Mission
Mengembangkan seluruh dokumen panduan (Getting Started, Tokens, Guides) dan halaman dokumentasi komponen UI (15 komponen) berbasis MDX dalam Bahasa Indonesia untuk website dokumentasi JustUI di apps/docs.

## 🔒 My Identity
- Archetype: orchestrator
- Roles: orchestrator, user_liaison, human_reporter, successor
- Working directory: /home/yourblooo/development/justui/.agents/orchestrator
- Original parent: main agent
- Original parent conversation ID: 94715ca9-59f4-47e9-a1ef-26f8440a7039

## 🔒 My Workflow
- **Pattern**: Project
- **Scope document**: /home/yourblooo/development/justui/.agents/orchestrator/PROJECT.md
1. **Decompose**: Decompose the project into milestones (E2E testing track & implementation track, and separate documentation tasks).
2. **Dispatch & Execute** (pick ONE):
   - **Delegate (sub-orchestrator)**: Spawn sub-orchestrators for milestones.
3. **On failure** (in this order):
   - Retry: nudge stuck agent or re-send task
   - Replace: spawn fresh agent with partial progress
   - Skip: proceed without (only if non-critical)
   - Redistribute: split stuck agent's remaining work
   - Redesign: re-partition decomposition
   - Escalate: report to parent (sub-orchestrators only, last resort)
4. **Succession**: Self-succeed at 16 spawns, write handoff.md, spawn successor.
- **Work items**:
  1. Initialize Project.md and plan.md [in-progress]
- **Current phase**: 1
- **Current focus**: Initialize project scope and planning

## 🔒 Key Constraints
- CODE_ONLY network mode: no internet access, no downloading external resources.
- Hard constraint: NEVER write, modify, or create source code files directly. We must delegate all work to subagents.
- Hard constraint: NEVER run build/test commands yourself — require workers to do so.
- We may use file-editing tools ONLY for metadata/state files (.md) in our .agents/ folder.
- Dynamic contrast enforcement/visual style presets (e.g. neobrutalism) rules from AGENTS.md must be followed if applicable.
- Forensic Auditor checks: if forensic auditor reports integrity violation, milestone fails.
- Never reuse a subagent after it has delivered its handoff — always spawn fresh.

## Current Parent
- Conversation ID: 94715ca9-59f4-47e9-a1ef-26f8440a7039
- Updated: not yet

## Key Decisions Made
- [TBD]

## Team Roster
| Agent | Type | Work Item | Status | Conv ID |
|-------|------|-----------|--------|---------|
| explorer_m1 | teamwork_preview_explorer | M1: Exploration & Code Analysis | completed | 4396cd7c-35b0-4453-8694-86eacd2abd96 |
| worker_m2 | teamwork_preview_worker | M2: General Guides MDX | completed | dee3ac46-3b86-4ca4-b9c7-fe7e14a569df |
| worker_m3 | teamwork_preview_worker | M3: Design Tokens MDX | completed | 293c5def-fd5d-4ac6-a8e5-42d9108dcb85 |
| worker_m4 | teamwork_preview_worker | M4: Advanced Guides MDX | completed | 6a29a3bb-6b52-474c-a07f-32a7cdb97baf |
| worker_m5 | teamwork_preview_worker | M5: Component Docs Part 1 | completed | 05295fa6-33fb-40d3-b68a-19934df74919 |
| worker_m6 | teamwork_preview_worker | M6: Component Docs Part 2 | completed | ab56d992-715e-4289-a822-e2ab2c6e623b |
| worker_m7 | teamwork_preview_worker | M7: Validation & Docs Build | completed | 811d79f2-c161-42ff-99f8-2c0e6da215ce |
| auditor_m7 | teamwork_preview_auditor | Forensic Integrity Audit | completed | 0e7296c1-252d-4d57-8732-98a3e8f05a59 |

## Succession Status
- Succession required: no
- Spawn count: 8 / 16
- Pending subagents: none
- Predecessor: none
- Successor: not yet spawned

## Active Timers
- Heartbeat cron: none
- Safety timer: none
- On succession: kill all timers before spawning successor
- On context truncation: run manage_task(Action="list") — re-create if missing

## Artifact Index
- /home/yourblooo/development/justui/.agents/orchestrator/ORIGINAL_REQUEST.md — Original request content
- /home/yourblooo/development/justui/.agents/orchestrator/plan.md — Orchestrator project plan
- /home/yourblooo/development/justui/.agents/orchestrator/progress.md — Heartbeat progress file

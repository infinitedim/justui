# Gemini (Antigravity) notes

`AGENTS.md` and `.agents/rules/` hold all project rules and apply to every
agent. This file only adds Gemini- and Antigravity-specific notes. It never
repeats or overrides a project rule.

- Read `AGENTS.md` first. When a task touches an area, read the matching
  `.agents/rules/*.md` file before your first edit, even if it was not
  auto-loaded.
- Antigravity shows rule files as pointers when the active rules exceed the
  token budget. If you see a pointer for an area you work in, open the file.
- Plan every task as `orchestration.md` says. For Tier 1 and Tier 2, work in
  planning mode, present the plan as an artifact, and also save it to the
  run folder so subagents can read it.
- Team mode needs custom agents (`.agents/agents/`), which run in the
  Antigravity 2.0 app and CLI. Select `orchestrator` as the main agent. If
  `invoke_subagent` or those agents are not available (for example in the
  IDE), use the fallback in `orchestration.md`.
- Workflows are deprecated in Antigravity; repeatable procedures are skills,
  invoked as `/<skill-name>` (for example `/justui-team`).
- Verify UI with the Playwright MCP tools as `mcp.md` describes. Do not use
  the built-in browser agent for verification.
- Reply in English or Bahasa Indonesia if user ask with Bahasa Indonesia (chat replies, commits, code comments, docs)

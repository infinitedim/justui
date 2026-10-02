# Gemini (Antigravity) notes

`AGENTS.md` and `.agents/rules/` hold all project rules and apply to every
agent. This file only adds Gemini- and Antigravity-specific notes. It never
repeats or overrides a project rule.

- Read `AGENTS.md` first. When a task touches an area, read the matching
  `.agents/rules/*.md` file before your first edit, even if it was not
  auto-loaded.
- Antigravity shows rule files as pointers when the active rules exceed the
  token budget. If you see a pointer for an area you work in, open the file.
- For tasks that need a plan (see `workflow.md`), work in planning mode and
  present the plan as an artifact before editing.
- Verify UI with the Playwright MCP tools as `mcp.md` describes. Do not use
  the built-in browser agent for verification.
- Reply in English.

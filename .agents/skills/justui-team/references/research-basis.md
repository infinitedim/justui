# Research basis

Why the orchestration rules look the way they do. This file is for humans
reviewing or changing the rules; agents do not need it to do the work.
"Preprint" means not peer-reviewed at the time of writing (2026-10).

| Rule | Evidence | Source |
| ---- | -------- | ------ |
| Split only parallel work; keep chains in one agent | Across 180 configurations, multi-agent setups gained up to +80.8% on decomposable tasks and lost 39-70% on sequential planning. Above ~45% single-agent accuracy, extra coordination tends to hurt. | Kim et al., "Towards a Science of Scaling Agent Systems", arXiv 2512.08296 (preprint) |
| One central orchestrator that verifies | Independent agents amplified errors 17.2x; centralized coordination with a validation step held it to 4.4x. | Kim et al., same |
| Coding is rarely parallel; teams cost tokens | Multi-agent research beat a single agent by 90.2% but used about 15x the tokens of a chat; most coding tasks have few truly parallel parts. | Anthropic, "How we built our multi-agent research system" (engineering blog, 2025) |
| Briefs name objective, output format, sources, boundaries | Vague subagent tasks caused duplicate work and gaps; these four fields fixed it. Effort should scale with task complexity. | Anthropic, same |
| Detailed plan with checkable criteria and stop conditions | 43.7% of multi-agent failures were system-design issues (ignoring the spec, repeating steps, not knowing when to stop) and 24.2% were verification failures. Objective-level verification added +15.6%; clearer roles added +9.4%. | Cemri et al., "Why Do Multi-Agent LLM Systems Fail?", arXiv 2503.13657 (preprint) |
| Plan before solving | Planning first reduced missing-step errors versus zero-shot chain of thought. | Wang et al., "Plan-and-Solve Prompting", ACL 2023, arXiv 2305.04091 |
| Fixed procedure and structured documents between roles | SOPs encoded in prompts and document-based handoffs reduced cascading errors versus free chat between agents. | Hong et al., "MetaGPT", ICLR 2024, arXiv 2308.00352 |
| Fixed phases over free-form agents | A three-phase pipeline (localize, repair, validate) beat open-source agents on SWE-bench Lite at about $0.70 per issue. | Xia et al., "Agentless", FSE 2025, arXiv 2407.01489 |
| Review must use external evidence | Self-correction without external feedback often made answers worse. | Huang et al., "Large Language Models Cannot Self-Correct Reasoning Yet", ICLR 2024, arXiv 2310.01798 |
| Same, with tools | Critique grounded in tools (search, code execution) improved results consistently. | Gou et al., "CRITIC", ICLR 2024, arXiv 2305.11738 |
| Reviewer blind to the coder; prefer a different model tier | LLM judges recognize and favor their own outputs, and the effect is causal. | Panickssery et al., "LLM Evaluators Recognize and Favor Their Own Generations", NeurIPS 2024, arXiv 2404.13076 |
| Reviewer writes tests from the spec, not from the code | A test designer that did not see the code reached 87.8-89.9% test accuracy versus 47.0-57.2% when one agent wrote both, with 2.4-4.5x fewer tokens than MetaGPT/ChatDev. | Huang et al., "AgentCoder", arXiv 2312.13010 |
| Findings need evidence; decide on evidence; cap rounds | Multi-agent debate did not reliably beat simple baselines such as self-consistency. | Zhang et al., "If Multi-Agent Debate is the Answer, What is the Question?", arXiv 2502.08788 (preprint); Smit et al., "Should we be going MAD?", ICML 2024 |
| Same | During debate, more agents switched from correct to incorrect answers than the reverse, under social pressure. | "Talk Isn't Always Cheap", arXiv 2509.05396 (preprint) |
| Small contexts; handoff through files | Models miss information placed in the middle of long contexts; performance drops as input grows even on simple tasks. | Liu et al., "Lost in the Middle", TACL 2024, arXiv 2307.03172; Chroma, "Context Rot" (technical report, 2025) |
| Shared memory in rule files, per-task memory in the run folder | Agent memory splits into working, episodic, semantic and procedural; rules are procedural memory every agent can load. | Sumers et al., "Cognitive Architectures for Language Agents", TMLR, arXiv 2309.02427 |
| Test the setup on ~20 real tasks | Small evaluation sets of about 20 real queries were enough to see large effects early. | Anthropic, multi-agent research system (above) |

## Antigravity facts this setup depends on

- Custom agents live in `.agents/agents/<name>.md` with YAML frontmatter
  (`name`, `description`, `model`: inherit/flash/pro, `tools`, `skills`,
  `subagent`, `mainAgent`, `commandExecutionPolicy`). The planner uses
  `description` to decide delegation. Subagents run concurrently, start
  without the parent's conversation, and inherit command prefixes, file
  scopes and sandbox settings. Source: antigravity.google/docs/subagents
- As of 2026-08, custom agents work in the Antigravity 2.0 app and CLI; the
  launch post says IDE support is "coming soon". Sources:
  antigravity.google/blog/introducing-custom-agents and atamel.dev, "Where
  does Antigravity look for Agents?"
- Workflows are deprecated in favor of skills by 2026-11-01; skills are
  invoked as `/<skill-name>`. Source: antigravity.google/docs/migration/workflows-to-skills
- Always-on rules share a 20,000-token budget; a rule file is capped at
  24 KB. Source: antigravity.google/docs/rules
- Not documented: whether subagents load `AGENTS.md` and `.agents/rules/`.
  The `probe` agent checks this; until then, every brief lists the rule
  files to read.

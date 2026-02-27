# Global Instructions

## Model Routing — Cost Optimization
Use the cheapest model that can handle the task. NEVER default to Opus for everything.

### When to use each model:
| Model | Use for | Cost reference |
|-------|---------|---------------|
| **Haiku** | File search, grep, glob, read-only exploration, doc generation, linting, simple refactors, test scaffolding, commit messages, boilerplate code | Cheapest (~60x less than Opus) |
| **Sonnet** | Multi-file edits, debugging, feature implementation, code review, architecture within a single project, API integration, test writing | Mid-range (default) |
| **Opus** | Cross-project refactors, novel problem-solving, complex multi-agent orchestration, security audits, critical architectural decisions, ambiguous or underspecified tasks | Most expensive — use sparingly |

### Enforcement rules:
- Subagents (Task tool) MUST specify `model: "haiku"` for: Explore agents, file searches, reading tasks, documentation
- Subagents MUST specify `model: "sonnet"` for: code writing, debugging, feature implementation
- Subagents use `model: "opus"` ONLY when: the task requires cross-cutting reasoning across 3+ files, or novel architectural decisions
- Default (no model specified) inherits parent — avoid this, always be explicit

## Multi-Agent Workflow
When a task has more than 2 subtasks, MUST use multiple agents (Task tool):
- One **commander agent** orchestrates the work and delegates to sub-agents
- Sub-agents execute their assigned tasks in parallel where possible
- Commander assigns exclusive file ownership to each agent (no overlaps)
- Commander reads all shared files first, passes context to each agent
- Commander handles shared file integrations after agents complete
- Sub-agents report back to the commander agent
- **Commander model**: Opus or Sonnet (based on task complexity)
- **Sub-agent model**: Haiku or Sonnet (based on subtask type — see table above)

## Context & Session Hygiene
- Use `/compact` based on **phase transitions**, not turn count:

| Transition | Compact? | Why |
|---|---|---|
| Research -> Planning | YES | Research is bulk data, the plan is the output |
| Planning -> Implementation | YES | Plan is already saved in files/todos |
| Debugging -> Next feature | YES | Debug traces pollute future decisions |
| After failed approach | YES | Clean dead-end reasoning from context |
| **Mid-implementation** | **NO** | You lose variable names, file paths, and decisions not written anywhere |

- Start a new session for unrelated tasks instead of continuing a long conversation
- CLAUDE.md files: keep under 250 lines. Move details to linked files if growing beyond that
- Prefer `Glob` and `Grep` directly over spawning Explore agents for simple, targeted searches (1-2 queries)
- Spawn Explore agents only when search requires 3+ queries or broad codebase understanding
- When reading files, use `offset` and `limit` for large files instead of reading everything

## Work Principles
- Read before edit — never modify code you haven't read
- Don't over-engineer — minimum viable change only
- No speculative abstractions — solve the current problem, not hypothetical future ones
- Prefer editing existing files over creating new ones
- No unsolicited docs, comments, or type annotations on untouched code

# Multi-Agent Pattern: Commander/Implementer

## The Problem
Serial code generation is slow. When you have 3+ independent changes (new feature + tests + docs, or parallel feature branches), Claude Code processes them one at a time. A 20-minute task could take 5 minutes with parallel agents.

## The Pattern

### Architecture
```
┌─────────────────────────────────────────┐
│         Commander Agent                  │
│  (Opus or Sonnet — based on complexity)  │
│                                          │
│  1. Reads all shared files               │
│  2. Creates task breakdown               │
│  3. Assigns exclusive file ownership     │
│  4. Launches implementer agents          │
│  5. Integrates results                   │
└──────┬──────────┬──────────┬─────────────┘
       │          │          │
  ┌────▼────┐ ┌───▼───┐ ┌───▼────┐
  │ Agent 1 │ │ Ag. 2 │ │ Ag. 3  │
  │ Haiku   │ │Sonnet │ │ Haiku  │
  │ file_a  │ │ b, c  │ │ tests  │
  └─────────┘ └───────┘ └────────┘
```

### Rules
1. **Exclusive file ownership** — Each agent owns specific files. No two agents touch the same file. This prevents merge conflicts and race conditions.
2. **Commander reads first** — The commander reads ALL shared files (package.json, types, interfaces) before delegating. It passes relevant context to each agent.
3. **Model routing** — Haiku for boilerplate/tests/simple edits, Sonnet for feature logic, Opus only for cross-cutting architectural decisions.
4. **Shared files handled by commander** — If multiple features need to update a shared file (e.g., index.ts exports, route registration), the commander does it AFTER all agents complete.

## When to Use It
- 3+ independent subtasks
- Files don't overlap between tasks
- Total work > 5 minutes serial

## When NOT to Use It
- Tasks with heavy file coupling (every change touches the same file)
- Simple bugs or single-file changes
- Fewer than 3 subtasks (overhead not worth it)

## CLAUDE.md Configuration
Add this to your `~/.claude/CLAUDE.md`:
```markdown
## Multi-Agent Workflow
When a task has more than 2 subtasks, MUST use multiple agents (Task tool):
- One **commander agent** orchestrates the work and delegates to sub-agents
- Sub-agents execute their assigned tasks in parallel where possible
- Commander assigns exclusive file ownership to each agent (no overlaps)
- Commander reads all shared files first, passes context to each agent
- Commander handles shared file integrations after agents complete
```

## Real Example

Task: "Add 4 new features to the app"

### Without multi-agent (serial):
```
Feature 1 → 5 min
Feature 2 → 4 min
Feature 3 → 3 min
Feature 4 → 5 min
Total: ~17 min
```

### With commander pattern:
```
Commander setup: 1 min
All 4 agents in parallel: ~5 min
Commander integration: 1 min
Total: ~7 min
```

Speedup: **2.4x** with 4 agents. Real measured result from a production project.

## Tips
- Always specify `model: "haiku"` or `model: "sonnet"` on subagents — don't let them inherit Opus
- Use `run_in_background: true` for truly independent agents
- Keep agent prompts focused — include ONLY the context they need, not the entire codebase
- If an agent needs output from another agent, don't parallelize — run sequentially

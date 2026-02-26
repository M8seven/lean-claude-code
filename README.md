# lean-claude-code

A minimalist, battle-tested Claude Code setup. No frameworks, no plugin bloat, no crypto tokens. Just what works.

## Philosophy

The Claude Code ecosystem has 100+ plugins, most of which burn tokens on context injection you don't need. Plugin fatigue is real, and so is the wasted context budget that comes with it.

The thesis: a lean setup with targeted hooks beats 15 plugins. This repo is the result of months of daily Claude Code usage across 5+ production projects. Every file here earns its place.

## What's Inside

| Component | What it does | Replaces |
|---|---|---|
| Model routing rules | Routes Haiku/Sonnet/Opus by task complexity — saves ~60% on token costs | Burning Opus on file searches |
| Sensitive file hook | Blocks writes to `.env`, `.pem`, credentials files at the hook level | Security plugins |
| Memory re-injection hook | Restores project context automatically after `/compact` | Memory management plugins |
| Statusline script | Shows model name + context% + session cost in real-time | Status line plugins |
| Multi-agent pattern | Commander/implementer architecture for parallel feature work | Agent framework plugins |

## Quick Start

```bash
# 1. Global instructions
cp configs/CLAUDE.md ~/.claude/CLAUDE.md

# 2. Settings with hooks
cp configs/settings.json ~/.claude/settings.json

# 3. Statusline script
cp configs/statusline-command.sh ~/.claude/statusline-command.sh
chmod +x ~/.claude/statusline-command.sh
```

Then customize:

- `CLAUDE.md` — model routing thresholds, work principles
- `settings.json` — project-specific paths in the SessionStart hook (the memory hook path), add your own project memory files
- `statusline-command.sh` — cost rates if you use different models

## Multi-Agent Pattern

When a task has 3+ independent subtasks, use a commander/implementer pattern instead of serial work. The commander reads shared files, assigns exclusive file ownership to each agent, and integrates results. Agents run in parallel where possible.

See [`docs/multi-agent-pattern.md`](docs/multi-agent-pattern.md) for full details.

```
┌─────────────────────────────┐
│     Commander (Opus/Sonnet) │
│     Reads shared files      │
│     Assigns file ownership  │
└──────┬──────┬──────┬────────┘
       │      │      │
  ┌────▼──┐ ┌─▼───┐ ┌▼─────┐
  │Agent 1│ │Ag. 2│ │Ag. 3 │
  │Haiku  │ │Son. │ │Haiku │
  │file_a │ │b,c  │ │tests │
  └───────┘ └─────┘ └──────┘
```

## What NOT to Install

Most Claude Code plugins inject prompt text into every turn, burning 500–2000 tokens per interaction. Over a session, that's 10–50k tokens wasted on instructions Claude already knows.

The Claude Code built-in tools — Glob, Grep, Read, Edit, Bash — already cover 95% of use cases. Before installing any plugin, ask whether a 3-line hook does the same thing.

Red flags to watch for in plugin repos:

- Memecoin links or token-gated features
- `--dangerously-skip-permissions` in usage examples
- More than 500 lines of injected context per turn
- Value proposition is "automatically does X" with no explanation of how

If a plugin's pitch is automation, check the implementation. Nine times out of ten it's a prompt wrapper.

## The One Plugin Worth Adding

[Context7](https://github.com/upstash/context7) provides up-to-date library documentation so Claude doesn't hallucinate APIs. It fetches real docs at query time instead of relying on training data.

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"]
    }
  }
}
```

Add this to `~/.claude/settings.json` under `mcpServers`.

## License

MIT

---

- `README.md` — English
- `README.it.md` — Italiano

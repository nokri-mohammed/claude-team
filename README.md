# Claude Team

Canonical Claude Code agents, skills, commands, and hooks — copy only the team your project needs.

Claude Team is a curated collection of [Claude Code](https://code.claude.com) subagents
(architect, code reviewer, security reviewer, TDD guide, doc updater, C4 diagrammer, UI designer),
the skills that back them, slash commands that delegate to them, and enforcement hooks — meant to
be copied piecemeal into any project's `.claude/` directory, not installed wholesale.

## Why copy-based, not a plugin

A plugin install is all-or-nothing. This repo is deliberately the opposite: a small project copies
in two or three agents; a larger one copies in the whole team. See `HUB.md` for the full roster and
rationale.

## Quick start

```
your-project/
└── .claude/
    ├── agents/        # copy only the .md files you need from agents/
    ├── skills/        # copy only the directories you need from skills/
    ├── commands/      # copy only the .md files you need from commands/
    └── hooks/         # copy hooks.json + scripts/ as a pair
```

See `HUB.md` → **Project bootstrap** for the full step-by-step, including the optional
`.mcp.json` for the `designer` agent's Figma + Playwright integration.

## What's in here

| Directory | Contents |
|---|---|
| `agents/` | Subagent definitions — architect, reviewers, tdd-guide, doc-updater, C4 diagrammer, designer |
| `skills/` | Skills the agents above load — coding standards, framework patterns, security review, UI/UX |
| `commands/` | Slash commands that delegate to the agents (`/plan`, `/code-review`, `/tdd`, …) |
| `hooks/` | A backlog-entry Stop hook and a Conventional-Commits warning hook |
| `scripts/validate-hub.sh` | Self-check: skill line limits, agent `tools:` fields, no dangling references |

Full roster, sources, and the bootstrap/versioning workflow: see [`HUB.md`](HUB.md).

## Versioning

This repo versions itself with [`commit-and-tag-version`](https://github.com/absolute-version/commit-and-tag-version)
from [Conventional Commits](https://www.conventionalcommits.org) — see `HUB.md` → Versioning &
Releases and `CHANGELOG.md` for the release history.

## License

MIT — see [`LICENSE`](LICENSE). Several agents and skills were adapted from other MIT-licensed
projects; see [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md) for attribution.

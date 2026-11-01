# Shorthand Guide: read this first

## What this is

A marketplace of six Claude Code plugins. You don't install the whole hub. You install only the
plugins a given project needs.

## 60-second setup

```bash
cd <your-project>
claude plugin marketplace add ~/code/claude-team   # path to wherever you cloned this repo
claude plugin install review@claude-team
claude plugin install tdd@claude-team               # repeat per plugin you need
```

Start minimal (`review` plus one specialist plugin) and add more only as the project's scope
actually demands it. Full step-by-step, including the Figma/Playwright MCP setup bundled in
`designer`: `HUB.md` → **Install into a project**.

## The four building blocks

| Block | What it is | Example |
|---|---|---|
| **Agent** | a subagent with a restricted tool set, for one job | `code-reviewer`, `security-reviewer` |
| **Skill** | a workflow/reference an agent loads | `tdd-workflow`, `accessibility-compliance` |
| **Command** | a slash command that delegates to an agent | `/code-review`, `/plan` |
| **Hook** | fires on a tool event, warns or blocks | backlog-entry check, commit-message check |

Each plugin bundles the agents, skills, commands, and hooks for one area of work. See `HUB.md` for
what each of the six plugins contains.

## How work flows: the CEO and the executives

You are the CEO: you set direction. The main Claude session in your project is your chief of
staff: it breaks your direction into tickets. Each ticket goes to the executive (agent) that owns
it, and you review what comes back.

| Ticket | Executive | Plugin |
|---|---|---|
| System design / ADRs | `architect` / `/plan` | `architecture` |
| Code review | `code-reviewer` / `/code-review` | `review` |
| Security-sensitive diff | `security-reviewer` | `review` |
| Test-first development | `tdd-guide` / `/tdd` | `tdd` |
| UI/UX, Figma-to-code, logo/brand design | `designer` | `designer` |

A single-file task doesn't need any of this. Scale the team to the task, one plugin install at a
time.

## Versioning, in one line

`npm run release:beta` cuts a beta; `npm run release` drops the prerelease tag. Both read commit
history, so commits must follow [Conventional Commits](https://www.conventionalcommits.org).

## Going deeper

This is the "read first" version. For the mechanics underneath, how agent `tools:`/`skills:`
frontmatter actually behaves, the SKILL.md size limit and why, how hooks are built and verified,
MCP wiring, and the versioning gotchas we hit building this, see **[LONGFORM_GUIDE.md](docs/LONGFORM_GUIDE.md)**.

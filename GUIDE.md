# Shorthand Guide: read this first

## What this is

A hub of canonical Claude Code agents, skills, commands, and hooks. You don't install it whole.
You copy the handful of pieces a given project actually needs into that project's `.claude/`.

## 60-second setup

```bash
mkdir -p <your-project>/.claude/{agents,skills,commands,hooks}
# copy only what you need:
cp agents/code-reviewer.md      <your-project>/.claude/agents/
cp -r skills/coding-standards    <your-project>/.claude/skills/
cp commands/code-review.md      <your-project>/.claude/commands/
cp hooks/hooks.json hooks/scripts -r  <your-project>/.claude/hooks/
```

Start minimal (one engineer-role agent, one reviewer) and add more only as the project's scope
actually demands it. Full step-by-step, including the optional Figma/Playwright MCP setup for
`designer`: `HUB.md` → **Project bootstrap**.

## The four building blocks

| Block | What it is | Example |
|---|---|---|
| **Agent** | a subagent with a restricted tool set, for one job | `code-reviewer`, `security-reviewer` |
| **Skill** | a workflow/reference an agent loads | `tdd-workflow`, `accessibility-compliance` |
| **Command** | a slash command that delegates to an agent | `/code-review`, `/plan` |
| **Hook** | fires on a tool event, warns or blocks | backlog-entry check, commit-message check |

## When to delegate

| Task | Use |
|---|---|
| System design / ADRs | `architect` / `/plan` |
| Code review | `code-reviewer` / `/code-review` |
| Security-sensitive diff | `security-reviewer` |
| Test-first development | `tdd-guide` / `/tdd` |
| UI/UX, Figma-to-code, logo/brand design | `designer` |

A single-file task doesn't need any of this. Scale the team to the task.

## Versioning, in one line

`npm run release:beta` cuts a beta; `npm run release` drops the prerelease tag. Both read commit
history, so commits must follow [Conventional Commits](https://www.conventionalcommits.org).

## Going deeper

This is the "read first" version. For the mechanics underneath, how agent `tools:`/`skills:`
frontmatter actually behaves, the SKILL.md size limit and why, how hooks are built and verified,
MCP wiring, and the versioning gotchas we hit building this, see **[LONGFORM_GUIDE.md](docs/LONGFORM_GUIDE.md)**.

<img src="assets/logo/readme-header.png" alt="Claude Team" width="420">

A marketplace of Claude Code plugins: agents, skills, commands, and hooks for software
engineering. Install only the plugins a project needs.

Claude Team packages [Claude Code](https://code.claude.com) subagents (architect, code reviewer,
security reviewer, TDD guide, doc updater, C4 diagrammer, UI designer), the skills that back them,
slash commands that delegate to them, and enforcement hooks, as six focused plugins.

## This is your hub

Keep this repo as one place: your whole team, in one spot, next to your projects, never inside
one.

```
~/code/
├── claude-team/          # this repo, your hub
└── projects/
    ├── my-app/
    └── another-app/
```

A project doesn't copy files out of the hub. It adds the hub as a marketplace, then installs the
plugins it needs.

```bash
cd ~/code/projects/my-app
claude plugin marketplace add ~/code/claude-team
claude plugin install review@claude-team
claude plugin install tdd@claude-team
```

Start with one or two plugins. Add more only as the project's scope grows. The full roster, with
what each plugin bundles, is in [`HUB.md`](HUB.md).

## How work flows: the CEO and the executives

You are the CEO. You decide what gets built, not how.

The main Claude session in your project is your chief of staff. You hand it a goal, and it breaks
that goal into tickets.

Each ticket goes to the executive who owns that function:

| Ticket | Executive |
|---|---|
| System design, an ADR | `architect` (`architecture` plugin) / `/plan` |
| Code review | `code-reviewer` (`review` plugin) / `/code-review` |
| A security-sensitive diff | `security-reviewer` (`review` plugin) |
| Test-first development | `tdd-guide` (`tdd` plugin) / `/tdd` |
| UI, Figma-to-code, a logo | `designer` (`designer` plugin) |
| Docs out of date after a change | `doc-updater` (`essentials` plugin) |

You read the output. The executives do the work. That's the whole model.

## The Guides

- **[GUIDE.md](GUIDE.md)**: shorthand / TL;DR. 60-second setup, the four building blocks, when
  to delegate. **Read this first.**
- **[docs/LONGFORM_GUIDE.md](docs/LONGFORM_GUIDE.md)**: advanced. How agent/skill frontmatter
  actually behaves, the SKILL.md size limit, building and verifying hooks, MCP wiring, and the
  versioning gotchas this hub hit while being built. Read it once you're extending the hub, not
  before.

## The six plugins

| Plugin | Bundles | Install |
|---|---|---|
| `review` | code-reviewer, security-reviewer, coding-standards, security-review, Conventional Comments, `/code-review` | `claude plugin install review@claude-team` |
| `tdd` | tdd-guide, tdd-workflow, `/tdd` | `claude plugin install tdd@claude-team` |
| `architecture` | architect, the four C4 agents, api-design, before-you-build, `/plan` | `claude plugin install architecture@claude-team` |
| `designer` | designer, UI/logo skills, bundled Figma + Playwright MCP | `claude plugin install designer@claude-team` |
| `patterns` | frontend-patterns, backend-patterns (no dedicated agent) | `claude plugin install patterns@claude-team` |
| `essentials` | doc-updater, verification-loop, asd-ste100, `/build-fix`, `/refactor-clean`, the backlog and commit-message hooks | `claude plugin install essentials@claude-team` |

Each plugin updates independently: `claude plugin update <plugin>@claude-team`, or turn on
auto-update for the `claude-team` marketplace. Full roster, sources, and rationale: see
[`HUB.md`](HUB.md).

## Key Concepts

**Agents** are subagents with a restricted tool set, invoked for a specific job. Example:
[`plugins/review/agents/security-reviewer.md`](plugins/review/agents/security-reviewer.md).

```yaml
---
name: security-reviewer
description: Security-focused review for OWASP risks, secrets, and injection
tools: Read, Grep, Glob, Bash
---
```

**Skills** are workflow or reference documents an agent loads for a task: a methodology
(`tdd-workflow`), a pattern library (`frontend-patterns`), or a domain reference
(`accessibility-compliance`). Example: the red-green-refactor loop in
[`plugins/tdd/skills/tdd-workflow/SKILL.md`](plugins/tdd/skills/tdd-workflow/SKILL.md).

```
1. Write a failing test (RED)
2. Implement the minimum code to pass (GREEN)
3. Refactor without changing behavior (IMPROVE)
4. Repeat
```

**Commands** are slash commands that delegate to an agent instead of re-deriving its process
inline. Example: [`plugins/review/commands/code-review.md`](plugins/review/commands/code-review.md)
delegates `/code-review` to the `code-reviewer` agent, and to `security-reviewer` too when the
diff warrants it.

**Hooks** fire on tool events and can warn or block. Example:
[`plugins/essentials/hooks/scripts/check-commit-msg.sh`](plugins/essentials/hooks/scripts/check-commit-msg.sh)
warns (non-blocking) when a commit doesn't follow Conventional Commits.

```bash
msg=$(git log -1 --format=%s 2>/dev/null)
pattern='^(feat|fix|chore|docs|refactor|perf|test|build|ci|revert)(\([a-z0-9_.-]+\))?!?: '
if [ -z "$msg" ] || echo "$msg" | grep -qE "$pattern"; then
  echo '{}'
else
  jq -n --arg m "$msg" '{systemMessage: ("Commit message \"" + $m + "\" does not follow Conventional Commits...")}'
fi
```

## Versioning

This repo versions itself with [`commit-and-tag-version`](https://github.com/absolute-version/commit-and-tag-version),
driven by [Conventional Commits](https://www.conventionalcommits.org). See `HUB.md` → Versioning &
Releases and `CHANGELOG.md` for the release history.

## Running Tests

```bash
npm test   # scripts/validate-hub.sh: SKILL.md line limits, agent tools: fields, dangling refs,
           # JSON validity, and claude plugin validate against every plugin
```

Run it before committing, and after adding or changing any plugin.

## Contributing

Contributions are welcome: a new agent, a new skill, a better hook, or a new plugin for a role
this hub doesn't cover yet. See [`CONTRIBUTING.md`](CONTRIBUTING.md) for the process and the
compliance bar every addition has to clear (explicit `tools:`, SKILL.md under 500 lines, no
dangling references, `npm test` passing).

## License

MIT. See [`LICENSE`](LICENSE). Several agents and skills were adapted from other MIT-licensed
projects; see [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md) for attribution.

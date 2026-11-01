# Homelab Team — Hub

Canonical agent and skill definitions. Projects under `~/projects/homelab-team-all/projects/<name>/`
copy or symlink only the subset they need into their own `.claude/agents/` and `.claude/skills/` —
nothing here is auto-visible to any project (deliberately kept outside `~/.claude`). `hub/` and
`projects/` are siblings inside `homelab-team-all/`, so this hub's own `CLAUDE.md` never becomes
an ancestor of any project directory and never auto-loads into one.

## Agents (`agents/`)

| Agent | Role | Source |
|---|---|---|
| architect | lays down project architecture | affaan-m/ECC |
| c4-context, c4-container, c4-component, c4-code | architecture diagrams at increasing detail, used alongside `architect` | wshobson/agents (c4-architecture plugin) |
| code-reviewer | reviews all code for quality/maintainability | affaan-m/ECC |
| security-reviewer | security-focused review (OWASP, secrets, injection) | affaan-m/ECC |
| doc-updater | syncs docs/codemaps after a task is done | affaan-m/ECC |
| tdd-guide | enforces write-tests-first | affaan-m/ECC |
| designer | UI/UX design, design-to-code, Figma + Playwright-verified visual work — owns the four UI-design skills below | this hub |

## Skills (`skills/`)

| Skill | Use | Source |
|---|---|---|
| coding-standards | baseline conventions when no framework-specific skill applies | affaan-m/ECC |
| frontend-patterns | React/Next.js patterns | affaan-m/ECC |
| backend-patterns | Node/Express/Next.js API patterns | affaan-m/ECC |
| api-design | REST API design (naming, status codes, pagination, versioning) | affaan-m/ECC |
| tdd-workflow | red-green-refactor methodology | affaan-m/ECC |
| security-review | security checklist for auth/secrets/payments | affaan-m/ECC |
| verification-loop | 6-phase PASS/FAIL check before a PR | affaan-m/ECC |
| before-you-build | pre-mortem product/feature risk check — use during Elephant drafting | wshobson/agents |
| visual-design-foundations | typography/color/spacing principles | wshobson/agents (ui-design) |
| design-system-patterns | design tokens, theming, component architecture | wshobson/agents (ui-design) |
| responsive-design | container queries, fluid typography, mobile-first | wshobson/agents (ui-design) |
| accessibility-compliance | WCAG 2.2 compliance | wshobson/agents (ui-design) |
| conventional-comments | labeled review-comment format for code-reviewer/security-reviewer output | conventionalcomments.org |

Deliberately excluded: `continuous-learning*` (duplicates native auto-memory), `strategic-compact`
(duplicates native `/compact` hints), and anything business/content/language-specific not relevant
to this stack.

## Project bootstrap (step 6 — hub's job, not delegated)

1. `mkdir -p ~/projects/homelab-team-all/projects/<name>/{.claude/agents,.claude/skills,.claude/hooks,docs,src}`
2. Copy/symlink only the needed agent `.md` files and skill directories from here into the project's `.claude/`
3. Write `docs/project-plan.md` (approved, Goldfish-reviewed), `docs/design/figma-link.md`, start `docs/architecture.md`
4. Copy `backlog-template.md` → `docs/backlog.md`
5. Set up `.claude/hooks/hooks.json`: block task completion unless the backlog line got a new dated entry; enforce scaling rule (simple task = one agent, 3-10 tool calls)
6. Decide team size for *this* project — default minimal (one engineer, one reviewer), add roles only if scope needs them
7. If the `designer` agent is in scope for this project, also copy `hub/.mcp.json` to the project
   root (not `.claude/`) as `.mcp.json`, and commit it. First run in that project prompts to approve
   the `figma-dev-mode-mcp-server` and `playwright` servers (`claude mcp list` to check status).
   Figma MCP needs a Dev Mode seat; Playwright MCP needs Node.js 18+ on the machine running it.

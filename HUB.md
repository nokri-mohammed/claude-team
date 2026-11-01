# Claude Team Hub

Canonical agent and skill definitions. Your projects copy or symlink only the subset they need
into their own `.claude/agents/` and `.claude/skills/`. Nothing here is auto-visible to any
project unless you copy it in. Keep this repo as a **sibling** of your project directories, never
an ancestor of one, so this hub's own `CLAUDE.md` never auto-loads into a project that didn't ask
for it. A layout like this works well:

```
~/code/
├── claude-team/          # this repo
└── projects/
    ├── my-app/
    └── another-app/
```

## Agents (`agents/`)

| Agent | Role | Source |
|---|---|---|
| architect | lays down project architecture | affaan-m/ECC |
| c4-context, c4-container, c4-component, c4-code | architecture diagrams at increasing detail, used alongside `architect` | wshobson/agents (c4-architecture plugin) |
| code-reviewer | reviews all code for quality/maintainability | affaan-m/ECC |
| security-reviewer | security-focused review (OWASP, secrets, injection) | affaan-m/ECC |
| doc-updater | syncs docs/codemaps after a task is done | affaan-m/ECC |
| tdd-guide | enforces write-tests-first | affaan-m/ECC |
| designer | UI/UX design, design-to-code, Figma + Playwright-verified visual work, and logo/brand-mark design (owns the UI-design and logo-design skills below) | this hub |

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
| before-you-build | pre-mortem product/feature risk check, use during Elephant drafting | wshobson/agents |
| visual-design-foundations | typography/color/spacing principles | wshobson/agents (ui-design) |
| design-system-patterns | design tokens, theming, component architecture | wshobson/agents (ui-design) |
| responsive-design | container queries, fluid typography, mobile-first | wshobson/agents (ui-design) |
| accessibility-compliance | WCAG 2.2 compliance | wshobson/agents (ui-design) |
| conventional-comments | labeled review-comment format for code-reviewer/security-reviewer output | conventionalcomments.org |
| asd-ste100 | writing standard for hub docs, adapted from ASD-STE100 (Simplified Technical English); used by `doc-updater` | this hub |
| logo-design | logo/brand-mark design workflow (brief → concepts → SVG production kit), owned by `designer` | kaankiziltug/logo-design-skill |

Deliberately excluded: `continuous-learning*` (duplicates native auto-memory), `strategic-compact`
(duplicates native `/compact` hints), and anything business/content/language-specific not relevant
to this stack.

## Commands (`commands/`)

Thin slash commands that delegate to the agents above instead of duplicating their process inline.

| Command | Delegates to |
|---|---|
| `/tdd` | `tdd-guide` |
| `/plan` | `architect` |
| `/code-review` | `code-reviewer` (+ `security-reviewer` when the diff warrants it) |
| `/build-fix` | self-contained, no dedicated agent for this |
| `/refactor-clean` | self-contained, no dedicated agent for this |

## Hooks (`hooks/`)

`hooks.json` + `scripts/`. Copy both into a project's `.claude/hooks/` (step 5 below). Two hooks:

- **Stop** → `check-backlog.sh`: blocks finishing a task unless `docs/backlog.md` has an entry
  dated today. Stateless (just checks today's date appears in the file), not a true "new line"
  check.
- **PostToolUse** (`git commit`) → `check-commit-msg.sh`: warns (never blocks) if the commit just
  made doesn't follow Conventional Commits. Reads the message back from `git log`, not the raw
  bash invocation, so it's correct whether the commit used `-m`, a heredoc body, or an editor.

Both degrade silently (no-op) if `docs/backlog.md` or `.git` doesn't exist yet, so they're safe to
copy into a project before it's fully bootstrapped.

## Validation (`scripts/validate-hub.sh`)

Run via `npm test`. Checks the hub against the rules from its own audit: every `SKILL.md` under
500 lines, every agent has an explicit `tools:` field, no dangling `references/*.md` pointers, and
every JSON config file parses. Run it before committing, and after adding any new agent or skill.

## Versioning & Releases

The hub is a git repo, versioned internally with [`commit-and-tag-version`](https://github.com/absolute-version/commit-and-tag-version)
(the maintained fork of `standard-version`: bumps semver, writes `CHANGELOG.md`, tags the
commit; no CI, no npm publish, nothing external).

**Commit messages must follow [Conventional Commits](https://www.conventionalcommits.org)**
(`feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, etc., with a `BREAKING CHANGE:` footer when
needed). The version bump and changelog are both derived from these, so a wrongly-typed commit
produces a wrong release.

To cut a release:

```bash
npm run release:beta   # 0.x.0-beta.N, use this until the hub is stable enough to drop beta
npm run release        # drops the prerelease tag once ready (feat -> minor, fix -> patch, BREAKING CHANGE -> major)
```

Both read `.versionrc.json` (pins the `conventionalcommits` preset, required on this machine's
Node 18, since `commit-and-tag-version`'s own default-preset resolution silently fell back to
patch-only bumps without it; verify this is still needed if Node is ever upgraded past 22).

## Project bootstrap (step 6, hub's job, not delegated)

1. `mkdir -p <your-project>/{.claude/agents,.claude/skills,.claude/commands,.claude/hooks,docs,src}`
2. Copy/symlink only the needed agent `.md` files, skill directories, and `commands/*.md` files from here into the project's `.claude/`
3. Write `docs/project-plan.md` (approved, Goldfish-reviewed), `docs/design/figma-link.md`, start `docs/architecture.md`
4. Copy `backlog-template.md` → `docs/backlog.md`
5. Copy `hooks/hooks.json` and `hooks/scripts/` into `.claude/hooks/`: enforces the backlog-entry rule and warns on non-conventional commits (see Hooks above). Still enforce the scaling rule by instruction (simple task = one agent, 3-10 tool calls); that part isn't hook-automated.
6. Decide team size for *this* project. Default minimal (one engineer, one reviewer), add roles only if scope needs them
7. If the `designer` agent is in scope for this project, also copy `hub/.mcp.json` to the project
   root (not `.claude/`) as `.mcp.json`, and commit it. First run in that project prompts to approve
   the `figma-dev-mode-mcp-server` and `playwright` servers (`claude mcp list` to check status).
   Figma MCP needs a Dev Mode seat; Playwright MCP needs Node.js 18+ on the machine running it.

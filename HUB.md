# Claude Team Hub

A Claude Code [marketplace](https://code.claude.com/docs/en/plugins/install) of six plugins, each
in `plugins/<name>/`. Nothing here loads into a project until that project installs the plugin it
wants. Keep this repo as a **sibling** of your project directories, never an ancestor of one, so
this hub's own `CLAUDE.md` never auto-loads into a project that didn't ask for it.

```
~/code/
├── claude-team/          # this repo, your hub
└── projects/
    ├── my-app/
    └── another-app/
```

## Install into a project

```bash
cd ~/code/projects/my-app
claude plugin marketplace add ~/code/claude-team   # or the GitHub form once pushed:
                                                     # claude plugin marketplace add nokri-mohammed/claude-team
claude plugin install review@claude-team
```

Repeat the install line for each plugin the project needs. Updates: `claude plugin update
<plugin>@claude-team`, or turn on auto-update for the marketplace (`/plugin` → Marketplaces tab).

## The plugins

### `plugins/review`

| Component | Role | Source |
|---|---|---|
| `code-reviewer` (agent) | reviews all code for quality/maintainability | affaan-m/ECC |
| `security-reviewer` (agent) | security-focused review (OWASP, secrets, injection) | affaan-m/ECC |
| `coding-standards` (skill) | baseline conventions when no framework-specific skill applies | affaan-m/ECC |
| `security-review` (skill) | security checklist for auth/secrets/payments | affaan-m/ECC |
| `conventional-comments` (skill) | labeled review-comment format for both reviewers' output | conventionalcomments.org |
| `/code-review` (command) | delegates to `code-reviewer`, and `security-reviewer` when the diff warrants it | this hub |

### `plugins/tdd`

| Component | Role | Source |
|---|---|---|
| `tdd-guide` (agent) | enforces write-tests-first | affaan-m/ECC |
| `tdd-workflow` (skill) | red-green-refactor methodology | affaan-m/ECC |
| `/tdd` (command) | delegates to `tdd-guide` | this hub |

### `plugins/architecture`

| Component | Role | Source |
|---|---|---|
| `architect` (agent) | lays down project architecture | affaan-m/ECC |
| `c4-context`, `c4-container`, `c4-component`, `c4-code` (agents) | architecture diagrams at increasing detail, used alongside `architect` | wshobson/agents (c4-architecture plugin) |
| `api-design` (skill) | REST API design (naming, status codes, pagination, versioning) | affaan-m/ECC |
| `before-you-build` (skill) | pre-mortem product/feature risk check | wshobson/agents |
| `/plan` (command) | delegates to `architect` | this hub |

### `plugins/designer`

| Component | Role | Source |
|---|---|---|
| `designer` (agent) | UI/UX design, design-to-code, Figma + Playwright-verified visual work, logo/brand-mark design | this hub |
| `visual-design-foundations`, `design-system-patterns`, `responsive-design`, `accessibility-compliance` (skills) | typography/color/spacing, tokens/theming, container queries, WCAG 2.2 | wshobson/agents (ui-design) |
| `logo-design` (skill) | logo/brand-mark design workflow (brief → concepts → SVG production kit) | kaankiziltug/logo-design-skill |
| `.mcp.json` | bundles the Figma and Playwright MCP servers `designer` verifies against | this hub |

Figma MCP needs a Dev Mode seat; Playwright MCP needs Node.js 18+ on the machine running it. On
first use in a project, Claude Code prompts to approve both servers (`claude mcp list` to check
status).

### `plugins/patterns`

No dedicated agent. Any agent in the project can load these.

| Component | Role | Source |
|---|---|---|
| `react-patterns` (skill) | React/Next.js patterns | affaan-m/ECC |
| `node-patterns` (skill) | Node/Express/Next.js API patterns | affaan-m/ECC |
| `rust-patterns` (skill) | explicit Rust house rules (no shorthand, comments above, services/ + unit tests) with good/bad examples | this hub |

### `plugins/essentials`

General project hygiene, no single specialist role.

| Component | Role | Source |
|---|---|---|
| `doc-updater` (agent) | syncs docs/codemaps after a task is done | affaan-m/ECC |
| `verification-loop` (skill) | 6-phase PASS/FAIL check before a PR | affaan-m/ECC |
| `asd-ste100` (skill) | writing standard for hub docs, adapted from ASD-STE100 (Simplified Technical English); used by `doc-updater` | this hub |
| `/build-fix`, `/refactor-clean` (commands) | self-contained, no dedicated agent for either | this hub |
| `hooks/hooks.json` + `hooks/scripts/` | backlog-entry Stop hook, Conventional-Commits warning hook | this hub |

Hooks:
- **Stop** → `check-backlog.sh`: blocks finishing a task unless `docs/backlog.md` has an entry
  dated today. Stateless (just checks today's date appears in the file), not a true "new line"
  check.
- **PostToolUse** (`git commit`) → `check-commit-msg.sh`: warns (never blocks) if the commit just
  made doesn't follow Conventional Commits. Reads the message back from `git log`, not the raw
  bash invocation, so it's correct whether the commit used `-m`, a heredoc body, or an editor.

Both degrade silently (no-op) if `docs/backlog.md` or `.git` doesn't exist yet in the installing
project.

Deliberately excluded across every plugin: `continuous-learning*` (duplicates native
auto-memory), `strategic-compact` (duplicates native `/compact` hints), and anything
business/content/language-specific not relevant to this stack.

## Picking a team for a new project

| Task | Plugin |
|---|---|
| System design / ADRs | `architecture` |
| Code review | `review` |
| Security-sensitive diff | `review` |
| Test-first development | `tdd` |
| UI/UX, Figma-to-code, logo/brand design | `designer` |
| Framework pattern reference, no agent needed | `patterns` |
| Docs/backlog hygiene | `essentials` |

Start minimal (`review` plus one of `tdd`/`architecture`) and install more only as the project's
scope actually demands it.

## Validation (`scripts/validate-hub.sh`)

Run via `npm test`. Checks every `SKILL.md` under 500 lines, every agent has an explicit `tools:`
field, no dangling `references/*.md` pointers, every JSON config file parses, and every plugin
passes `claude plugin validate`. Run it before committing, and after adding or changing any
plugin.

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

**After every release, bump `version` in all six `plugins/*/.claude-plugin/plugin.json` files to
match the new `package.json` version**, so `claude plugin update` reports the correct version to
installers. This hub has one release cadence for all six plugins; it doesn't version them
independently.

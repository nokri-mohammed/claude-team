# Longform Guide: advanced

Read `GUIDE.md` first. This covers the mechanics underneath, and the specific problems we hit
building this hub. Useful once you're extending it, not before.

## Why six plugins, not one

A single plugin install is all-or-nothing: install it, and every agent, skill, command, and hook
inside loads. A small project that only wants `code-reviewer` shouldn't also pull in `designer`'s
Figma/Playwright MCP wiring.

This hub splits into six plugins (`review`, `tdd`, `architecture`, `designer`, `patterns`,
`essentials`) along the natural fault lines in `HUB.md`'s roster, so a project installs only what
it needs while still getting real update propagation: `claude plugin update <plugin>@claude-team`
pulls a fix without a manual re-copy, and the marketplace's auto-update can do it without even
that. See `README.md` → **The six plugins** for the current split. Add a new plugin, don't grow an
existing one past one coherent job, when a new role doesn't fit any of the six.

## Agent frontmatter, precisely

```yaml
---
name: designer
tools: Read, Write, Edit, Grep, Glob, Bash
mcpServers: figma-dev-mode-mcp-server, playwright
skills: visual-design-foundations, logo-design
model: sonnet
---
```

- `tools:` restricts the agent's built-in tool surface. **Always set this explicitly**: an agent
  with no `tools:` field inherits the full session tool set, including `Bash` and `Edit`, which is
  almost never what you want for a reviewer/read-only role. (`validate-hub.sh` enforces this.)
- `mcpServers:` restricts which configured MCP servers this agent can reach, by name, matching the
  keys in `.mcp.json`.
- `skills:` **preloads** the named skills' full content into the agent's context at startup.
  This is not the same as the agent being able to call the Skill tool at runtime. If a skill isn't
  listed here, the agent won't have it unless it can invoke Skill itself.
- Keep the `description` field specific: it's what Claude Code uses to decide *when* to delegate
  to this agent, not documentation for humans. Put the human-facing detail in the body.

## The SKILL.md 500-line limit

This is Anthropic's own guidance, not a stylistic choice: keep `SKILL.md` under 500 lines, and
move detailed reference material into `references/*.md`, linked from `SKILL.md`. Every skill in
this hub that started over the limit (`react-patterns`, `tdd-workflow`, `node-patterns`,
`coding-standards`, `api-design`, `security-review`) was split this way, on clean section
boundaries, never mid-example. When you add a new skill, write the workflow/decision-making part
in `SKILL.md` and push exhaustive examples/checklists into `references/`.

A skill that points at a `references/*.md` file that doesn't exist fails silently at runtime: the
agent just won't find the content. `validate-hub.sh` catches this; run it after any skill edit.

## Building and verifying a hook

Don't write a hook and assume it fires. The sequence that actually catches failures:

1. **Write the raw command first**: no `|| true`, no `2>/dev/null` yet, so errors surface.
2. **Pipe-test it directly**: synthesize the stdin JSON the hook will receive and pipe it in:
   `echo '{"tool_name":"Bash","tool_input":{"command":"..."}}' | bash your-script.sh`. Check both
   the exit code and the actual JSON printed.
3. **Validate the schema** with `jq -e` against `hooks.json`: a malformed hook JSON silently
   disables *every* hook in that file, not just the broken one.
4. Only after both pass, wrap the command with `2>/dev/null || true` (unless you want it to be
   able to block; most checks in this hub are warnings, not blockers, by design; see
   `check-commit-msg.sh` vs `check-backlog.sh` for the two patterns).
5. In a plugin's `hooks/hooks.json`, reference the plugin's own bundled scripts with
   `${CLAUDE_PLUGIN_ROOT}`, never a path like `.claude/hooks/scripts/...`: a plugin isn't copied
   into the installing project's `.claude/`, so that path doesn't exist there. See
   `plugins/essentials/hooks/hooks.json` for the pattern.
6. If a hook is wired correctly but never fires in a live session, run `/reload-plugins` after
   installing or updating the plugin; Claude Code doesn't pick up a hook change mid-session
   without it.

## MCP wiring (the `designer` plugin)

`plugins/designer/.mcp.json` declares two servers, auto-discovered because `.mcp.json` at a
plugin's root is the standard location Claude Code scans:

```json
{
  "mcpServers": {
    "figma-dev-mode-mcp-server": { "type": "http", "url": "https://mcp.figma.com/mcp" },
    "playwright": { "command": "npx", "args": ["-y", "@playwright/mcp@latest"] }
  }
}
```

Installing the `designer` plugin into a project makes Claude Code prompt to approve both servers
on first run there. Figma's server needs a Dev Mode seat (Hobby-tier accounts can't use it);
Playwright's needs Node.js 18+ on whatever machine runs the session.

## Versioning mechanics, in full

Release tooling is [`commit-and-tag-version`](https://github.com/absolute-version/commit-and-tag-version)
(a maintained fork of the deprecated `standard-version`): bumps semver, writes `CHANGELOG.md`,
tags the commit, no CI, no publish step. Two gotchas we hit setting this up:

- **Starting at `0.0.0`**: versions in the `0.0.x` range are treated as "pre-initial-release," so
  a `feat:` commit only bumps the patch digit instead of minor. Start a new package at `0.1.0`
  instead if you want normal semver semantics from the first release.
- **Preset resolution on old Node**: `commit-and-tag-version`'s default preset auto-resolution can
  silently fail on Node < 22 (its stated minimum), falling back to patch-only bumps with no error.
  `.versionrc.json` pins `{"preset": "conventionalcommits"}` to force the preset that's actually
  installed, sidestepping the broken auto-resolution. Verify this is still needed if your Node
  version changes.
- **Six manifests, one version**: `commit-and-tag-version` only bumps `package.json`. It doesn't
  know about `plugins/*/.claude-plugin/plugin.json`. Bump all six by hand after every release (see
  `HUB.md` → Versioning & Releases), or installers see a stale version in `claude plugin list`.

## Writing something that'll pass `validate-hub.sh`

- New agent: explicit `tools:` field, specific `description`, placed in the right
  `plugins/<name>/agents/`, added to that plugin's table in `HUB.md`.
- New skill: `SKILL.md` ≤500 lines, every `references/*.md` it mentions actually exists, placed
  in the right `plugins/<name>/skills/`, added to that plugin's table in `HUB.md`.
- New plugin: `plugins/<name>/.claude-plugin/plugin.json` with at least `name`, `version`,
  `description`; add an entry to `.claude-plugin/marketplace.json` with
  `"source": "<name>"`, since `metadata.pluginRoot` is set to `./plugins`.
- Run `npm test` before committing: SKILL.md limits, agent `tools:` fields, dangling references,
  JSON validity, and `claude plugin validate` against every plugin, the same checks spelled out
  in `CONTRIBUTING.md`.

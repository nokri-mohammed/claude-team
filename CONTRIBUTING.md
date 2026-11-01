# Contributing

This hub is a community resource: a marketplace of six focused Claude Code plugins, not one
monolith everyone installs whole. Contributions that fit that model are welcome.

## Before you open a PR

Run the self-check:

```bash
npm test
```

It enforces the same rules this hub was audited against: every `SKILL.md` under 500 lines
(Anthropic's own guidance: split long content into `references/*.md` and point to it from
`SKILL.md`), every agent has an explicit `tools:` allowlist (never inherit the full tool set
silently), no skill references a `references/*.md` file that doesn't exist, every JSON config
file parses, and every plugin passes `claude plugin validate`.

## What's worth contributing

- **A new agent** for a role this hub doesn't cover: give it a narrow `tools:` list, a clear
  `description` (the part Claude Code uses to decide when to delegate to it), place it under the
  plugin it belongs to (or propose a new plugin if none fits), and add it to that plugin's table
  in `HUB.md`.
- **A new skill**: a methodology, pattern library, or domain checklist an agent can load. Keep
  `SKILL.md` under 500 lines; move detail into `references/*.md`.
- **A slash command** that delegates to an existing agent instead of duplicating its process.
- **A hook**: prefer non-blocking warnings (`systemMessage`) over blocking (`decision: "block"`)
  unless the check is cheap, reliable, and something you'd genuinely want to stop on every time.
  Reference the plugin's own bundled scripts with `${CLAUDE_PLUGIN_ROOT}`, not a `.claude/...`
  path.
- **An MCP config** for a tool this hub doesn't integrate with yet (add a `.mcp.json` to the
  relevant plugin and document the setup/approval steps in `HUB.md`, the way `designer`'s Figma +
  Playwright entry does).

## How to contribute

1. Fork the repo and clone your fork locally.
2. Create a branch named for what you're adding (`add-rust-skill`, `fix-tdd-hook`, not `patch-1`).
3. Add your files under the right plugin's matching directory
   (`plugins/<plugin>/agents/`, `plugins/<plugin>/skills/<name>/`, `plugins/<plugin>/commands/`,
   or `plugins/<plugin>/hooks/scripts/`), following that directory's existing format (agent
   frontmatter, `SKILL.md` + `references/`, command frontmatter with
   `description`/`argument-hint`). A genuinely new role gets its own `plugins/<name>/` with a
   `.claude-plugin/plugin.json` and an entry in `.claude-plugin/marketplace.json`.
4. Run `npm test` and fix anything it flags.
5. If you added a hook, pipe-test it manually (synthesize the stdin payload it expects, confirm
   the JSON it prints is well-formed); `npm test` checks JSON syntax, not that a hook actually
   fires correctly.
6. Commit with a [Conventional Commits](https://www.conventionalcommits.org) type (`feat:`,
   `fix:`, `docs:`, …). This hub's own release tooling depends on it, and a PR with a wrongly
   typed commit will need squashing before merge anyway.
7. Open a PR describing what you added, why it's useful, and how you tested it.

## Do / Don't

**Do:** keep each agent/skill/command focused on one job; write a `description` specific enough
that Claude Code can tell when to use it without being told by name; test what you're adding
before submitting; follow the existing file layout rather than inventing a new one; note any
external dependency (an MCP server, a specific CLI tool) up front.

**Don't:** include real secrets, API keys, or personal infrastructure details, even as examples;
add something so niche it won't generalize beyond your one use case; submit untested hooks or
scripts; duplicate a skill/agent that already covers the same job; require a paid-only service
with no free or self-hosted alternative mentioned.

## File naming

Lowercase, hyphenated, descriptive: `security-review`, not `SecurityReview` or `sec-rev`. An
agent's filename matches its `name:` frontmatter field; a skill's directory name matches its
`SKILL.md` `name:` field.

## Licensing

This repo is MIT (see `LICENSE`). If you're porting content from another project, confirm its
license is compatible (MIT/Apache-2.0/BSD are fine; anything with a stricter copyleft or
non-commercial clause needs a conversation first) and add an entry to `THIRD_PARTY_NOTICES.md`
crediting the source, the same way the existing entries do.

## What doesn't belong here

- Anything that duplicates a native Claude Code feature (auto-memory, `/compact`, etc.). This
  hub deliberately excludes content like that; see the note in `HUB.md`.
- Business-, content-, or language-specific skills unrelated to software engineering; keep the
  hub's scope coherent.
- Large binary or dataset assets (reference image/logo libraries, model weights, etc.); link to
  the upstream source instead of vendoring them in.

## Questions?

Open a [GitHub issue](https://github.com/nokri-mohammed/claude-team/issues), for a vague idea as
much as a concrete bug.

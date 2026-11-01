# Contributing

This hub is a community resource: a curated team of Claude Code agents, skills, commands, and
hooks that people copy from, not a monolith everyone installs whole. Contributions that fit that
model are welcome.

## Before you open a PR

Run the self-check:

```bash
npm test
```

It enforces the same rules this hub was audited against: every `SKILL.md` under 500 lines
(Anthropic's own guidance — split long content into `references/*.md` and point to it from
`SKILL.md`), every agent has an explicit `tools:` allowlist (never inherit the full tool set
silently), no skill references a `references/*.md` file that doesn't exist, and every JSON config
file parses.

## What's worth contributing

- **A new agent** for a role this hub doesn't cover — give it a narrow `tools:` list, a clear
  `description` (the part Claude Code uses to decide when to delegate to it), and add it to the
  agents table in `HUB.md`.
- **A new skill** — a methodology, pattern library, or domain checklist an agent can load. Keep
  `SKILL.md` under 500 lines; move detail into `references/*.md`.
- **A slash command** that delegates to an existing agent instead of duplicating its process.
- **A hook** — prefer non-blocking warnings (`systemMessage`) over blocking (`decision: "block"`)
  unless the check is cheap, reliable, and something you'd genuinely want to stop on every time.
- **An MCP config** for a tool this hub doesn't integrate with yet (add it to `.mcp.json` and
  document the setup/approval steps in `HUB.md`, the way `designer`'s Figma + Playwright entry
  does).

## Licensing

This repo is MIT (see `LICENSE`). If you're porting content from another project, confirm its
license is compatible (MIT/Apache-2.0/BSD are fine; anything with a stricter copyleft or
non-commercial clause needs a conversation first) and add an entry to `THIRD_PARTY_NOTICES.md`
crediting the source, the same way the existing entries do.

## What doesn't belong here

- Anything that duplicates a native Claude Code feature (auto-memory, `/compact`, etc.) — this
  hub deliberately excludes content like that; see the note in `HUB.md`.
- Business-, content-, or language-specific skills unrelated to software engineering — keep the
  hub's scope coherent.
- Large binary or dataset assets (reference image/logo libraries, model weights, etc.) — link to
  the upstream source instead of vendoring them in.

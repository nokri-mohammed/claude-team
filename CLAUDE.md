# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Role

This directory is the working space for a local IT assistant, and is also the **homelab-team hub**: the CTO session the user talks to directly, holding canonical agent/skill definitions (see `HUB.md`). It still manages the user's local homelab server and checks it for vulnerabilities — the user owns the homelab, so security checks against it are authorized. Keep all scanning and testing within that environment.

## Current state

Git repo, versioned with `commit-and-tag-version` (see `HUB.md` → Versioning & Releases). Run
`npm test` before committing — it checks skill line limits, agent `tools:` fields, and dangling
`references/*.md` pointers. `agents/`, `skills/`, `commands/`, `hooks/`, `HUB.md`, and
`backlog-template.md` hold the hub's canonical definitions for spinning up per-project teams. This
directory (`hub/`) and project workspaces (`~/projects/homelab-team-all/projects/<name>/`) are
siblings inside `~/projects/homelab-team-all/`, each project copying/symlinking only the subset of
agents/skills/commands/hooks it needs — this keeps this directory's own CLAUDE.md from leaking
into any project via ancestor-path auto-loading.

## Git Workflow

Commit messages **must** start with a Conventional Commits type (`feat:`, `fix:`, `chore:`,
`docs:`, `refactor:`, `perf:`, `test:`, `build:`, `ci:`, `revert:`), with a `BREAKING CHANGE:`
footer when relevant — `commit-and-tag-version` derives both the semver bump and `CHANGELOG.md`
from this, so a wrongly-typed commit produces a wrong release. Never amend or force-push a commit
that's already been released (tagged) — a release tag marks history as fixed from that point.

## When to Delegate to a Subagent

Don't do architecture, implementation review, or design work inline that one of the hub's agents
already owns — delegate instead of re-deriving their process in the main thread:

| Task | Agent / command |
|---|---|
| System design, trade-off analysis, ADRs | `architect` / `/plan` |
| C4 documentation at any level | `c4-context`, `c4-container`, `c4-component`, `c4-code` |
| Code review (quality/maintainability) | `code-reviewer` / `/code-review` |
| Security-sensitive diff (auth, secrets, injection, payments) | `security-reviewer` |
| Docs/CODEMAP sync after a task | `doc-updater` |
| Test-first development | `tdd-guide` / `/tdd` |
| UI/UX, design systems, Figma-to-code, visual/responsive/a11y review | `designer` |

A simple, single-file task doesn't need a subagent at all — scale the team to the task, not the
other way around (see `HUB.md` bootstrap step 6).

## Environment

- Work runs from WSL2 (Linux) on the user's machine, not on the homelab server itself. Reaching the server means going over the network, for example via SSH.
- Scan targets, host addresses and the service inventory are not recorded yet. Ask the user for them, or record them here once confirmed, instead of guessing.

## Conventions

- Confirm before any change that alters the server's state, such as installing or removing packages, editing configs, restarting services or changing firewall rules. Read-only inspection and scans of confirmed homelab hosts need no confirmation.
- Put scan output, findings and notes in this directory so they persist between sessions.

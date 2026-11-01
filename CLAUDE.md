# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Role

This repository is a hub of canonical Claude Code agent, skill, command, and hook definitions (see
`HUB.md`) — a curated team of subagents (architect, reviewers, tdd-guide, designer, etc.) that
individual projects copy or symlink from, taking only the subset each project actually needs.

## Current state

Git repo, versioned with `commit-and-tag-version` (see `HUB.md` → Versioning & Releases). Run
`npm test` before committing — it checks skill line limits, agent `tools:` fields, and dangling
`references/*.md` pointers. `agents/`, `skills/`, `commands/`, `hooks/`, `HUB.md`, and
`backlog-template.md` hold the hub's canonical definitions for spinning up per-project teams.

Keep this repository as a **sibling** of the projects that consume it, never an ancestor directory
of one — Claude Code loads `CLAUDE.md` from every ancestor of the working directory, so if a
project lived underneath this repo, this file would auto-load into every session in that project
whether it copied anything from here or not.

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

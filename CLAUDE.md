# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Role

This directory is the working space for a local IT assistant, and is also the **homelab-team hub**: the CTO session the user talks to directly, holding canonical agent/skill definitions (see `HUB.md`). It still manages the user's local homelab server and checks it for vulnerabilities — the user owns the homelab, so security checks against it are authorized. Keep all scanning and testing within that environment.

## Current state

No build or test tooling, no git history. `agents/`, `skills/`, `HUB.md`, and `backlog-template.md` hold the hub's canonical definitions for spinning up per-project teams. This directory (`hub/`) and project workspaces (`~/projects/homelab-team-all/projects/<name>/`) are siblings inside `~/projects/homelab-team-all/`, each project copying/symlinking only the subset of agents/skills it needs — this keeps this directory's own CLAUDE.md from leaking into any project via ancestor-path auto-loading.

## Environment

- Work runs from WSL2 (Linux) on the user's machine, not on the homelab server itself. Reaching the server means going over the network, for example via SSH.
- Scan targets, host addresses and the service inventory are not recorded yet. Ask the user for them, or record them here once confirmed, instead of guessing.

## Conventions

- Confirm before any change that alters the server's state, such as installing or removing packages, editing configs, restarting services or changing firewall rules. Read-only inspection and scans of confirmed homelab hosts need no confirmation.
- Put scan output, findings and notes in this directory so they persist between sessions.

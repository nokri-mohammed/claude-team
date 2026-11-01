---
description: Produce an architecture/implementation plan for a feature or system change, via the architect agent.
argument-hint: <feature or system change to plan>
---

Delegate to the `architect` subagent to plan: $ARGUMENTS

It should review current-state architecture, gather functional and non-functional requirements,
propose a design with trade-off analysis, and produce a system design checklist. If the decision is
significant enough to outlive this task, ask it to write an ADR under `docs/architecture.md` rather
than only reporting back inline.

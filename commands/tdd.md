---
description: Run the TDD workflow (red-green-refactor) for a feature or fix, via the tdd-guide agent.
argument-hint: <feature or fix to build test-first>
---

Delegate to the `tdd-guide` subagent for: $ARGUMENTS

Give it the full context of what's being built or fixed (acceptance criteria, affected files, test
runner already in use if known). Wait for its TDD evidence report before continuing — do not mark
the task done until it has.

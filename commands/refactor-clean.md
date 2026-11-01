---
description: Find and remove dead code, unused exports, and redundant logic without changing behavior.
argument-hint: [optional scope, e.g. "src/api only"]
---

Find and remove dead code and redundancy. Scope: $ARGUMENTS (whole project if not given).

1. Look for unused exports, unreferenced files, duplicated logic that could collapse into one
   implementation, and now-unreachable branches — not stylistic nitpicks.
2. Apply the project's `coding-standards` skill (if present) for what "clean" means here: KISS,
   DRY, YAGNI, no premature abstraction.
3. This is a behavior-preserving pass, not a rewrite — if removing something changes observable
   behavior, flag it instead of removing it silently.
4. Run the project's existing tests after each removal, not just at the end — a dead-code removal
   that breaks a test wasn't actually dead.
5. Report what was removed and why, as a short list, not a full diff narration.

For bugs, simplification beyond dead-code removal, or efficiency issues, that's a different job —
use `/code-review` or the general `simplify` skill instead.

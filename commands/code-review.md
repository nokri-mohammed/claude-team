---
description: Review the current diff for quality, security, and maintainability, via code-reviewer (and security-reviewer when the diff touches auth/secrets/payments/injection surfaces).
argument-hint: [optional focus, e.g. "just the API layer"]
---

Delegate to the `code-reviewer` subagent to review the pending changes: $ARGUMENTS

If the diff touches authentication, secrets, payments, user input handling, or anything else on the
`security-review` skill's checklist, also delegate to `security-reviewer` and report both results
together. Findings from either agent are written as Conventional Comments (see the
`conventional-comments` skill) — don't flatten them back into prose.

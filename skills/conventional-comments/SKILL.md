---
name: conventional-comments
description: Format every code review comment and finding using the Conventional Comments standard (conventionalcomments.org) — a labeled, machine-parseable comment format. Use whenever reviewing code, leaving PR comments, or writing up review findings for any agent (code-reviewer, security-reviewer, or an engineer reviewing another engineer's work).
metadata:
  origin: conventionalcomments.org
---

# Conventional Comments

A structured format for code review comments. Every review comment — in a PR, in a backlog entry,
in a review agent's output — follows this shape instead of free-text prose.

## Format

```
<label> [decorations]: <subject>

[discussion]
```

- **label** — one word naming the kind of comment (required)
- **decorations** — optional, comma-separated, in parentheses — add context like blocking status or topic
- **subject** — the one-line point of the comment (required)
- **discussion** — optional supporting detail, reasoning, or next steps

## Labels

| Label | Use it for |
|---|---|
| **praise** | Something genuinely good. Include at least one per review, only when sincere — never pad a review with a fake one. |
| **nitpick** | A trivial, preference-based request. Non-blocking by nature. |
| **suggestion** | An improvement. State clearly what's suggested and why it's better. |
| **issue** | A specific problem (user-facing or internal). Pair with a `suggestion` fixing it when possible. If you're not sure it's actually a problem, use `question` instead. |
| **todo** | A small, necessary change — distinct from `issue` (not a defect) and `suggestion` (not optional). |
| **question** | A concern you're unsure is even relevant; asking the author to clarify or investigate. |
| **thought** | An idea that came up during review. Non-blocking by nature; can seed a larger follow-up. |
| **chore** | A small required task before this can be accepted (e.g. "run the lint fixer"). Link the process if one exists. |
| **note** | Always non-blocking. Flags something the reader should know, nothing more. |

Optional, more expressive variants: **typo** (a `todo` where the issue is a misspelling), **polish**
(a `suggestion` where the content is already fine), **quibble** (a lighter-hearted `nitpick`).
Diverge from this list when a situation genuinely calls for it — it's a convention, not a lockstep.

## Decorations

| Decoration | Meaning |
|---|---|
| **(blocking)** | This must be resolved before the change is accepted. |
| **(non-blocking)** | This should not prevent the change from being accepted. |
| **(if-minor)** | Resolve only if the fix turns out to be small/trivial. |

Decorations can be stacked with a topic tag, e.g. `issue (security, blocking)` or
`suggestion (test, if-minor)` — keep the set minimal and unambiguous; don't stack more than one or
two per comment.

## Examples

```
issue (blocking): Hardcoded API key in source

File: src/api/client.ts:42
This key will land in git history the moment this is committed.

suggestion: Move it to an environment variable and add a placeholder to .env.example.
```

```
nitpick: `little star` => `little bat`
```

```
praise: Clean separation between the fetch and the validation layer here — exactly the service
pattern from frontend-patterns.
```

```
question (non-blocking): Does this need to handle the empty-array case, or is that unreachable
given how the caller filters first?
```

## Severity mapping for this hub's review agents

`code-reviewer` and `security-reviewer` keep their CRITICAL/HIGH/MEDIUM/LOW severity tiers for
triage — but every individual finding is written as a Conventional Comment, mapped like this:

| Severity | Conventional Comment |
|---|---|
| CRITICAL | `issue (blocking)` |
| HIGH | `issue (non-blocking)` |
| MEDIUM | `suggestion` |
| LOW | `nitpick` |

A clean review that found nothing wrong should still look for one honest `praise:` to include —
per the standard's own guidance, never a manufactured one.

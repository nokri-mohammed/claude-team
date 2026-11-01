---
name: asd-ste100
description: Writing standard for hub documentation (SKILL.md files, agent docs, README files, commit messages). Based on ASD-STE100 (Simplified Technical English), a controlled-language standard built for clear technical writing. Use when writing or editing any documentation in this hub, or when a project copies docs from here and wants the same clarity standard.
---

# ASD-STE100 for Hub Documentation

This skill adapts [ASD-STE100](https://www.asd-ste100.org/) (Simplified Technical English), a
controlled-language standard from the aerospace industry, for this hub's own documentation. The
goal is the same one STE was built for: one reader, one meaning, no ambiguity.

This applies to documentation **we write ourselves**: `SKILL.md` files, agent `.md` files,
`README.md`, `HUB.md`, `GUIDE.md`, `CONTRIBUTING.md`, command docs, and commit messages. It does
not apply to third-party content copied in from other projects. See `THIRD_PARTY_NOTICES.md` for
what that is; leave that prose in its original style.

## The rules

**Write short sentences.** Use 20 words or fewer for an instruction. Use 25 words or fewer for any
other sentence. Split a long sentence into two short ones.

**Put one instruction in each sentence.** Do not chain two actions with "and" or "then" if they
can be two separate steps.

**Use the active voice.** Write "the hook blocks the commit," not "the commit is blocked by the
hook." The active voice names who or what does the action.

**Use simple verb tenses.** Use the simple present for facts ("the script checks the message"),
the imperative for instructions ("run `npm test`"), and the simple past for what already happened.
Avoid compound tenses where a simple one works.

**Use articles.** Write "the agent reads the file," not "agent reads file." Dropping articles to
save words makes a sentence harder to parse, not easier.

**Avoid long noun strings.** "The agent tool permission denial handler" is four nouns stacked
together. Rewrite it as "the handler that denies an agent a tool." Three nouns in a row is the
most to use before rewriting.

**Avoid "-ing" words as nouns or adjectives.** Write "to start the server," not "server starting."
Write "a file that fails," not "a failing file." The imperative or a relative clause is almost
always clearer.

**Use the same word for the same thing, every time.** If a document calls something an "agent" in
one sentence, do not call it an "assistant" or "subagent" two sentences later for variety.
Consistent naming matters more than varied prose here.

**Write procedures as numbered steps.** One action per step, in the order the reader performs
them. Do not bury a step inside a paragraph.

**Write warnings, cautions, and notes in a fixed form**, when a document needs one:
- **Warning:** tells the reader about a risk to people or data that cannot be undone.
- **Caution:** tells the reader about a risk of breaking something recoverable (a build, a test
  run, a local file).
- **Note:** gives extra information that is not a risk.

**Avoid dashes and semicolons that join two independent clauses.** Split them into two sentences
instead. This hub also never uses em dashes at all (a separate, stricter rule): see the project's
own writing preference, which this skill reinforces rather than replaces.

**Define jargon on first use, or avoid it.** A term like `.mcp.json`, `SKILL.md`, or `tools:` is
fine once the reader has seen what it does. A term borrowed from another domain without
explanation is not.

## Quick self-check

Before committing a doc change, check it against this list:
- [ ] No sentence over 25 words (20 for an instruction)
- [ ] No sentence with more than one instruction
- [ ] No passive voice where the actor is known
- [ ] No noun string longer than three words
- [ ] No "-ing" word standing in for a noun or adjective
- [ ] The same term used for the same thing throughout
- [ ] Any procedure is numbered steps, not a paragraph
- [ ] No em dash, no dash or semicolon joining two full sentences

## Why this, not just "write clearly"

"Write clearly" is not a checklist. STE is. A reviewer, or an agent, can check a sentence against
these rules mechanically, the same way `validate-hub.sh` checks a SKILL.md's line count. That is
the actual point of a controlled-language standard: it turns a style preference into something you
can verify.

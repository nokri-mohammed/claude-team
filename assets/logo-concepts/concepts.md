# Claude Team — logo concepts

Brief: open-source curated collection of Claude Code subagents, skills, slash commands and hooks ("a
ready-made team" devs copy selectively into their own projects). Audience: engineers browsing GitHub.
Tone: technical, credible, clever — not corporate, not cutesy. Must work as a 16 px favicon/avatar and
as a wordmark lockup in a README header.

Category clichés avoided: robot/mascot heads, circuit-board textures, generic AI "sparkle" bursts,
gradient blobs, handshake icons, literal globe/shield fintech-style marks.

## Longlist (8–12 one-liners)

1. **Tag Team** — opposing angle brackets `<` `>` cradle a small three-dot roster, like an HTML/JSX tag
   holding a team. *(built — Concept A)*
2. **Draft Deck** — three stacked, graduated rounded-square cards, like a hand of agent cards you draft
   into your project. *(built — Concept B)*
3. **CT Cursor Monogram** — a custom "C" interlocked with a "T" whose stem doubles as a blinking
   terminal cursor. *(built — Concept C)*
4. **Rank Chevron Stack** — three nested right-pointing chevrons (terminal prompt `>` read as rank
   insignia) for a lineup of specialised roles.
5. **Orbit Node Cluster** — a lead node with three satellite nodes on thin struts, a tight multi-agent
   graph abstracted into a badge.
6. **Low-Poly Knight** — a faceted, straight-edged chess-knight silhouette: one specialised piece doing
   a job within a larger team.
7. **Hex Module Pie** — a single hexagon split into three equal wedges (agent / skill / hook) inside one
   outer border.
8. **Prompt Caret Lineup** — three graduated `^`/caret marks side by side, the team drawn as a tiny
   bar-chart of cursors.
9. **Double Chevron Shield** — two opposing `>` chevrons nested into a minimal shield/badge outline —
   code plus credibility badge.
10. **Pipeline Nodes** — a single horizontal pipe (`|`, the CLI pipe) with three small circular nodes
    riding it, a staffed command pipeline.
11. **Bracket Starburst** — a radial star built entirely from paired `< >` brackets instead of generic
    AI-sparkle rays.
12. **Interlocking Gear-Bracket** — a code bracket whose inner corner is cut to a gear tooth, hinting at
    "tooling" without drawing a literal gear.

## The three built

### A — Tag Team
`assets/logo-concepts/concept-1.svg`
Two mirrored angle-bracket chevrons (round-capped, 45°, stroke-based) face each other around three
dots of graduated size — a lead agent flanked by two others, literally held inside a code tag. At
large sizes it reads clearly as `< team >`; at 16 px the caps merge and it reads instead as a bold
diamond/gem badge with a dot at its core — still distinctive and usable as a favicon, but the explicit
bracket pun only survives at ≥32 px (README header, social card).

### B — Draft Deck
`assets/logo-concepts/concept-2.svg`
Three identical rounded-square "cards" fanned on a diagonal, tonal steps (22% / 50% / 100% black) for
depth. Reads instantly as a stack/deck — the most literal metaphor for "pick what you need from a
curated set." Weakest of the three at 16 px: the offset and tonal steps compress into a single soft
blob and the stack cue is nearly gone; it still works as a plain rounded-square avatar, just without
the concept doing any work at favicon size. Also the closest of the three to an existing UI cliché
(files/wallet "stack" icon), so it leans more generic than clever.

### C — CT Cursor Monogram
`assets/logo-concepts/concept-3.svg`
A custom "C" (built as an open circular arc, parenthesis-style) interlocks with a custom "T" whose
vertical stem runs past the baseline like a terminal cursor/caret. Doubles as the initials of "Claude
Team" and as a nod to the CLI the whole product lives in. Passed every test in the loop: recentred to
perfect optical balance (L28/R28, T44/B44), reads unambiguously as "CT" at 64, 32 **and 16 px** in the
rendered pixel test — the only one of the three concepts whose core idea survives all the way down to
favicon size.

## Recommendation

**C — CT Cursor Monogram.** It is the only concept that keeps its idea intact at 16 px (the brief's
hard constraint), it is tied directly to the name rather than a generic team/AI metaphor, and the
cursor-stem detail gives developers a specific, technical "aha" instead of a mood (team spirit,
collection) that any product could claim. Risk to flag: as a monogram it leans on the viewer already
knowing the project name — pair it with a wordmark lockup in the README header rather than relying on
the symbol alone on first contact.

Runner-up: **A — Tag Team**, strong and more literally "collection of agents," but its bracket pun
only survives at README/social-card sizes, not at the 16 px favicon — fine if the favicon is allowed to
read as "distinctive badge" rather than "literal brackets." **B — Draft Deck** is the safest-looking but
least ownable and loses the most meaning at small size; not recommended as the lead direction.

A human should pick between the three before any kit (colour, lockups, favicon/app-icon exports,
presentation board) is built.

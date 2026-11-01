# Claude Team — logo concepts, round 2

New direction brief (from user's moodboard, "I like this style"): drop thin uniform-stroke
construction entirely; work in solid filled shapes, using (1) same-colour/same-opacity overlap so
the intersection reads as a third, darker tone, and (2) negative-space cutouts carved from one solid
silhouette. Restrained, architectural geometry; no rounded stroke caps, no decorative flourish.

Three new concepts built, each testing a different technique from the moodboard:

## Round2‑1 — CT Overlap Monogram
`assets/logo-concepts/round2-1.svg`
Rebuilds the round‑1 "CT" idea in the requested language: the "C" is now a true filled crescent
(outer ring minus inner ring minus a flat-cut wedge — no stroke), and the "T" is two filled
rectangles with square, architectural corners. Both shapes share the same fill colour at 62%
opacity, so where the T's crossbar crosses the C's ring the overlap compounds to a visibly darker
patch — the exact "third tone from transparency" trick on the moodboard, applied directly to the
monogram that tested best for name-recognition and 16 px legibility in round 1.
**Trade-off found in testing:** because the *whole* mark sits at 62% opacity (not just the overlap),
it renders as mid-grey rather than solid black — at 16 px the C+T shapes are still clearly readable,
but with less contrast than a fully solid mark. Standard fix: ship this as the README/medium-size
version and cut a second, fully-opaque favicon version at 16–32 px (the testing checklist's normal
"simplified small-size companion" — size, not idea, is what needs to change).

## Round2‑2 — Socket Tray
`assets/logo-concepts/round2-2.svg`
One solid rounded-square tile with three circular holes punched out in an ascending diagonal —
pure negative-space carving, the technique behind the moodboard's pin-hole and leaf-heart marks.
Reads as a module/socket panel you plug specialised agents into — a fairly literal match for "copy
selectively from a curated set." By far the highest-contrast and most legible of the three at every
size tested, including 16 px, because it stays fully solid black/white rather than relying on
partial opacity. Honest note: at a glance it can also read as a triple-lens camera module — not a
bad association for a precision dev tool, but worth being aware of since it isn't the intended
reading.
*(Built with white circles over a black tile for this exploration; production master should cut
these as true holes via `fill-rule="evenodd"` so the mark still works as a one-colour/knockout
version — flagged by `svg_audit.py` as expected at this stage.)*

## Round2‑3 — Agent Diamonds
`assets/logo-concepts/round2-3.svg`
Three same-size diamonds (rotated squares) in a tight cluster — not two, like the moodboard's plain
Venn example, but three, so the centre where all three overlap compounds to a fourth, near-black
tone (the darkest point = "where the team actually works together"). At large/medium size this is
the most elegant and premium-feeling of the three, closest in spirit to the moodboard's gem/diamond
and N-overlap marks. At 16 px it is the softest of the three: the silhouette (a crown/gem outline)
still reads, but the "three distinct overlapping members" story collapses into a single grey blob —
similar small-size trade-off to round 1's Concept A.

## Recommendation

**Round2‑1, CT Overlap Monogram**, for the same reason round 1's Concept C won: it is the only one
of the three that keeps a specific, ownable idea (the literal initials, built as code/cursor-adjacent
geometry) legible at 16 px, not just a pleasant abstract silhouette. Pair it with a solid-black
small-size cut for the actual favicon/avatar files, and use the 62%-opacity version wherever size
allows the tone detail to register (README header, social preview, docs site).

**Round2‑2, Socket Tray** is the strongest runner-up and arguably the safer pick if 16 px contrast is
weighted above name-recognition — it needs no small-size companion, it's already maximally legible.

**Round2‑3, Agent Diamonds** is the best "hero" mark for large contexts (README banner, social card,
slide decks) but is not recommended as the primary favicon/avatar on its own.

No direction has been finalised — these three, plus the three from round 1, are all still open for
the user to choose between (or to request a third round).

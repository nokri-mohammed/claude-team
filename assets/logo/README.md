# Claude Team logo — file guide

Direction: **Agent Diamonds** — three overlapping diamonds (same colour, partial opacity) whose
intersections compound into a darker third tone, in the solid-shape/overlap language from the
approved moodboard. Monochrome ink `#141414` on a cream/white ground; see "Colour" below.

## The two masters

- **`/home/mo/projects/homelab-team-all/hub/assets/logo.svg`** — the full mark, 3 diamonds at 60%
  opacity, optically centred. Use wherever the mark renders at roughly **32px or larger**
  (README body, docs site, app UI, large avatars) — this is the version with the tonal depth that
  makes the concept work.
- **`/home/mo/projects/homelab-team-all/hub/assets/logo-mark-small.svg`** — same geometry, same
  diamonds, opacity raised to 100% so the three shapes fuse into one solid silhouette. Use for
  **favicons, browser tabs, and any context at roughly 24px or smaller**. The 60%-opacity master
  turns into a soft grey blob at 16px (tested and rejected — see round2-concepts.md); this cut
  stays a crisp, high-contrast badge down to 16px (verified in the 16px pixel test, see below).
  It's not a different idea, just the same shapes with the tone effect — which only reads once
  there's enough room to see it — turned off.

## Exported variants (this folder)

All generated from `logo.svg` via `scripts/export_variants.py`, using `logo-mark-small.svg` as
the small-size source for every favicon/icon output:

| File | Use |
|---|---|
| `logo-black.svg` / `logo-white.svg` | one-colour versions for light / dark backgrounds |
| `logo-square.svg` (+ PNG 32/512/1024) | mark centred on a padded square canvas — avatar master |
| `logo-app-icon.svg` (+ PNG) | mark in cream on a dark rounded-square tile (app/package icon look) |
| `logo-favicon.svg` (+ PNG) | tight-cropped favicon SVG, built from the small-size cut |
| `favicon.ico`, `favicon-16/32/48.png`, `apple-touch-icon.png`, `icon-192/512.png`, `maskable-512.png`, `site.webmanifest`, `head-snippet.html` | full web/PWA icon set — drop `head-snippet.html`'s contents into an HTML `<head>` as-is |
| `social-preview-1280x640.png` (+ `.svg` source) | GitHub social preview card (Settings → social preview). Dark background, mark + "Claude Team" wordmark + one-line description. |
| `readme-header.png` (+ `.svg` source) | compact horizontal lockup (mark + wordmark + tagline) sized for a README header image, transparent/light background |

The two `.svg` sources under `social-preview-1280x640.svg` / `readme-header.svg` use live
`<text>` in a monospace stack (Ubuntu Mono / DejaVu Sans Mono, both present on this machine) —
acceptable here because each is rasterized once to PNG and the PNG is what actually ships. If you
edit the wordmark, re-render with `cairosvg` (or any Chromium browser) rather than trusting the
SVG's text rendering elsewhere.

## 16px test (small-size cut)

Rendered `logo-mark-small.svg` at literal 16×16px and inspected pixel-for-pixel (nearest-neighbour
zoom): reads as a solid, high-contrast badge with a clear peaked top and notched bottom — no mush,
passes the skill's 16px checklist item. The "three separate overlapping agents" story does not
survive at that size (expected and accepted per the skill's own guidance: design a simplified
small-size companion rather than force the full idea into too few pixels); what survives is the
family silhouette, which is what a favicon needs to do.

## Colour

Kept **strictly monochrome** (`#141414` ink / `#f5f3ee` cream, i.e. black-on-cream, white-on-dark
for reversal) — matches the moodboard (all 15 reference marks were monochrome), fits the
"technical, credible, not corporate" brief, and keeps the tonal-overlap trick doing all the work
instead of competing with a second variable. No accent colour was added. If a single accent is
wanted later (e.g. for the web-icon tile or an OG-image highlight), it's a cheap follow-up — swap
the `--icon-bg`/`--icon-fg` values in the `export_variants.py` call — but it hasn't been assumed
here, flagging it rather than deciding it.

## Not included (by request — small OSS repo, not a client deliverable)

No full brand-guidelines document, no clear-space/misuse diagrams, no multi-page identity system.
If the project grows into something that needs that, re-run Phase 7 of the logo-design skill's
process with `templates/brand-guidelines-template.md`.

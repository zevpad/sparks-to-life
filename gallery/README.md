# Handmade gallery site

A one-page gallery for the handmade-pieces studio: hero, photo grid,
WhatsApp order modal (4 questions, optional wish list), and
click-to-call fallback. Lives at `/gallery/` so the tester-signup page
at the repo root is untouched. Once deployed via GitHub Pages it is
served at `https://<user>.github.io/sparks-to-life/gallery/`.

## Finish the setup (3 steps)

1. **Drop the 9 photos into the repo's `/images/` folder** (repo root,
   not inside `gallery/`), named `work-01.jpg` … `work-09.jpg`.
   `work-01.jpg` must be the best group shot — it doubles as the hero
   background. Until the photos exist, tiles render as neutral
   "photo coming soon" placeholders, so the page never looks broken.

2. **Edit the `CONFIG` block at the top of `gallery/site.js`:**
   - `studioName` — the studio / artist name shown in the hero and footer
   - `whatsappNumber` — international format, digits only (`972501234567`)
   - `phoneDisplay` / `phoneDial` — the click-to-call number

3. **Fill in captions and alt text** in the `MANIFEST` array in
   `gallery/site.js` (from the planning manifest). Empty captions are
   fine — the tile just shows no label.

## Open slots

The last two `MANIFEST` entries (`Biblical scenes`, `Chess sets`) are
"coming soon" tiles. When those photos exist, give each entry a `src`
(and drop the JPG into `/images/`) and it becomes a normal gallery tile.

## How the WhatsApp modal works

The four questions (name, interest, timing, optional wish list) are
combined into a prefilled `wa.me` message and opened in WhatsApp — no
form backend, no separate inbox. The wish list is appended only when
filled in. Visitors without WhatsApp get the click-to-call link shown
in the hero, the closing section, and inside the modal.

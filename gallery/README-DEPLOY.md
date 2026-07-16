# McLevy's Candle Alchemy — deploy notes

The site is a single self-contained page at `gallery/index.html`
(all CSS/JS inline, no build step), plus one Cloudflare Pages Function
at `functions/api/notify.js` (repo root — Cloudflare requires the
`functions/` directory at the project root). This repo already deploys
to Cloudflare Pages, so the page is served at `/gallery/` and the
function at `/api/notify`.

## Finish the content (2 steps)

1. **Photos** — upload the 9 JPGs to the repo's `/images/` folder with
   these names (mapping from the originals):

   | File | Original |
   |---|---|
   | `images/mushroom-head.jpg` | 68814.jpg |
   | `images/penguin-pair.jpg` | 68806.jpg |
   | `images/penguin-squad.jpg` | 68813.jpg |
   | `images/trophy-penguins.jpg` | 68809.jpg |
   | `images/profession-penguins.jpg` | 68812.jpg |
   | `images/reader-penguins.jpg` | 68807.jpg |
   | `images/bat-penguin.jpg` | 68811.jpg |
   | `images/birthday-penguin.jpg` | 68810.jpg |
   | `images/studio-scene.jpg` | 68808.jpg |

   `penguin-squad.jpg` also becomes the hero background automatically.
   Until a photo exists, its tile shows a neutral "photo coming soon"
   placeholder. Search `index.html` for `REPLACE` to find the remaining
   placeholder slots (portrait, biblical scenes, chess sets, OG image).

2. **Phone number** — already set to the real number in the single
   `PHONE` constant at the top of the `<script>` block in
   `gallery/index.html`. One-line fix if it ever changes.

## Inquiry notification beacon (one-time setup)

When a visitor taps Send in the booking modal, the page fires a
best-effort `sendBeacon` to `/api/notify`, which forwards a WhatsApp
message to the admin via the CallMeBot API. It never blocks or delays
the visitor's WhatsApp redirect, transmits only the questionnaire
selections (no names or personal data), and fails silently.

To activate:

1. From the **admin's WhatsApp**, send the CallMeBot activation message
   to their bot number to receive an API key — see
   https://www.callmebot.com/blog/free-api-whatsapp-messages/
2. In the Cloudflare Pages dashboard → project → **Settings →
   Environment variables**, set:
   - `ADMIN_PHONE` — the admin's WhatsApp number, international format,
     digits only (the same number that was activated with CallMeBot)
   - `CALLMEBOT_APIKEY` — the key from step 1
3. Redeploy. Until both variables are set, the function is a silent
   no-op (still returns 204).

Swapping CallMeBot for an email provider later (e.g. Resend) only
requires editing `functions/api/notify.js` — the client code doesn't
change.

## Custom domain: tzfatcandles.thehonuway.com

`functions/_middleware.js` rewrites `/` to the McLevy page whenever the
request arrives on the candle subdomain (visitors see a clean
`tzfatcandles.thehonuway.com`, no `/gallery/` in the URL). All other
hosts and paths are untouched, so the tester page keeps working at the
project's default URLs. Two one-time steps in the dashboards:

1. **Cloudflare Pages** → the `tzfatcandles` project → **Custom domains**
   → *Set up a custom domain* → enter `tzfatcandles.thehonuway.com`.
   Cloudflare shows the exact DNS record it wants.
2. **Wherever thehonuway.com's DNS is managed** (registrar or DreamHost
   — the www record currently points at DreamHost), add that record:
   a `CNAME` for `tzfatcandles` → `tzfatcandles.pages.dev`.

Certificates are issued automatically once the CNAME resolves (usually
minutes). If the subdomain ever changes, set a `CANDLE_HOST` env var on
the Pages project instead of editing code.

## Migrating to the `tzfatcandles` Cloudflare Pages project

The site was first deployed under a Pages project named `sparks-to-life`.
To move it to a project named `tzfatcandles` (account
`91f1502e4d7aca3cba37b535db0ac38a`), in the Cloudflare dashboard:

1. **Workers & Pages → Create → Pages → Connect to Git** → pick the
   `zevpad/sparks-to-life` repo. Name the project **`tzfatcandles`**,
   set the production branch to **`main`**, leave build command empty
   and output directory `/`. Deploy — it builds the current `main`.
2. **Re-set the environment variables** on the new project (they do NOT
   carry over): Settings → Environment variables → add `ADMIN_PHONE` and
   `CALLMEBOT_APIKEY` (see the beacon section above). Redeploy so they
   take effect.
3. **Attach the custom domain** `tzfatcandles.thehonuway.com` to the new
   project (Custom domains → Set up), and point the `tzfatcandles` CNAME
   at `tzfatcandles.pages.dev` per the section above.
4. **Verify** the new project serves the site and the booking beacon
   reaches WhatsApp.
5. **Only then delete** the old `sparks-to-life` project (its
   Settings → Delete project). Remove its custom domain first if one was
   attached, so DNS doesn't dangle.

## Pricing

Prices are deliberately not rendered. They live in an HTML comment in
the Workshops section of `index.html` for easy enabling later.

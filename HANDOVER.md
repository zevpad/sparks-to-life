# Project Handover

This document hands over every project that exists in this repository (`sparks-to-life`) as of **2026-08-11**. There is currently **one project** in the repo: the Google Play Tester Signup landing page.

---

## 1. Google Play Tester Signup — Landing Page

### What it is
A single-page, mobile-first static website used to recruit ~14–20 Android users to join a **closed Google Play beta test** for 14 days. It sets expectations up front (commitment required, no early opt-out), explains the process, collects tester details through a form, and answers common questions.

### Status: functional, not yet wired to a real form backend

The page is complete and production-ready **except for one manual step**: the signup form still posts to a placeholder URL and needs to be connected to a real form backend before testers can actually submit it (see [Outstanding work](#outstanding-work)).

### Tech stack
- Plain HTML5 / CSS3 / vanilla JavaScript — **no framework, no build step, no package.json, no dependencies**.
- Google Font "Inter" loaded via `<link>` (Google Fonts CDN).
- Designed to be hosted as a static site (Cloudflare Pages or Vercel, per the README).

### File structure
```
sparks-to-life/
├── index.html   — All page markup/content (single page, section-based)
├── styles.css   — All styling (mobile-first, CSS custom properties for theme)
├── script.js    — Form validation, async submit, smooth-scroll
└── README.md    — Setup/deploy instructions for whoever runs this
```

### `index.html` — page structure
Sections, top to bottom:
1. **Hero** (`.hero`) — headline "I need 14 reliable Android testers," subheadline, primary CTA anchor-linking to `#signup`, and a note that the app may cost ~₪1.
2. **What I Need From You** (`#requirements`) — checklist of expectations (Android phone, Gmail on Play, install & keep installed 14 days, respond if asked, etc.).
3. **Commitment Notice** (`#commitment`) — a highlighted warning card reiterating that flaking out (uninstalling/opting out) can delay the app launch.
4. **How It Works** (`#how-it-works`) — numbered 7-step process from signup → join Play test → install → 14 days → feedback.
5. **Signup Form** (`#signup`) — the actual conversion point. Fields: full name, Gmail (must end `@gmail.com`), WhatsApp number, Android phone model, plus 4 required checkboxes (has Android, commits to 14 days, won't uninstall without talking to Zev first, consents to contact). Submits via `<form action="FORM_ACTION_URL_HERE" method="POST">`.
6. **FAQ** (`#faq`) — 6 Q&As (Android-only, iPhone not supported, possible ~₪1 cost, what's required, can uninstall after 14 days, consequence of early uninstall).
7. **Footer** — simple thank-you line.

Currency and contact details in the copy are localized/personalized: prices are in **₪ (ILS)**, and the checkbox copy explicitly names **"Zev"** as the person testers should talk to before uninstalling.

### `script.js` — behavior
- Waits for `DOMContentLoaded`, then wires up `#signup-form`.
- On submit: prevents default, runs `validateForm()`, disables the submit button and shows "Submitting…".
- `validateForm()`:
  - Confirms all non-checkbox required inputs are non-empty (adds `.invalid` class + shows an error banner if not).
  - Confirms the Gmail field ends in `@gmail.com` (case-insensitive) — shows a specific error if not.
  - Confirms all 4 required checkboxes are checked.
- **Demo mode fallback**: if `action` is missing or still equals the literal string `FORM_ACTION_URL_HERE`, it skips the network call entirely and just shows the success state. This means **the page currently "works" end-to-end in a browser but silently discards every submission** — nothing is actually being collected until a real form endpoint is wired in.
- Otherwise does a `fetch(action, { method: 'POST', body: new FormData(form), headers: { Accept: 'application/json' } })` and shows success/error based on the response.
- Clears `.invalid` styling on input/change per field.
- Adds smooth-scroll behavior to all in-page `href="#..."` anchor links (e.g. the hero CTA → `#signup`).

### `styles.css` — design system
- CSS custom properties in `:root` define the palette (blue accent `#2563EB`, slate text/muted tones, amber "notice" card, green success, red error) and shared radii/shadows.
- Mobile-first single-column layout, `max-width: 680px` centered container.
- Custom-styled checkboxes (native checkbox visually hidden, styled `.checkmark` sibling with an SVG-drawn check).
- Two responsive breakpoints: `min-width: 480px` (roomier padding) and `max-width: 400px` (tighter padding for small phones).
- `:focus-visible` outline defined globally for accessibility.

### `README.md` — already documents
- How to connect the form to **Formspree** (recommended), **Tally**, or **Google Forms** (with a caveat that Google Forms breaks the inline success message because it doesn't support cross-origin AJAX — it will hard-redirect instead).
- How to deploy to **Cloudflare Pages** and **Vercel** (both: no build command, output directory = root).
- How to preview locally with `python3 -m http.server 8080` or `npx serve .`.
- Product notes: page publicly advertises **14** testers needed, but recommends actually recruiting **16–20** so a dropout doesn't reset Google Play's 14-day closed-test clock. No analytics/tracking/ads by design.

### Outstanding work
1. **Form is not connected.** `FORM_ACTION_URL_HERE` in `index.html` (line 116) must be replaced with a real Formspree/Tally/Google Forms endpoint before this goes live, or all submissions will silently no-op into the demo success state (see `script.js` behavior above). This is the single most important thing for whoever picks this up next.
2. No automated tests exist (none are needed for a static page of this size, but there's also no CI/lint/build pipeline at all — this is intentional given the zero-dependency approach).
3. Not yet deployed anywhere as far as this repo shows — no deploy config (`vercel.json`, `wrangler.toml`, `_headers`, etc.) is present, so deployment is presumably done manually through the dashboards described in the README.
4. Copy is currently written for one specific launch (Zev's app, ₪ pricing, 14 testers) — if reused for a different app/tester round, the hardcoded numbers/names/currency in `index.html` would need updating.

### Git history
- `6443505` — Initial commit (empty repo scaffold).
- `68ab7a3` — "Add Google Play tester signup landing page" — the entire site was built in this single commit (Claude Sonnet 4.6, session `01TVybrr3EyZWqsiDUEaY76R`, June 2026). This is the only substantive commit in the project's history.

Branches in the repo: `claude/google-play-tester-signup-37z6gr` (where the page was built) and `claude/project-handover-docs-umrhdz` (this handover doc). Both currently point at the same commit as `main`'s work — there is no divergent unmerged work to be aware of.

---

## Summary for the next person/session

There is one project here: a finished, unstyled-yet-hosted signup landing page for Android beta testers. **The only blocking task before it's truly "done" is plugging in a real form backend URL.** Everything else — copy, validation, responsive design, deploy docs — is complete. No other projects, services, or codebases exist in this repository.

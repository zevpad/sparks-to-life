# Google Play Tester Signup — Landing Page

A mobile-first, commitment-focused landing page for recruiting Android closed-beta testers on Google Play.

---

## File structure

```
sparks-to-life/
├── index.html       — Complete landing page
├── styles.css       — All styles (mobile-first)
├── script.js        — Form validation + async submission
└── README.md        — This file
```

---

## Step 1 — Connect your signup form

Before deploying, replace the placeholder in `index.html`:

```
FORM_ACTION_URL_HERE
```

### Option A — Formspree (recommended, free, no backend needed)

1. Go to [formspree.io](https://formspree.io) and create a free account.
2. Create a new form and copy the endpoint URL (e.g. `https://formspree.io/f/xabcdefg`).
3. In `index.html`, find:
   ```html
   <form id="signup-form" action="FORM_ACTION_URL_HERE" method="POST" novalidate>
   ```
4. Replace `FORM_ACTION_URL_HERE` with your Formspree URL:
   ```html
   <form id="signup-form" action="https://formspree.io/f/xabcdefg" method="POST" novalidate>
   ```
5. Submissions go directly to your email. Done.

### Option B — Tally (free, beautiful responses dashboard)

1. Create a form at [tally.so](https://tally.so).
2. In Tally's settings, get the form's submission URL.
3. Replace `FORM_ACTION_URL_HERE` with the Tally endpoint.

### Option C — Google Forms (no code, familiar)

1. Create a Google Form with matching fields.
2. From the form settings, get the pre-filled form URL or the form action from the page source.
3. Replace `FORM_ACTION_URL_HERE` with the Google Form action URL.

> **Note:** Google Forms does not support cross-origin AJAX, so the page will redirect to Google after submission instead of showing the inline thank-you message. Tally or Formspree give a better in-page experience.

---

## Deploy to Cloudflare Pages

1. Push this repo to GitHub (or GitLab).
2. Go to [Cloudflare Pages](https://pages.cloudflare.com) → **Create a project**.
3. Connect your GitHub repo.
4. Build settings:
   - **Framework preset:** None
   - **Build command:** *(leave empty)*
   - **Output directory:** `/` (root) — or `.`
5. Click **Save and Deploy**.
6. Cloudflare will give you a `*.pages.dev` URL immediately.
7. To use a custom domain, go to **Custom domains** in the Pages project settings.

---

## Deploy to Vercel

1. Push this repo to GitHub.
2. Go to [vercel.com](https://vercel.com) → **New Project**.
3. Import your GitHub repo.
4. Framework settings:
   - **Framework preset:** Other
   - **Root directory:** `/`
   - **Build command:** *(leave empty)*
   - **Output directory:** `/`
5. Click **Deploy**.
6. You get a `*.vercel.app` URL in under a minute.
7. Custom domains are free and configurable in the project settings.

---

## Local preview

No build step needed. Just open `index.html` in a browser:

```bash
# Python (any OS)
python3 -m http.server 8080

# Node (if installed)
npx serve .
```

Then open `http://localhost:8080`.

---

## Notes

- **Tester target:** The page shows 14 publicly. Aim to recruit 16–20 so one dropout does not reset the 14-day Google Play clock.
- **Form fields collected:** Full name, Gmail, WhatsApp, phone model, and four commitment checkboxes.
- **No analytics, no tracking, no ads** by design.

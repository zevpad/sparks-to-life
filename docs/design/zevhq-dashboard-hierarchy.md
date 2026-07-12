# ZevHQ Dashboard — Design & Content Hierarchy Spec

**Status:** SPEC ONLY — no code, no schema changes. Logged as design chip.
**Implementation owner:** Codex (frontend), after ZevHQ-0704 master audit.
**Scope tag:** `[SHARED]` — token system applies to all tenants; content rules apply per-tenant via config.
**Author:** Principal Architect session, 2026-07-12.

---

## 1. Problem statement

The dashboard is visually "premium" but emotionally mute. Root causes, in priority order:

1. **No focal point.** Every card has identical weight, color, and elevation. Nothing leads.
2. **Leads with failure states.** `$0 MRR` and `0 DONE` occupy hero-adjacent tiles. The first data the owner sees daily is "nothing earned, nothing finished."
3. **Generic-luxury skin.** Gold serif on dark olive is a template look, not an identity. The two genuinely distinctive assets — the Hebrew calendar and the Honu brand — are footnotes.
4. **Greeting eats the viewport.** ~30% of first paint is a name and a platitude; the day's actual tasks sit below attention.

This spec fixes 1–2 with content hierarchy rules (Part A) and 3–4 with a design language (Part B).

---

## Part A — Content hierarchy rules

These are logic rules, not styling. They belong in the dashboard composition layer and should eventually be expressible per-tenant in `Tenant.config.dashboardContent` (consistent with the pending missionControlSeed migration — do not entangle the two; this spec only defines target behavior).

### A1. The hero is the most emotionally live element, not the greeting

Priority order for the hero slot:

1. **Active countdown** (e.g., Moshe Noam's Bar Mitzvah) — if any countdown is within 45 days.
2. **Next action** — the single top open task, if no countdown qualifies.
3. Greeting fallback — only if the tenant has no countdowns and no open tasks.

The greeting itself becomes a single line above the hero: `Good evening, Zev · Saturday, July 11 · כ״ו תמוז התשפ״ו`. One line. No motivational subtitle by default (tenant-configurable).

### A2. Stat tiles are conditional, not fixed

| Tile | Rule |
|---|---|
| MRR | Hidden while $0. Appears at first dollar. A zero is not a metric, it's a wound. |
| DONE | Shows only after ≥1 completion today. Before that, the slot shows the count of open tasks only. |
| ITEMS | Demote — total item count is inventory, not signal. Move to Library, not the daily view. |
| OPEN TASKS | Keep. This is the day's real number. |

Net effect: the dashboard opens with at most two numbers — days-to-go and open tasks. Both are actionable.

### A3. Tasks move above the fold

Task list renders directly under the hero. Search bar moves below the task list (search is a recovery action, not a primary one). The second "Daily Focus / Today" block merges with the task list — two task-like sections on one page is duplication.

### A4. Empty and zero states get direction, not mood

- Zero tasks: "Nothing open. Add tomorrow's first move." + add field focused.
- No countdown: hero falls through to next action (A1).
- Never render a zero-value metric tile as if it were an achievement tile.

---

## Part B — Design language ("Honu Dark")

### B1. Grounding

The brand is *The Honu Way* — the honu (Hawaiian green sea turtle): deliberate, long-lived, navigates by instinct across oceans, surfaces to breathe. The owner's world is Torah-observant family life on the Hebrew calendar. Neither of these is visible in the current skin. The design language should be derivable from these two sources and nothing else — no generic "premium dashboard" moves.

### B2. Palette — from olive-gold to ocean-and-sand

Current palette is near-black + dark olive + gold: the default "luxury dark" template. Replace with tokens drawn from the honu's world — deep water, moonlit surface, sand, shell:

| Token | Hex | Role |
|---|---|---|
| `--ink` | `#0B1B21` | Base background. Deep water at night, blue-black, not olive-black. |
| `--ink-raised` | `#122831` | Card surface. One step toward the surface. |
| `--foam` | `#E8EDE9` | Primary text. Warm off-white, moonlight on water. |
| `--sand` | `#C9B48A` | Secondary accent: labels, eyebrows, the Hebrew date. Replaces gold's job with a quieter, warmer material. |
| `--shell` | `#E0A458` | Primary accent. Used in exactly one place per screen (see B5). Amber shell-glow, not champagne gold. |
| `--reef` | `#3E7C6F` | Success / done states. Sea green, used sparingly. |

Rule: `--shell` appears once per view. If it's on the countdown number, it's nowhere else. Restraint is what makes it read as identity instead of theme.

### B3. Typography — the Hebrew face is a first-class decision

Current: generic display serif for everything Latin, Hebrew rendered as an afterthought in system fallback. Invert this:

- **Display (Latin):** a high-contrast serif retained for the hero only — but tightened: the greeting no longer gets display treatment (A1), so display type now marks *meaning* (the countdown, the simcha) rather than decoration.
- **Body/UI (Latin):** a clean humanist sans (e.g., Inter or equivalent already in stack) — tasks, labels, controls.
- **Hebrew:** a deliberate Hebrew typeface — **Frank Ruhl Libre** (serif, pairs naturally with a Latin display serif) for the Hebrew date and any liturgical/calendar text. Never system fallback. The Hebrew date is set at the same optical size as its Latin sibling, not smaller.

This is the cheapest high-signal change in the whole spec: one webfont, and the most distinctive text on the page stops looking like a footnote.

### B4. The Hebrew calendar is the spine, not a caption

The day header (A1's one-line greeting) treats the Hebrew date as structurally equal to the Gregorian one — same size, `--sand` color, Frank Ruhl Libre. Sensitivity rule carried from project principles: render real calendar data only; never generate or approximate Hebrew text. Date strings come from a proper Hebrew calendar library (e.g., @hebcal/core), not from formatting logic or AI output.

### B5. Signature element — the counting hero

The Bar Mitzvah countdown becomes the page's one memorable element:

- Full-width hero band on `--ink-raised`.
- The number (days to go) set large in display serif, `--shell` — the single accent use on the page.
- Beneath it, a thin progress arc or bar in `--sand` showing days elapsed since the countdown was created → the feeling is *counting toward* a simcha, not a deadline timer.
- Event name in display serif, date in both calendars.

Deliberately not styled as urgency (no red, no pulsing). It's anticipation, rendered calmly. This is also the demo moment for HQ Builder: Aaron's or YoniHQ's hero counts toward *their* milestone with *their* tenant accent.

### B6. Per-tenant tokens

All Part B tokens live as a named theme in tenant config (target: `Tenant.config.theme`), defaulting to Honu Dark. This makes the design language the concrete implementation of the "per-tenant AI personality layer" roadmap item — personality starts with palette, type, and greeting voice before it's ever an AI feature. No schema change required if `config` is already JSON; confirm during implementation, do not assume.

---

## Part C — Constraints and sequencing

1. **No code until after ZevHQ-0704.** This document is the design chip's contents. Pipeline order stands: Hermes packet → Step 0 findings → ADR → master audit → then this.
2. **No schema changes.** If implementation reveals `Tenant.config` can't hold theme tokens without migration, that surfaces as evidence for a future decision — it does not get patched inline.
3. **Guardrails untouched.** Nothing here touches tenant-scoped queries or `TENANT_MODELS`.
4. **Atomic implementation.** When Codex implements, hierarchy rules (Part A) and theme tokens (Part B) can ship as separate commits, but the removal of the old greeting block and stat tiles must be in the same commit as their replacements — no duplicate-content window.
5. **Verification standard.** Post-deploy: phone screenshot of zevhq tenant + aaron tenant confirming (a) hero renders per A1 priority, (b) $0 MRR tile absent, (c) Hebrew date renders in Frank Ruhl Libre at parity size, (d) zero bleed-through of Zev's countdown into aaron tenant.

---

## Acceptance test (one sentence)

Open the dashboard cold on your phone: within one second you should know **what you're counting toward** and **what to do next** — and it should look like it belongs to no one but you.

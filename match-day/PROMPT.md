# Match Day — build prompt

> A companion app that turns the end of screen time into the end of a soccer match.
> Paste this entire document into Claude (or your app builder of choice) as the build brief.

---

## The problem this app solves

My young son loves soccer and loves screens. What he cannot handle is the *end* of screen time. When a parent walks over and turns off the TV or takes the iPad, it feels sudden, arbitrary, and personal — and it regularly ends in a meltdown. Warnings from a parent ("five more minutes!") don't help, because the parent is still the one deciding, and the decision still feels negotiable.

Real soccer matches, though, he ends without any struggle. A match ends when the referee blows full time. Nobody argues with the whistle. The clock was visible the whole time, the warnings came in a familiar rhythm, and — critically — **there is always another match tomorrow**.

**Match Day borrows that exact ritual.** It reframes every screen-time session as a soccer match, run by a neutral referee that is not mom or dad. The whistle ends the match. The parents are just fellow spectators.

---

## The single most important design decision: it's a companion app

**Match Day runs on its own device — an iPhone or iPad propped up in the room, next to whatever he's watching or playing.** It is the referee at the side of the pitch.

- It never displays, hosts, or controls the content. The TV, the console, the FIFA session, the YouTube video — all untouched, on their own devices.
- Because it controls nothing, it works with **everything**: broadcast TV, FIFA on the PlayStation, YouTube on the iPad, anything. No Screen Time API, no parental-control integrations, no per-device setup, no pairing.
- Its entire job is to be **visible and audible in the room**: a big match clock and a referee's whistle.

Do not add any form of device control, content blocking, or screen mirroring. That is not a missing feature — its absence is the concept.

---

## The match (core session flow)

### 1. Setting up the match (parent)
- Parent picks the match length: presets (30, 45, 60, 90, 120 minutes) plus a custom option. Maximum 2 hours.
- Parent controls sit behind a simple guard (e.g., long-press to open) so the child can't change settings.
- **Once the match kicks off, the length cannot be extended — by anyone, ever.** No "add 5 minutes" button exists. A guarded pause exists only for genuine interruptions (bathroom, doorbell), and pausing visibly freezes the clock like an injury stoppage.

### 2. Kickoff
- Referee whistle, crowd roar, and a big "KICKOFF!" moment on screen.
- The match clock starts **counting up**, exactly like a real soccer broadcast (0:00 → 90:00), not counting down. A count-up clock is calm; a countdown is a threat. Optional quiet stadium ambience underneath.

### 3. The warning ladder (fixed, always the same)
Predictability is the therapy here. The same three signals, in the same order, every single match:

1. **10 minutes to full time** — a short referee whistle + the announcement, spoken and shown: "10 minutes to full time."
2. **5 minutes to full time** — a short referee whistle + "5 minutes to full time."
3. **The final minute — the stoppage-time board.** The fourth official's electronic board appears showing **+1**. This is the one and only countdown in the app, and it's the one he already knows from real soccer. Crowd noise rises steadily through the final minute.

### 4. Full time
- A long, unmistakable triple whistle. Crowd cheers.
- A big **FULL TIME** board fills the screen.
- **The point:** if he stops smoothly, the parent awards a point with **one single tap** — a star/trophy animation and a running tally of points across days. If the stop wasn't smooth, nothing happens: no comment from the app, no penalty, no lost points. The only mechanics are reward or silence. There are no punishment mechanics anywhere in this app.
- **Required closing line**, spoken and shown on every full-time screen, always the same words: **"See you at tomorrow's match."** This continuity signal — the screen goes off, but the match *comes back* — is probably the single most meltdown-relevant sentence in the whole app. It is not optional and must not be reworded per session.

---

## Technical requirements

- **Platform:** iOS/iPadOS, SwiftUI. One codebase, layouts tuned for both iPhone and iPad (the iPad propped in landscape is the primary "scoreboard" mode).
- **Screen stays awake:** set `UIApplication.shared.isIdleTimerDisabled = true` while a match is running (and restore it after). The scoreboard must never auto-lock mid-match.
- **Audio stays alive for a full 2-hour session:** configure `AVAudioSession` with the `.playback` category so whistles and announcements play even with the silent switch on, and keep the session active for the whole match. Whistles must be loud and clear from across the room.
- **Clock correctness:** store the kickoff timestamp and compute elapsed time from it — never accumulate timer ticks. If the app is accidentally backgrounded, locked, or relaunched mid-match, it resumes showing the correct match time and still fires any warnings that are due.
- **Fully offline:** all whistle samples, crowd ambience, rising-crowd loop, cheers, and announcer lines are bundled. No network, no accounts, no analytics, no ads, no in-app purchases. Points tally persists locally.
- **Readable from the couch:** the match clock is huge and high-contrast — legible from 4–5 meters away. Stadium-scoreboard aesthetic: dark background, bright digits, a strip of green pitch. Kid-friendly but not babyish.
- **Announcer voice:** warm, short sentences, identical wording every time. Provide both **English and Hebrew** as selectable languages; every spoken line has a matching on-screen text.

---

## What NOT to build

- No countdown clock during the match (count-up only; the stoppage-time board is the sole countdown).
- No device/content control of any kind.
- No penalties, red cards, or negative feedback for a rough stop.
- No way to extend a running match.
- No gamification beyond the single points tally (no streaks pressure, no levels, no notifications).

---

## A note to the humans (include this in the app's parent-setup screen)

The app sets up the ritual, but for the first two weeks the ritual only works if the humans follow the whistle too — no "five more minutes" exceptions, ever, in either direction. Consistency is what teaches a child that the whistle is real. The app just makes that consistency easier to deliver warmly.

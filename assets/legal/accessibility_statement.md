# Accessibility Statement

**Last Updated:** September 9, 2026

**CinReco** (operated by Ali Mobini, an independent developer based in the Netherlands) is committed to making our app usable by everyone, including people with disabilities. This statement describes where things currently stand, measured honestly rather than aspirationally.

---

## 1. Conformance Target

We target **WCAG 2.1 Level AA**, the standard referenced by the EU's harmonised accessibility standard (EN 301 549) and by the European Accessibility Act.

**Current status: partially conformant.** Partially conformant means some parts of the app meet the standard and some do not yet. We would rather say that plainly than claim full compliance we can't back up.

---

## 2. What We've Verified

* **Screen reader labels:** Interactive controls — buttons, navigation items, and the swipe screen's Like/Dislike/Super Like actions — carry semantic labels for VoiceOver (iOS), TalkBack (Android), and desktop screen readers on the web.
* **Keyboard navigation:** The global search overlay supports full keyboard control (Up/Down/Enter/Esc). CinReco is built with Flutter, which provides platform-native accessibility support (dynamic text sizing, focus navigation) by default for standard UI components; this statement covers the custom controls layered on top of that foundation, not Flutter's baseline behaviour.

## 3. Known Gaps

* **Swipe-card interaction** is primarily gesture- and mouse-driven. A keyboard- or screen-reader-only path for swiping is not yet fully equivalent to the pointer experience.
* **Icon-only controls on secondary screens** (group sessions, watchlist, movie details) have not yet had the same labelling pass as the primary flows above.
* **Reduced motion:** the app does not yet honour the OS-level "reduce motion" accessibility setting; card and page transitions always animate.
* **Video content:** once in-app trailer playback ships, it will need captions before it can be considered accessible — this is tracked, not yet built.

We're working through these; this statement will be updated as they close, not just on a fixed schedule.

---

## 4. Feedback

If you encounter an accessibility barrier using CinReco, please tell us — specifics (what screen, what assistive technology, what happened) help us fix it faster:

* **Email:** `info@mail.mobini.nl`

We aim to acknowledge accessibility reports within 5 business days.

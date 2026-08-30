# Accessibility Statement (Demo Project)

**Last updated:** 2026-08-18

Cinreco Web is a personal portfolio project. It's built with Flutter,
which provides platform-native accessibility support (screen reader
labels, dynamic text sizing, keyboard/focus navigation) by default for
standard UI components. This statement covers the custom controls
layered on top of that foundation — swipe cards, the bottom navigation
bar, and similar bespoke widgets — measured honestly rather than
aspiratively.

## Current state

- Interactive controls (buttons, nav items, swipe actions) carry
  semantic labels for screen readers.
- Keyboard navigation is supported for the global search overlay
  (Up/Down/Enter/Esc).
- The swipe-card interaction is primarily gesture/mouse-driven; a
  keyboard- or screen-reader-only path for swiping is not yet fully
  equivalent to the pointer experience.

## Feedback

If you hit an accessibility barrier while trying this demo, please
open an issue on the GitHub repository with what screen, what
assistive technology, and what happened — that's the fastest way to
get it looked at.

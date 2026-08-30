# Privacy Notice (Demo Project)

**Last updated:** 2026-08-18

Cinreco Web is a personal portfolio project demonstrating a Flutter Web
client against a live backend API. It is not a commercial product, and
this notice is intentionally short rather than a formal GDPR/CCPA
privacy policy.

## What happens if you register or log in

- Creating an account here creates a real row in the developer's
  personal database — the same database used to demo the underlying
  API. There is no separate "sandbox" environment.
- Please **do not use a real password you use elsewhere**, and avoid
  submitting anything you consider sensitive (the swipe/watchlist/group
  session data model is real, but nothing here is treated as
  production user data).
- Demo data (accounts, swipes, watchlists, group sessions) may be
  reset or deleted at any time without notice, since this is a
  portfolio demonstration, not a maintained service.
- A shared **demo account** is offered on the login screen specifically
  so you don't need to register at all to try the app.

## What's collected

- Standard web server logs (IP address, request path, timestamp) as a
  side effect of any HTTP request, for basic operational visibility.
- If analytics are enabled for this deployment, anonymous/pseudonymous
  usage events (e.g. screen views, button clicks) may be recorded via
  PostHog — never your password, and never movie preference text.
- Movie metadata is fetched from the backend API, which in turn sources
  it from TMDb. No personal data is sent to TMDb.

## Questions

This is a portfolio project — for questions, please open an issue on
the GitHub repository rather than emailing a formal privacy contact.

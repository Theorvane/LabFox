# Privacy Policy

**LabFox** is developed by **sloki9637** (https://www.sloki9637.com).
This policy explains what the app processes and what leaves your device.

_Last updated: 2026-10-20_

## What LabFox processes

- **Your GitLab content** — projects, issues, merge requests, pipelines, and
  files are fetched **directly from the GitLab instance you sign in to** and
  are shown on your device. This traffic goes to your instance only; it is
  never routed through, stored on, or readable by sloki9637's servers.
- **Credentials** — your Personal Access Token or OAuth tokens are stored only
  in your device's secure storage (Keychain / Keystore). They are sent only to
  the GitLab instance you configured, never to sloki9637, and they never
  appear in logs or error reports.
- **Local preferences** — settings such as your theme choice and your recent
  and favorite projects are stored only on your device.

## Analytics

To understand which features matter, LabFox sends a small set of anonymous
usage events to an analytics service operated by sloki9637 (self-hosted
OpenPanel):

- **What you did, not what it was about**: app opened, screen viewed, signed
  in, signed out, account switched, search run (which scope, never the term),
  project favorited or unfavorited, issue created, merge request created,
  approved, unapproved, merged, closed, reopened, rebased, draft changed,
  comment posted (on an issue or a merge request, never its text), pipeline
  retried or cancelled, job retried, cancelled, or run manually, to-do
  cleared, and background checks turned on or off.
- Screen-view events carry only a **sanitized route** — numeric identifiers
  are removed (`/projects/:id`), so no project, issue, or account can be
  identified.
- Events contain **no personal data**: no usernames, names, email addresses,
  tokens, titles, content, or full URLs.
- Analytics are never sold, shared with third parties, or used for
  advertising.

## Advertising and purchases

LabFox does not show ads, access the advertising identifier, or offer in-app
purchases. Every LabFox feature is available without a subscription.

## Background checks

If you turn on background to-do checks (off by default), LabFox asks **your own
GitLab instance** for your pending to-do list
on a schedule the operating system controls, and shows a local notification for
anything new.

- The request goes to your instance with your token, exactly like the same
  screen in the app. Nothing is sent to sloki9637.
- Notification text is built on your device and stays there.
- LabFox stores only the ids of the to-dos it has already announced, so it does
  not announce them twice. Turning the setting off stops the checks.

## Data retention and deletion

- Signing an account out removes that account's data from your device: its
  token, its stored account details, and its recent and favorite projects.
- App-wide preferences that belong to the device rather than to an account —
  your theme choice, for example — are kept, so removing one account does not
  reset the app for the others. Uninstalling removes everything.
- Anonymous analytics events cannot be linked back to you and are retained
  only in aggregate form for product decisions.

## Your GitLab instance

LabFox is a client. What your GitLab instance logs or retains about your
activity is governed by that instance's own policies, not by this one.

## Changes

Material changes to this policy are published with the app and in this
repository. Continued use after a change means the updated policy applies.

## Contact

- **sloki9637** — https://www.sloki9637.com
- Published policy: https://www.sloki9637.com/privacy
- Terms of service: https://www.sloki9637.com/terms
- Inquiries: **inquiry@sloki9637.com**

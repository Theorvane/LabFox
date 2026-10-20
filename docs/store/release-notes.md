# Release notes

The "What's New" text for each store, newest first. Written here rather than
typed into a console field, so it is reviewed and kept.

**Play caps release notes at 500 characters per language.** The App Store allows
4000, but a listing that says the same thing in both places is easier to keep
honest, so the short version is the one that matters — write it first and let
the App Store text be the same or a little longer.

Rules, the same two the listing keeps:

- Say what changed for the **user**, not what changed in the repository. Nobody
  reading a store update cares which provider was refactored.
- Do not name what is not shipped. Roadmap features do not appear here.

Translations live beside this file as `release-notes.<locale>.md`. English is
the source: change this first, then carry it across.

---

## 0.1.10

**Play** (500 characters max):

```
• Every LabFox feature is now free, including approve and merge, job actions,
  multiple accounts, background to-do checks, and unlimited favorites.
• Ads and in-app purchases have been removed.
```

**App Store**:

```
• Every LabFox feature is now free on iPhone and iPad, including approve and
  merge, job actions, multiple accounts, background to-do checks, and unlimited
  favorites.
• Ads and in-app purchases have been removed.
```

---

## 0.1.9

**Play** (500 characters max):

```
• Maintenance release. There are no user-facing changes on Android.
```

**App Store**:

```
• The App Store page now presents the subscription duration, renewal terms,
  Terms of Use, and Privacy Policy together. There are no in-app changes.
```

---

## 0.1.8

**Play** (500 characters max):

```
• Nothing changes on Android. Sign in with a personal access token, or open
  your instance in the browser, exactly as before.
```

**App Store**:

```
• On iPhone and iPad, connect with a personal access token from your own
  GitLab account settings. The token is held in the device keychain and is
  sent only to the instance you name.
```

---

## 0.1.7

**Play** (500 characters max):

```
Clearer sign-in:

• The screen now says what it is asking for. LabFox has no account of its own
  — you connect the GitLab you already use, whether that is gitlab.com or a
  server you host yourself.
```

**App Store**:

```
Clearer sign-in:

• The screen now says what it is asking for. LabFox has no account of its own
  — you connect the GitLab you already use, whether that is gitlab.com or a
  server you host yourself. The button that opens your instance in a browser
  now says so, instead of implying it signs you in to GitLab.com.
```

---

## 0.1.6

**Play** (500 characters max):

```
Fixes:

• Ads now ask before using anything about your device to personalise
  themselves. Say no and they keep showing, just less targeted. Subscribers
  see no ads and are never asked.
```

**App Store**:

```
Fixes:

• Ads now ask before using anything about your device to personalise
  themselves, through the system tracking prompt. Say no and ads keep showing,
  just less targeted. Subscribers see no ads at all and are never asked.
```

---

## 0.1.5

**Play** (500 characters max):

```
Fixes:

• The strip at the bottom of the screen no longer sits there empty. It takes
  no room at all until there is something to put in it.
```

**App Store**:

```
Fixes:

• The strip at the bottom of the screen no longer sits there empty. It takes
  no room at all until there is something to put in it, and once something is
  there it stays put instead of shifting the page under you.
```

---

## 0.1.4

The 0.1.3 submission was rejected for metadata rather than for anything in the
build, so this release carries the same features and adds what was missing.

**Play** (500 characters max):

```
The subscription screen now shows what you are agreeing to: how often it
renews, how to cancel, and links to the Terms of Use and the Privacy Policy.

Everything from 0.1.3 is here too — background to-do checks, and a
subscription you can actually find.
```

**App Store**:

```
The subscription screen now shows what you are agreeing to before you buy: how
often it renews, how to cancel it, and links to the Terms of Use and the
Privacy Policy.

Everything from 0.1.3 is here too:

• Background to-do checks. LabFox looks at your to-do list while it is closed
  and tells you when something new needs you — a review requested, a pipeline
  that failed, an issue assigned to you. Part of the subscription, and off
  until you turn it on in Settings.
• The subscription is easier to find, and your profile shows whether it is
  active.
```

---

## 0.1.3

**Play** (500 characters max):

```
What's new:

• Background to-do checks. LabFox looks at your to-do list while it is closed
  and tells you when something new needs you — a review, a failed pipeline, an
  assignment. Part of the subscription; turn it on in Settings.
• The subscription is easier to find, and shows its state on your profile.

Android checks about every fifteen minutes; iOS decides when, so this is a
background check rather than an instant push.
```

**App Store**:

```
What's new:

• Background to-do checks. LabFox looks at your to-do list while it is closed
  and tells you when something new needs you — a review requested, a pipeline
  that failed, an issue assigned to you. Part of the subscription, and off
  until you turn it on in Settings.
• The subscription is easier to find, and your profile shows whether it is
  active.

This is a background check, not a push. There is no LabFox server that could
send you one: your device asks your own GitLab on a schedule the operating
system decides. Android checks about every fifteen minutes; iOS picks its own
moments.
```

---

## 1.0.0 — first release

**Play** (500 characters max):

```
LabFox brings GitLab to your phone.

• Read merge requests in full, with approvals and discussion
• Go through the diff file by file, with real line numbers
• Approve, merge, or comment
• Watch pipelines, open job logs with colour intact, retry or cancel
• Issues, to-do inbox, search, and repository browsing

Works with gitlab.com or your own self-hosted instance. Tokens stay in the
device keychain — no LabFox account, no LabFox server.

Open source, Apache-2.0.
```

**App Store**:

```
The first release of LabFox.

Review a merge request on the train. Check why the pipeline went red before you
get to your desk.

• Merge requests in full — description, labels, approvals, discussion
• Diffs file by file, with real line numbers and changed lines highlighted
• Approve, merge, or leave a comment
• Pipelines at a glance, and job logs with the runner's colour output intact
• Retry a failed job, cancel one, or start a manual job
• Issues, to-do inbox, search, repository, branches, commits

The layout follows the screen, not the device: a focused single pane on a
phone, a navigation rail and room for twenty merge requests on a tablet.

gitlab.com and self-hosted instances work the same way. Tokens are held in the
device keychain — there is no LabFox account and no LabFox server between you
and your GitLab.

Open source under Apache-2.0: github.com/theorvane/labfox
```

---

## Template for later releases

Keep the shape. Lead with the thing most people will notice, and skip anything
they would not.

```
What's new:

• <the change someone would notice, in their words>
• <the next one>

Fixes:

• <what was broken, described by the symptom rather than the cause>
```

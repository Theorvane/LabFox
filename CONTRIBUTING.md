# Contributing to LabFox

Thanks for your interest in contributing. LabFox supports four platforms from **a single Flutter codebase**.
A bug you fix on desktop is fixed on mobile too — every contribution reaches every platform.

---

## Project model

```
Source code            Apache-2.0 open source — anyone may use, modify, redistribute
Desktop (Win/macOS)    Free
Mobile (Android/iOS)   Sold on the App Store / Play Store
```

Code you contribute is published under Apache-2.0 and ships in the free mobile and desktop apps.
Make sure you understand and accept that before contributing. If you don't, please don't contribute.

The "LabFox" name and logo are trademarks and are not covered by the Apache-2.0 license.
Fork freely, but use a different name and icon. ([TRADEMARK.md](TRADEMARK.md))

---

## Before you start

1. **Read [AGENTS.md](AGENTS.md) first.** It covers the architecture, conventions, and what's off-limits.
   The same rules apply to humans and coding agents alike.
2. Check that what you plan to work on falls inside the **1.0 scope** (AGENTS.md §9).
3. For any large change, discuss it in an issue before writing code.

---

## Development setup

```bash
flutter --version          # 3.38.9, stable channel
flutter pub get            # resolves the whole pub workspace at once
```

The repository is a native pub workspace (Dart 3.6+), not a melos monorepo, so
there is no extra tool to install: one `flutter pub get` at the root resolves
`apps/labfox` and every package against a single lockfile.

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Workflow

```
Issue → Branch → Commit → Pull Request
```

> LabFox is a GitLab client, but **development happens on GitHub.**
> The domain term inside the app is still Merge Request; only the contribution process uses Pull Request.

Branch from `dev` and target your pull request at `dev`. Nothing is committed directly to `dev` or `main` — `main` holds releases only.

```bash
git switch -c feat/12-mr-diff-viewer dev
```

- Branches: `<type>/<issue-number>-<slug>` — type is one of `feat` `fix` `docs` `refactor` `test` `chore`
- Commits: [Conventional Commits](https://www.conventionalcommits.org/)
  e.g. `fix(gitlab_api): handle keyset pagination in project list`
- Link the issue from the PR description with `Closes #12`
- Details: [`.agents/docs/workflow.md`](.agents/docs/workflow.md)

### Before you open a PR

```bash
dart format .
flutter analyze
flutter test
```

Don't open a PR while `analyze` warnings remain.

---

## Ground rules

### License

- **Never pull in GPL, LGPL, or AGPL code.** Once copyleft spreads, the entire project becomes GPL,
  which voids Apache-2.0 and blocks App Store distribution.
- New dependencies are limited to **MIT, BSD, Apache-2.0, ISC, and Zlib**.
  If you add one, update [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
- Don't copy code from other projects. Read them for reference all you like, but write the implementation yourself.
- Check fonts, icons, and images for commercial-use rights as well.

### Platform

- **Don't build a separate UI per platform.** Branch on screen width instead:
  use `LayoutBuilder` plus breakpoints, not `Platform.isAndroid`.
  This is exactly why a desktop contribution carries over to mobile.
- Even for a desktop-only fix, verify that nothing breaks at mobile width (<600).

### Security

- Never leave tokens (PAT / OAuth) in logs, code, screenshots, or commits.
- When attaching logs to an issue or PR, scrub `Authorization` headers and any `glpat-` strings.

---

## Developer Certificate of Origin (DCO)

Include a `Signed-off-by` line in every commit.

```bash
git commit -s -m "fix(gitlab_api): handle keyset pagination"
```

This signals your agreement to the [Developer Certificate of Origin](https://developercertificate.org/)
and confirms that **you have the right to contribute the code.**
There is no separate CLA to sign.

---

## Review

- Keep PRs small enough to review. Anything over 1,000 lines gets a look at whether it can be split.
- Attach screenshots for UI changes — **both mobile and desktop**, both light and dark.
- CI must pass before anything is merged.
- Reviews may take a while; thanks for your patience.

---

## Good places to start

| | |
|---|---|
| **Bug reports** | Most useful when the reproduction steps are clear |
| **Self-hosted issues** | Problems on different GitLab versions and configurations are hard for us to reproduce |
| **Desktop UX** | Windows/macOS feel, keyboard shortcuts, multi-pane layouts |
| **Accessibility** | Screen readers, contrast, touch targets |
| **Translation** | Multi-language support |

## What we won't accept

- Features outside the 1.0 scope (Wiki, Packages, Registry, Analytics, Admin, and so on)
- UI built with GitHub brand assets
- Changes that bypass the architecture (calling `GitLabClient` directly from a widget, for example)

---

## Questions

Open a [GitHub issue](https://github.com/theorvane/labfox/issues) with the `question` label, or
comment on the issue or pull request you are working on — see [SUPPORT.md](SUPPORT.md).

For anything that must stay private, email **inquiry@sloki9637.com**. Suspected vulnerabilities go
through [SECURITY.md](SECURITY.md) instead.

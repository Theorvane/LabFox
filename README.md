<p align="center">
  <img src="brand/generated/icon-128.png" width="96" height="96" alt="LabFox">
</p>

# LabFox

**A Flutter-based cross-platform GitLab workflow client that pairs GitHub Mobile-grade UX
with GitLab's Merge Requests, CI/CD, and self-hosted support.**

<p>
  <a href="LICENSE"><img alt="License" src="https://img.shields.io/badge/license-Apache--2.0-blue.svg"></a>
  <img alt="Platforms" src="https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20Windows%20%7C%20macOS-lightgrey.svg">
</p>

> **Pre-release.** Sign-in, projects, issues, merge requests, diffs, pipelines,
> job logs, the to-do inbox and search are built and tested. Not yet published to
> any store — see [RELEASING.md](RELEASING.md).

---

## What it looks like

<p align="center">
  <img src="docs/images/home.png" width="24%" alt="Home: issues, merge requests, pipelines and favourites">
  <img src="docs/images/review.png" width="24%" alt="Merge request with approvals and the merge button">
  <img src="docs/images/diff.png" width="24%" alt="Diff viewer with line numbers and changed lines">
  <img src="docs/images/job-log.png" width="24%" alt="CI job log with colour output">
</p>

The same code branches on width rather than platform, so a tablet gets a
navigation rail and the room to show twenty merge requests at once:

<p align="center">
  <img src="docs/images/tablet.png" width="80%" alt="Merge request list on a tablet, with a navigation rail">
</p>

<sub>Screenshots show <a href="https://gitlab.com/gitlab-org/gitlab">gitlab-org/gitlab</a>, a public project.</sub>

---

## What we're building

LabFox began as a focused workflow client: **make the work developers do every
day fast.** A maintainer-approved expansion now tracks broader GitLab
mobile-web coverage in the [parity inventory](docs/mobile-web-parity.md).

```
Check notifications
   ↓
Open the Issue / Merge Request
   ↓
Read the diff and review
   ↓
Check pipeline status
   ↓
Check job logs
   ↓
Approve / Merge / Retry
```

Where the GitLab web UI splits its menus by feature, LabFox reorganizes them **around the task at hand.**

```
Home
├── My Issues
├── Merge Requests
├── Review Requests
├── Pipelines
├── Projects
└── To-do
```

## What sets it apart

| | |
|---|---|
| **GitHub Mobile-grade UX** | Information density and flow designed for development work on the go |
| **GitLab CI/CD** | Pipelines, job logs, retries, and manual jobs — all from your phone |
| **Self-hosted / Multi Account** | GitLab.com and your company's instance are equal citizens |
| **Four platforms** | Android · iOS · Windows · macOS |

## Tech stack

Flutter · Dart · Riverpod · Dio · go_router · flutter_secure_storage · intl

A local cache (Drift/SQLite) is planned for after 1.0; today the repositories are network-only.

```
UI → Controller (Riverpod) → Repository → GitLab API Client → GitLab
```

Monorepo layout:

```
labfox/
├── apps/labfox/          Flutter application
└── packages/
    ├── gitlab_api/       GitLab REST / GraphQL client (pure Dart)
    ├── gitlab_models/    DTO / Entity
    ├── design_system/    LabFox Design System
    └── secure_storage/   Platform secure storage wrapper
```

## Roadmap

| | | |
|---|---|---|
| **M0** Foundation | Scaffolding, routing, theming, responsive layout, API client skeleton | ✅ |
| **M1** Repository | PAT login, Projects, Repository Browser, File Viewer | ✅ |
| **M2** Collaboration | Issues, Merge Requests, Diff, Discussion, Approve, Merge | ✅ |
| **M3** CI/CD | Pipeline, Jobs, Job Log, Retry, Cancel, Manual Job | ✅ |
| **M4** Product | OAuth, Self-hosted, Multi Account, Inbox, Search, Deep Links | ✅ |
| **1.0** Release | Store listings, background notifications, offline cache | in progress |

Details: [`.agents/docs/roadmap.md`](.agents/docs/roadmap.md)

The maintainer-approved GitLab mobile-web expansion is tracked in
[the parity inventory](docs/mobile-web-parity.md). It distinguishes shipped
slices from known gaps; it is not a claim of complete web parity.

## Contributing

**Contributions are welcome.** Read [CONTRIBUTING.md](CONTRIBUTING.md) before you start.

One Flutter codebase powers all four platforms, so
**a bug you fix on desktop is fixed on mobile too.**

```
Desktop contribution → shared codebase → every platform improves
```

This repository is developed together with coding agents.
The working rules live in [`AGENTS.md`](AGENTS.md), and they apply to human contributors just the same.

Work flows **Issue → Branch → Pull Request**. Nothing is committed directly to `main`.

```
gh issue create --title "..."
git switch -c feat/12-mr-diff-viewer dev
git commit -s -m "feat(scope): ..."
gh pr create --fill --base dev
```

- Branches: `<type>/<issue-number>-<slug>` (`feat` `fix` `docs` `refactor` `test` `chore`)
- Commits: [Conventional Commits](https://www.conventionalcommits.org/) with a DCO sign-off (`git commit -s`)
- Link the issue from the PR description with `Closes #N`
- Details: [`.agents/docs/workflow.md`](.agents/docs/workflow.md)

### Docs

- [CONTRIBUTING.md](CONTRIBUTING.md) — contribution process, DCO, license rules
- [`AGENTS.md`](AGENTS.md) — architecture, conventions, what's off-limits, 1.0 scope
- [`.agents/docs/`](.agents/docs/) — detailed docs (architecture · conventions · api-reference · references · roadmap)
- [`.agents/docs/workflow.md`](.agents/docs/workflow.md) — the Issue → Branch → PR process
- [`docs/mobile-web-parity.md`](docs/mobile-web-parity.md) — shipped slices and remaining mobile-web work
- [`.agents/skills/`](.agents/skills/) — playbooks for each type of task

## License

The source code is released under the **Apache License 2.0**. → [LICENSE](LICENSE)

```
Source code            Apache-2.0 open source — anyone may use, modify, redistribute
Windows                Direct download, free, full features
macOS                  Mac App Store, free, full features
Android / iOS          Free download, full features
```

Every LabFox feature is free on desktop and mobile, with no ads or in-app
purchases. There is no LabFox account or server. GitLab's own permissions and
server-tier requirements still govern what each instance allows. The shared
Flutter codebase lets a fix contributed on desktop improve mobile too.

Distribution policy: [`.agents/docs/monetization.md`](.agents/docs/monetization.md)

Third-party dependency licenses: [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)

## Trademark

**The "LabFox" name and logo are not covered by the Apache-2.0 license.**
Section 6 of the Apache License 2.0 explicitly withholds trademark rights.

You are free to use, modify, and redistribute the code. However, **shipping a modified version
under the "LabFox" name or logo requires prior permission.** Forks must use a different name and icon.

Full details: [TRADEMARK.md](TRADEMARK.md)

## Notice

LabFox is an **unofficial third-party client** and is not affiliated with, endorsed by,
or certified by GitLab Inc. or GitHub, Inc.
"GitLab" is a trademark of GitLab Inc.; "GitHub" is a trademark of GitHub, Inc.

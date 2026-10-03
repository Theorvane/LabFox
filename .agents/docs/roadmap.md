# Roadmap

## First Vertical Slice

Don't implement the entire API up front. Finish this one thread first.

```
PAT Login → Home → Projects → Project → Merge Requests → MR Detail → Diff
```

Once that works, the API architecture, authentication, routing, state management, UI, Markdown, diff, and
responsive layout are effectively all validated. Everything after that is applying the same skeleton repeatedly.

## Phases

### M0 — Foundation
Flutter project and monorepo scaffolding, Riverpod / Dio / go_router,
freezed + json_serializable, Secure Storage, Theme, responsive layout,
`gitlab_api` client skeleton.

### M1 — Repository
PAT Login, Projects, Project Overview, Repository Browser, File Viewer,
README rendering, Branches, Commits.

### M2 — Collaboration
Issues, Issue Detail, Comments, Merge Requests, MR Detail, Diff, Discussion,
Approve, Merge.

### M3 — CI/CD
Pipeline, Pipeline Detail, Stages, Jobs, Job Log, Retry, Cancel, Manual Job.

### M4 — Product
OAuth, Self-hosted, Multi Account, Inbox (To-do), Search, Local Cache, Offline, Deep Links.

## 1.0 Scope

**Included**

- Account — GitLab.com, Self-hosted, PAT, OAuth, Multi Account
- Project — Projects, Favorites, Repository, Files, Branches, Commits
- Collaboration — Issues, Comments, Merge Requests, Discussions, Diff, Approval, Merge
- CI/CD — Pipelines, Jobs, Job Logs, Retry, Cancel, Manual Job
- Productivity — To-do Inbox, Search, Recent, Favorites
- Platform — Android, iOS, Windows, macOS

**Excluded (not implemented in 1.0)**

Wiki · Packages · Container Registry · Infrastructure · Kubernetes ·
Security Dashboard · GitLab Analytics · Admin Area · Runner Administration

The later maintainer-approved mobile-web parity expansion includes these areas.
Track its shipped slices and remaining work in
[`docs/mobile-web-parity.md`](../../docs/mobile-web-parity.md); the list above
remains the original 1.0 boundary, not a prohibition on approved parity issues.

These are GitLab feature areas, not a rule about LabFox's own instrumentation —
anonymous product telemetry is in scope for 1.0. See `AGENTS.md` §9.

## Later Expansion

- Desktop Integration — open in VS Code / Cursor / Android Studio / IntelliJ / Terminal / Explorer / Finder
- AI — analyze Job Log failure causes, summarize MR changes
  → **Start only after the 1.0 core features are complete.**

## Information Architecture

Don't port web GitLab's feature-centric menus verbatim; restructure them around user tasks.

```
Home
├── My Issues
├── Merge Requests
├── Review Requests
├── Pipelines
├── Projects
└── To-do
```

Mobile navigation: Bottom Navigation — `Home · Settings · Search · Me`
Desktop: Navigation Rail + Multi-pane + Command Palette (⌘K / Ctrl+K)

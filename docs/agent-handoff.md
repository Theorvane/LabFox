# Agent handoff: protection-rule parity work

Snapshot: 2026-10-18. This document records the source chat's state; GitHub and
the working tree must be checked again when resuming. Repository content is
English; the maintainer communicates in Korean.

## Current state

| Item | Snapshot |
| --- | --- |
| Repository | `Theorvane/LabFox`, local workspace `/home/ubuntu/labfox` |
| Integration/release branches | Contributor PRs target `dev`; `main` is release-only |
| Verified `origin/dev` baseline | `e329aab9af8a224c2ca2887e565ae3a8d5f040c8` |
| Last merged feature | [PR #661](https://github.com/Theorvane/LabFox/pull/661), deploy-group addition, squash merged on 2026-10-18 |
| Pending feature | [Issue #662](https://github.com/Theorvane/LabFox/issues/662), [PR #663](https://github.com/Theorvane/LabFox/pull/663), deploy-group removal |
| Feature branch | `feat/662-remove-deploy-groups` |
| Exact feature head | `1cda0281083440170321867d95fe7e8ced285e26` |
| PR #663 review/merge state | `OPEN`, `APPROVED`, `CLEAN` at handoff inspection |
| PR #663 CI | Flutter quality gate, iOS SDK validation, language policy, project detection and PR triage succeeded; issue-only triage was skipped |
| Uncommitted feature work | None; the feature was committed and pushed |
| Handoff branch | `docs/664-agent-handoff`, created separately from `origin/dev` for [issue #664](https://github.com/Theorvane/LabFox/issues/664) |

The handoff branch intentionally starts before PR #663 is merged. Its checkout
does not contain that PR's removal implementation. Use the feature branch/PR to
inspect the pending implementation; fetch `dev` after merge before starting the
next feature. Do not stack new feature work on either branch above.

## First actions when resuming

1. Read [AGENTS.md](../AGENTS.md), the applicable repository skills and the
   [parity tracker](mobile-web-parity.md). Preserve any new user changes.
2. Re-check PR #663's state, latest head, review decision, mergeability and every
   CI result. The snapshot above is not a live merge decision. If already merged,
   skip the merge and inspect the resulting `dev` commit.
3. The source chat contains explicit maintainer authorization to merge approved
   work and continue. Follow the receiving session's current user instructions
   and permissions. Where that authorization applies, merge only approved,
   clean work with passing CI, matching the verified head. This repository uses
   squash merges; merge commits were rejected. Do not bypass gates or resolve
   the reviewer's threads as the author.
4. Fetch `origin/dev` after the merge and create the next issue/branch from it.
   Mark the removal slice shipped in the tracker only after verifying the merge.
5. Choose one bounded next slice, verify the current official GitLab API, write
   and run a failing behavior test, then implement it. Continue through checks,
   signed commits, push and a PR targeting `dev`.

Useful read-only checks:

```sh
git status --short
gh pr view 663 --json state,headRefOid,baseRefName,reviewDecision,mergeStateStatus,statusCheckRollup
gh pr checks 663 --required
```

Inspect all checks in `statusCheckRollup`, not just the subset marked required.
When merging under the applicable user authorization, use `gh pr merge` with
`--squash --match-head-commit` and the freshly verified approved head.

## What PR #663 implements

One existing project protected-environment deploy group can be removed by stable
grant ID. Selection requires positive grant/group IDs, no user selector and an
explicit direct/inherited membership value. Reported role metadata is allowed
on group grants. Unknown membership, role/user-only grants and group-level rules
remain read-only in this slice.

The responsive dialog shows current deploy/approval access and selected grant
identity/membership. Saving requires the exact environment name and acknowledgement;
selection/name edits reset consent. Warnings cover access loss, remaining grants
and the impact of removing the last deploy grant.

The controller scans every inventory page and strictly reads the full rule on
inspection and before dispatch. It sends one PUT containing only
`deploy_access_levels: [{id, _destroy: true}]`. The response and fresh read-back
must equal the frozen snapshot with exactly that grant removed. The environment
stays protected, including when deploy access becomes empty; all other deploy
grants and approval rules/counts are preserved.

Writes disable redirects and automatic OAuth refresh/replay. Status mapping
precedes strict parsing. Pending input, dismissal and duplicate writes are
blocked. Failed/uncertain writes require read-only reinspection and fresh consent;
an already-removed grant cannot be retried. Account changes prevent dispatch or
suppress late old-session success/refresh effects.

Key files in the feature branch or merged `dev`:

- `packages/gitlab_api/lib/src/environments/protected_environments_api.dart`:
  `removeDeployGroup`, existing strict `getForDeployGroupEdit` reader.
- `apps/labfox/lib/features/protected_environments/data/protected_environments_repository.dart`:
  repository forwarding and complete inventory checks.
- `apps/labfox/lib/features/protected_environments/presentation/controllers/protected_environment_remove_deploy_group_controller.dart`:
  session-bound preflight, preservation and read-back checks.
- `apps/labfox/lib/features/protected_environments/presentation/widgets/protected_environment_remove_deploy_group_dialog.dart`:
  selection, confirmation, reload and pending controls.
- `apps/labfox/lib/features/protected_environments/presentation/protected_environment_detail_screen.dart`:
  project-only action and current-session success message.
- Source/translated ARBs and generated delegates under `apps/labfox/lib/l10n/`.
- New API/controller/screen tests named `protected_environment_remove_deploy_group_*_test.dart`.
- Feature evidence: [implementation notes](https://github.com/Theorvane/LabFox/blob/feat/662-remove-deploy-groups/docs/protected-environment-deploy-group-removal.md),
  with four fixture-only screenshots under `docs/images/protected-environment-deploy-group-removal/`.

## Validation already completed

API, controller and widget tests were run red before implementation, then green.
Related controller/widget regressions passed **234 tests**; the new API suite
passed **25 tests**. Five locales (`en`, `ko`, `ja`, `hi`, `zh`) were tested at
320/800/1200 widths in light and dark themes. Mobile/desktop screenshot captures
were visually inspected in both themes.

Full local suites at the feature head passed **8,653 tests**:

| Suite | Passed |
| --- | ---: |
| App | 4,922 |
| GitLab API | 3,387 |
| Design system | 135 |
| GitLab models | 204 |
| Secure storage | 5 |

Root static analysis reported no issues. Root formatting changed no files, and
the CI English-language policy and whitespace checks passed. Models and
dependencies did not change; no `build_runner` or license-notice update was needed.

Local logs use `/tmp/labfox-remove-deploy-group-*.log`; they are temporary aids,
not durable evidence. The PR, committed tests, implementation notes and GitHub CI
are the durable record. Temporary screenshot test files were removed.

No live GitLab role/tier/self-hosted version matrix was validated. The server
requires the applicable tier, enabled CI/CD and management permission. The endpoint
has no atomic compare-and-set: preflight/read-back cannot eliminate concurrent
server changes. Preservation covers modelled fields; strict editing reads fail
closed on incomplete protection metadata.

## Toolchain and workflow

Use Flutter **3.38.9** and its bundled Dart SDK in this workspace:

```sh
LABFOX_FLUTTER=/home/ubuntu/fvm/versions/3.38.9/bin/flutter
LABFOX_DART=/home/ubuntu/fvm/versions/3.38.9/bin/dart

# From the repository root:
"$LABFOX_DART" format --output=none --set-exit-if-changed .
"$LABFOX_FLUTTER" analyze

# App tests:
(cd apps/labfox && "$LABFOX_FLUTTER" test --no-pub --reporter expanded)

# API tests:
(cd packages/gitlab_api && "$LABFOX_DART" test --reporter expanded)

# Other package tests:
for labfox_package in design_system gitlab_models secure_storage; do
  (cd "packages/$labfox_package" && "$LABFOX_FLUTTER" test --no-pub --reporter expanded)
done
```

The workspace uses native pub workspaces, not melos; the root has no test suite.
Run `flutter gen-l10n` from `apps/labfox` after ARB changes. Never hand-edit
generated delegates/models. Use the repository's feature/API skills, match
existing patterns, keep strings localized and write behavior tests first.

Follow one issue/branch/PR per slice, branch from `origin/dev`, use Conventional
Commits with `git commit -s`, and never force push or push directly to `dev/main`.
Attach every created PR to the Codex task with `attach_artifact` when available.
Do not send messages to other chats/people without user authorization.

The origin URL uses the older `labfox` casing and GitHub redirects it to `LabFox`;
pushes worked. Shell execution in the source session required the tool's normal
escalated approval flow because its default sandbox could not launch the shell.
Follow the actual execution/approval errors in the receiving session.

## Candidate continuation

MW-02 remains in progress; these slices do not establish complete GitLab parity.
Recent related work includes deploy-group addition (#660/#661), deploy-group
membership editing (#658/#659), approval-group replacement (#656/#657) and the
current removal slice (#662/#663).

A plausible next bounded slice is replacing an existing deployment group by exact
group ID while preserving the grant ID, membership, reported role metadata,
other deploy grants and every approval rule/count. No issue or implementation
for that candidate has been started in this chat. Check for concurrent work and
verify the current official API before selecting it. The maintainer has not
specified that this candidate must be next; use the tracker and current user
direction to choose the next slice.

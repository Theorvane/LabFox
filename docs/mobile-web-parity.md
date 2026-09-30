# GitLab mobile-web parity tracker

This is the working inventory for the maintainer-approved expansion beyond the
original 1.0 scope. It is **not** a claim that LabFox matches every GitLab web
screen. GitLab behavior varies by version, tier, role, project settings, and
feature flags. A route or API method proves only the named slice, not a whole
feature area.

Baseline: `dev` at `32fe6e1` (2026-09-27). The [roadmap](../.agents/docs/roadmap.md)
records the original scope; `AGENTS.md` §9 records the expansion. Use GitLab's
[project feature catalog](https://docs.gitlab.com/user/project/organize_work_with_projects/),
[project settings](https://docs.gitlab.com/user/project/settings/), and
[permissions](https://docs.gitlab.com/user/permissions/) to discover and verify
work, not as a fixed denominator.

## Progress accounting

- **Shipped baseline** below means the named app slice is on `dev`. It does not
  mean the entire GitLab feature area is complete.
- **Known work packages** are broader than PRs. Split each package into
  issue-sized slices before coding; add more packages as gaps are discovered.
- Status moves `Queued → In progress → In review → Shipped`. `Shipped` requires
  tests, review approval, passing CI, and merge into `dev`. Use `Blocked` with
  a reason when tier, permission, API, or design constraints prevent progress.
- Update the snapshot, evidence, and issue/PR links in the same PR that changes
  a row. Do not calculate a GitLab parity percentage from this incomplete list.

Snapshot (2026-09-30): **19 known work packages**, **1 shipped**, **5 in
progress**, **13 queued**. This is a lower bound on remaining work,
**not 18 PRs** or an ETA. The shipped baseline is excluded from that count.

## Shipped baseline by workflow

| Area | Confirmed slice on `dev` | Evidence | Boundary |
| --- | --- | --- | --- |
| Accounts | PAT/OAuth sign-in, self-hosted instance, account switching | [auth](../apps/labfox/lib/features/auth/presentation/) | More version/role validation. |
| Productivity | Home, to-do inbox/completion, issue notification subscriptions, project/issue/MR search | [home](../apps/labfox/lib/features/home/presentation/), [inbox](../apps/labfox/lib/features/inbox/presentation/), [issues](../apps/labfox/lib/features/issues/presentation/), [search](../apps/labfox/lib/features/search/presentation/) | Search scopes and broader notification settings. |
| Groups and projects | Group/subgroup/project browsing, project overview and activity | [groups](../apps/labfox/lib/features/groups/presentation/), [projects](../apps/labfox/lib/features/project_overview/presentation/) | Settings and management. |
| Repository | Tree/files, branches, tags, commits; branch/tag creation | [repository](../apps/labfox/lib/features/repository/presentation/), [branches](../apps/labfox/lib/features/branches/presentation/), [tags](../apps/labfox/lib/features/tags/presentation/) | Advanced repository operations. |
| Protection | Project protected branch, tag, and environment rule browsing; group protected environment browsing | [branches](../apps/labfox/lib/features/protected_branches/presentation/), [tags](../apps/labfox/lib/features/protected_tags/presentation/), [project/group environments](../apps/labfox/lib/features/protected_environments/presentation/) | Rule writes. |
| Collaboration | Issues, linked issues, issue title/description, due-date, label, assignee, milestone, confidentiality, and discussion-lock editing; MRs, comments, diff, approval/merge/rebase actions | [issues](../apps/labfox/lib/features/issues/presentation/), [MRs](../apps/labfox/lib/features/merge_requests/presentation/), [diff](../apps/labfox/lib/features/diff/presentation/) | Remaining metadata editing, boards, advanced review. |
| CI/CD execution | Pipelines/jobs/logs/actions; schedules/run; environments/deployments | [pipelines](../apps/labfox/lib/features/pipelines/presentation/), [jobs](../apps/labfox/lib/features/jobs/presentation/), [schedules](../apps/labfox/lib/features/pipeline_schedules/presentation/) | Configuration, variables, runners, schedule edits. |
| Planning metadata | Project/group milestones and labels; project/group member browsing | [milestones](../apps/labfox/lib/features/milestones/presentation/), [labels](../apps/labfox/lib/features/project_labels/presentation/), [members](../apps/labfox/lib/features/members/presentation/) | Editing and administration. |
| Content and distribution | Releases/assets, snippet reading, single-file project snippet creation and deletion, title and description editing, wiki page reading, Markdown creation and editing, packages/files, container repositories/tags | [releases](../apps/labfox/lib/features/releases/presentation/), [snippets](../apps/labfox/lib/features/snippets/presentation/), [wiki](../apps/labfox/lib/features/wiki/presentation/), [packages](../apps/labfox/lib/features/package_registry/presentation/), [registry](../apps/labfox/lib/features/container_registry/presentation/) | Snippet file and visibility management; wiki deletion, history, and other management. |

## Known work packages

`P0` preserves the developer workflow; `P1` completes adjacent mobile-web
tasks; `P2` covers broad administrative surfaces. A package can need several
issues and PRs. Keep it open until its full acceptance boundary is verified.

| ID | Priority | Work package and acceptance boundary | Status | Tracking |
| --- | --- | --- | --- | --- |
| MW-01 | P1 | Group protected environments: list/detail, deploy/approval rules, role/tier errors, narrow/wide tests. | Shipped | [#326](https://github.com/Theorvane/labfox/issues/326), [PR #328](https://github.com/Theorvane/labfox/pull/328) |
| MW-02 | P1 | Project protection-rule creation, update, and removal with permission checks. | In progress | Protected tag removal [#511](https://github.com/Theorvane/labfox/issues/511), [PR #512](https://github.com/Theorvane/labfox/pull/512); protected tag creation [#513](https://github.com/Theorvane/labfox/issues/513), [PR #514](https://github.com/Theorvane/labfox/pull/514); protected branch creation [#515](https://github.com/Theorvane/labfox/issues/515), [PR #516](https://github.com/Theorvane/labfox/pull/516); protected branch removal [#517](https://github.com/Theorvane/labfox/issues/517), [PR #518](https://github.com/Theorvane/labfox/pull/518). Rule updates and remaining environments need separate slices. |
| MW-03 | P1 | Project/group settings inventory and authorized general/repository/CI changes. | Queued | Issue needed |
| MW-04 | P1 | Member invitations, role/expiry changes, and removal for groups/projects. | Queued | Issue needed |
| MW-05 | P0 | Issue/work-item editing, metadata, types, and validated state transitions. | In progress | [#329](https://github.com/Theorvane/labfox/issues/329), [PR #330](https://github.com/Theorvane/labfox/pull/330) shipped title and description editing; [#339](https://github.com/Theorvane/labfox/issues/339), [PR #340](https://github.com/Theorvane/labfox/pull/340) shipped due-date editing; [#341](https://github.com/Theorvane/labfox/issues/341), [PR #342](https://github.com/Theorvane/labfox/pull/342) shipped issue-label editing; [#343](https://github.com/Theorvane/labfox/issues/343), [PR #344](https://github.com/Theorvane/labfox/pull/344) shipped assignee editing; [#345](https://github.com/Theorvane/labfox/issues/345), [PR #346](https://github.com/Theorvane/labfox/pull/346) shipped milestone editing; [#347](https://github.com/Theorvane/labfox/issues/347), [PR #348](https://github.com/Theorvane/labfox/pull/348) shipped confidentiality; [#349](https://github.com/Theorvane/labfox/issues/349), [PR #350](https://github.com/Theorvane/labfox/pull/350) shipped discussion locking. Type-conversion compatibility and remaining work-item actions need separate issues. |
| MW-06 | P1 | Boards and iterations: discover mobile-web behavior, then list/detail/mutations. | Queued | Issue needed |
| MW-07 | P0 | Advanced MR review: audit inline discussions/suggestions and finish missing review/approval flows. | Queued | Issue needed |
| MW-08 | P1 | CI/CD configuration: pipeline editor, variables, triggers, and schedule editing. | Queued | Issue needed |
| MW-09 | P1 | Wiki creation/editing/deletion and history with conflict handling. | In progress | [#351](https://github.com/Theorvane/labfox/issues/351), [PR #352](https://github.com/Theorvane/labfox/pull/352) shipped Markdown page creation; [#353](https://github.com/Theorvane/labfox/issues/353), [PR #354](https://github.com/Theorvane/labfox/pull/354) shipped editing with best-effort stale-draft detection; [#373](https://github.com/Theorvane/labfox/issues/373), [PR #374](https://github.com/Theorvane/labfox/pull/374) shipped deletion with confirmation and best-effort stale-page detection; [#375](https://github.com/Theorvane/labfox/issues/375), [PR #376](https://github.com/Theorvane/labfox/pull/376) shipped Markdown template selection. [#377](https://github.com/Theorvane/labfox/issues/377), [PR #378](https://github.com/Theorvane/labfox/pull/378) cover template listing and creation in review. Page history and atomic conflict protection remain. The documented wiki REST API can retrieve a page by version SHA but does not list page history. |
| MW-10 | P1 | Snippet creation/editing/deletion, files, and visibility. | In progress | [#355](https://github.com/Theorvane/labfox/issues/355), [PR #356](https://github.com/Theorvane/labfox/pull/356) shipped single-file project snippet creation; [#357](https://github.com/Theorvane/labfox/issues/357), [PR #358](https://github.com/Theorvane/labfox/pull/358) shipped deletion with confirmation; [#359](https://github.com/Theorvane/labfox/issues/359), [PR #360](https://github.com/Theorvane/labfox/pull/360) shipped title and description editing; [#361](https://github.com/Theorvane/labfox/issues/361), [PR #362](https://github.com/Theorvane/labfox/pull/362) shipped single-file content editing; [#363](https://github.com/Theorvane/labfox/issues/363), [PR #364](https://github.com/Theorvane/labfox/pull/364) shipped private/public visibility editing; [#365](https://github.com/Theorvane/labfox/issues/365), [PR #366](https://github.com/Theorvane/labfox/pull/366) shipped multi-file content editing; [#367](https://github.com/Theorvane/labfox/issues/367), [PR #368](https://github.com/Theorvane/labfox/pull/368) shipped adding a file; [#369](https://github.com/Theorvane/labfox/issues/369), [PR #370](https://github.com/Theorvane/labfox/pull/370) shipped deleting a file; [#371](https://github.com/Theorvane/labfox/issues/371), [PR #372](https://github.com/Theorvane/labfox/pull/372) shipped moving and renaming a file. Broader visibility management remains. |
| MW-11 | P1 | Release and milestone creation/editing/closure/deletion. | In progress | [#379](https://github.com/Theorvane/labfox/issues/379), [PR #380](https://github.com/Theorvane/labfox/pull/380) shipped project milestone creation with optional dates; [#381](https://github.com/Theorvane/labfox/issues/381), [PR #382](https://github.com/Theorvane/labfox/pull/382) shipped project milestone editing; [#383](https://github.com/Theorvane/labfox/issues/383), [PR #384](https://github.com/Theorvane/labfox/pull/384) shipped close/reactivate actions; [#385](https://github.com/Theorvane/labfox/issues/385), [PR #386](https://github.com/Theorvane/labfox/pull/386) shipped project milestone deletion; [#387](https://github.com/Theorvane/labfox/issues/387), [PR #388](https://github.com/Theorvane/labfox/pull/388) shipped group creation; [#389](https://github.com/Theorvane/labfox/issues/389), [PR #390](https://github.com/Theorvane/labfox/pull/390) shipped group editing; [#391](https://github.com/Theorvane/labfox/issues/391), [PR #392](https://github.com/Theorvane/labfox/pull/392) shipped group close/reactivate; [#393](https://github.com/Theorvane/labfox/issues/393), [PR #394](https://github.com/Theorvane/labfox/pull/394) shipped group deletion; [#395](https://github.com/Theorvane/labfox/issues/395), [PR #396](https://github.com/Theorvane/labfox/pull/396) shipped basic release creation. [#397](https://github.com/Theorvane/labfox/issues/397), [PR #398](https://github.com/Theorvane/labfox/pull/398) shipped release name and description editing. [#399](https://github.com/Theorvane/labfox/issues/399), [PR #400](https://github.com/Theorvane/labfox/pull/400) shipped release deletion. [#401](https://github.com/Theorvane/labfox/issues/401), [PR #402](https://github.com/Theorvane/labfox/pull/402) shipped asset link creation; [#403](https://github.com/Theorvane/labfox/issues/403), [PR #404](https://github.com/Theorvane/labfox/pull/404) shipped asset link deletion; [#405](https://github.com/Theorvane/labfox/issues/405), [PR #406](https://github.com/Theorvane/labfox/pull/406) shipped asset link name and URL editing. [#407](https://github.com/Theorvane/labfox/issues/407), [PR #408](https://github.com/Theorvane/labfox/pull/408) cover asset link type editing in review. [#409](https://github.com/Theorvane/labfox/issues/409), [PR #410](https://github.com/Theorvane/labfox/pull/410) cover direct download path replacement in review. Path removal, milestone links, and scheduling remain. |
| MW-12 | P1 | Package/container management, cleanup, and protection by tier. | Queued | Issue needed |
| MW-13 | P2 | Security: inventory and implement vulnerability, policy, and scan views by role. | Queued | Issue needed |
| MW-14 | P2 | Analytics: inventory project/group reports and implement mobile layouts. | Queued | Issue needed |
| MW-15 | P2 | Infrastructure/Kubernetes: inventory current pages and API capabilities first. | Queued | Issue needed |
| MW-16 | P2 | Instance/group administration and runner inventory/actions, role-gated. | Queued | Issue needed |
| MW-17 | P1 | Broader search scopes, filters, and deep-link coverage. | Queued | Issue needed |
| MW-18 | P0 | Cross-cutting comparison by role, tier, self-hosted version, and viewport; record every missing action. | Queued | Issue needed |
| MW-19 | P0 | Issue/MR notification subscriptions and to-do shortcuts, including idempotent actions and error states. | In progress | [#331](https://github.com/Theorvane/labfox/issues/331), [PR #332](https://github.com/Theorvane/labfox/pull/332) shipped issue subscriptions; [#333](https://github.com/Theorvane/labfox/issues/333), [PR #334](https://github.com/Theorvane/labfox/pull/334) shipped issue to-do creation; [#335](https://github.com/Theorvane/labfox/issues/335), [PR #336](https://github.com/Theorvane/labfox/pull/336) cover MR subscriptions; [#337](https://github.com/Theorvane/labfox/issues/337), [PR #338](https://github.com/Theorvane/labfox/pull/338) shipped MR to-do creation. |

## Procedure for the next slice

1. Verify current GitLab documentation and mobile-web behavior. Record tier,
   role, API, and feature-flag requirements in an issue and refine its row here.
2. Use one issue, one branch from `dev`, and one PR into `dev`. Write a failing
   behavior test before implementation. Keep one responsive UI across platforms.
3. Test parsing, pagination, domain errors, empty states, deep links, and narrow
   and wide widths as applicable. Run formatting, analysis, and package/app tests.
4. Link the PR and move the row to `In review`. Move it to `Shipped` only after
   approval, passing CI, and merge. Add discovered gaps as new rows rather than
   silently expanding the definition of done.

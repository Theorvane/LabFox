# Private pending MR review pagination

Issue [#602](https://github.com/Theorvane/labfox/issues/602) adds the read-only
controller prerequisite for pending review in MW-07. It builds on the
[private draft API/repository](mr-draft-notes.md). It exposes no screen, composer,
mutation, publication, approval, disk cache or analytics event.

## Resource and session identity

`MrPendingReviewQuery` contains a project/IID route, the authoritative positive
global MR identity from the current detail, and page size (1–100). These fields
all participate in provider equality. The global identity is checked against
returned drafts; it never replaces the route IID. Future presentation must
obtain that identity from the current authenticated MR detail, not infer it from
an IID or a saved private page.

The auto-disposed `MrPendingReviewController` watches the account and captured
repository session. Disposal or replacement before repository resolution
prevents the old read from dispatching. Session generation, current account and
repository identity are checked before pagination dispatch and after each
response. Obsolete initial and continuation success/errors cannot update current
rows. Already dispatched reads may finish on their original client.

Presentation must watch `mrPendingReviewProvider(query)`. It removes Riverpod's
retained previous data during loading/errors and additionally checks the current
account and repository against the loaded rows. Private rows disappear immediately
on account, instance or client replacement and sign-out, including before the
scheduled rebuild pump. The raw controller provider/future is for orchestration
and commands, not for displaying retained values.

## Explicit paging and recovery

The controller reads page one once and follows only explicit `loadMore()` calls.
A nonempty next-page header is followed even on an empty page. It makes no eager
continuation and does not use optional totals to guess a last page.

`MrPendingReviewDrafts` holds immutable rows in server order, optional totals,
the next cursor and `isLoadingMore`. Duplicate continuation calls are rejected
while a read is pending. Current rows remain visible during an ordinary
continuation within the same session. Every page must retain the expected global
MR and captured/account author identity. Duplicate draft IDs within or across
pages and non-forward cursors reject the entire loaded result with a static
sanitized error; a mixed page is never merged partially or silently deduplicated.

An initial or continuation failure exposes its domain error and hides all prior
private rows. It does not automatically retry. `refresh()` is the explicit
read-only retry, returning to page one and immediately clearing presentation.
It supersedes any pending continuation; an obsolete completion cannot release
or overwrite a new session's state. A failed refresh never restores previous
private rows. Consumers keep a subscription while awaiting auto-disposed futures.

`isComplete` means the last observed page had no continuation. Offset pagination
is not an atomic server snapshot: drafts may change between page reads without
a duplicate appearing. A complete cursor traversal is not proof of an unchanged
review and must not authorize publication or automatic retry of an uncertain
save. A future composer/publication flow still needs fresh authoritative
inspection, current view/session checks and shared write reservations.

Draft Markdown and nullable original position/reply/resolution metadata are
preserved by the existing generated models. This controller does not infer
unsupported anchor eligibility or transform server metadata into a new request.
The existing [creation prerequisite](mr-draft-note-creation.md) remains separate.

## Verification

Test-first coverage checks route/global identity, immutable order and exact
bodies, optional totals, explicit cursors through empty pages, duplicate-load
blocking, mismatched identities, duplicate drafts, backward cursors, typed
failures, refresh/retry and invalid pre-dispatch queries. Session coverage checks
immediate removal on account/instance/client/sign-out, cancellation before
repository resolution, late initial and continuation outcomes, resource/container
disposal and superseded refreshes. Initial-response tests wait for an actual old request to dispatch before
replacing its repository, distinguishing cancellation before dispatch from
isolation of already dispatched reads. Current errors remain typed; Riverpod
discards superseded initial build errors and the continuation guard suppresses
obsolete pagination errors.

Workspace format, analysis and all five package test suites are required before
push; exact-head review and CI precede merge. No endpoint, generated model,
dependency, localization or visible layout changes are made. No live GitLab,
device, theme or store validation is claimed. The pending-review list UI, composer,
uncertain-write recovery, editing/deletion and publication remain follow-up work.

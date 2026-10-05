# Guarded regular private review saves

Issue [#606](https://github.com/Theorvane/labfox/issues/606) adds regular private
note save orchestration to `MrDiscussionsController`. It builds on the
[creation API](mr-draft-note-creation.md) and [private readers](mr-draft-notes.md).
The [pending review panel](mr-pending-review-panel.md) remains read-only: no
composer, positioned-save orchestration, editing/deletion or publication UI is
introduced by this controller prerequisite.

## Save and identity

`savePendingNote` preserves the exact nonblank Markdown, including whitespace.
It reserves the existing discussion controller before asynchronous work, waits
for the account-bound client and repositories, and reloads authoritative MR
detail. The positive global MR ID comes from that detail, separately from the
project/IID route. Wrong detail, wrong author, missing authentication and failed
preflight prevent a create request. A new detail provider is initialized once;
an existing one is explicitly refreshed.

The reservation covers the controller's comments, replies, positioned creation,
resolution, single/batch suggestions, inspection and pagination. Private saves
also wait for any active discussion pagination. Approval/merge actions use their
existing separate controller; this is not a transaction across all MR commands.

Account, client, draft/detail/comments repository futures and MR detail are
observed while the command waits. Replacement or controller disposal cancels
obsolete waits without dispatching or moving the old body to a new session.
Caller-provided view checks run before dispatch and at each completion boundary.
Already dispatched HTTP writes cannot be cancelled or undone; late outcomes are
suppressed. Callers must still check their current view before displaying a
result or clearing a composer.

One create is dispatched, with no public-comment fallback, replay or analytics.
Current-session success requires a positive saved identity, captured author,
exact global MR ID and exact body confirmation. Only then does a route-scoped
revision refresh all private page/aggregation query variants for this MR,
including custom page sizes, without refreshing other MRs or public discussions.
The existing API's strict response and single-attempt write behavior is unchanged.

## Uncertain writes and explicit inspection

The controller records an inspection requirement before dispatch. Every failed
or unconfirmed dispatched save keeps that requirement. It also remains when a
write completes after its view/controller was replaced. Further private saves
return no success without sending another request. Public comment behavior is
unchanged; there is no automatic conversion from a failed private save.

Ordinary controller refreshes and same-account repository/client replacement
cannot clear this requirement. An actual account/instance change or sign-out
separates the old private scope. The state is in memory only and is not durable
across a process/container restart; future UI must discard session-bound input
and must not promise durable uncertain-write recovery.

`inspectPendingNotes` is explicit read-only recovery. If a dispatched write is
still unsettled, it waits for that actual request to finish before reading. This
prevents an early empty inspection from authorizing a duplicate while the first
write can still finish. The same reservation remains held during this wait and
all subsequent reads.

Inspection reloads fresh MR detail and stages every private page in server order,
following header cursors even through empty pages. It validates positive draft
IDs, captured ownership/global MR identity, uniqueness across all pages and
strictly advancing cursors. Failed, malformed or obsolete inspection returns no
partial private list and keeps the same-account requirement. No next-page read
can dispatch after session/view replacement.

Only a complete successful traversal returns an immutable snapshot and permits
a subsequent explicit save; inspection itself never retries a create. A future
composer must display this snapshot before offering retry. An identical saved
body does not establish whether it is the uncertain attempt. Offset pagination
and a settled client request do not establish an atomic server snapshot; a server
may continue processing after a client timeout. User inspection cannot promise
exactly-once creation. Publication and automatic deduplication remain separate.

## Verification

The tests were written before these methods and first failed because orchestration
was missing. A further failing regression showed that same-account client
replacement could incorrectly clear the uncertainty requirement before its fix.
There are 65 controller regressions covering exact bodies/global identity, fresh
and invalid detail, duplicate reservations, valid public reply/resolution/
suggestion targets, pagination overlap, typed preflight/write failures,
complete/empty/invalid/duplicate private pages, explicit retry, cancelled writes,
settlement barriers, account/instance/client/repository/view replacement,
obsolete inspection data/errors and route-scoped reader refreshes.

No new endpoint, model, dependency, localization, visible layout, remote asset,
telemetry or disk cache is added. Tests use synthetic users and dummy credentials;
no live GitLab, physical-device or store validation is claimed. Existing widget
and review-controller suites remain part of regression verification. MW-07 stays
in progress until the remaining review flows are completed and validated.

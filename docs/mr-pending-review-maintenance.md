# Editing and deleting private review notes

Issue [#612](https://github.com/Theorvane/LabFox/issues/612) connects the
[pending review panel](mr-pending-review-panel.md) to the
[update/delete foundations](mr-draft-note-maintenance.md). The regular composer
shares its private input, preparation, session and recovery guards with the new
maintenance dialog. Publication and positioned/reply/commit creation remain
separate; MW-07 is still in progress.

## Selection and execution

Owned saved notes offer deletion. Editing is offered for regular notes and
complete original text anchors, including supported multiline ranges. Image,
file, incomplete and opaque line-code-only anchors have no edit action. The
repository uses the API's existing pure text-position validator, exported for
this classification, so presentation does not recreate its range rules.

Editing starts with exact saved Markdown and displays the original note and
known location metadata. Blank and unchanged input cannot be submitted.
Deletion shows the selected note and requires an explicit checkbox before the
Delete note button is enabled. Both dialogs are scrollable and use the same
width-responsive feature code on every platform. All new messages have English
source and translations for Korean, Japanese, Hindi and Chinese.

`updatePendingNote` and `deletePendingNote` reserve the existing discussion
controller before asynchronous work. This shares the create/reply/resolution/
suggestion and discussion-pagination reservation; approval/merge commands still
have their separate controller. Fresh account-bound MR detail supplies the
positive global MR ID separately from project/IID. Ownership, selected draft ID
and global identity are checked before reading private state.

The controller traverses every private page, including empty intermediate pages,
and validates positive IDs, captured author/global identity, uniqueness and
advancing cursors. A missing draft or any change to its captured body, original
position or modeled metadata stops the command before dispatch. A later page
failure cannot authorize a write from an earlier partial result. It never
silently adopts a concurrently changed target or treats its disappearance as a
successful deletion.

A current exact match permits one repository update or delete. Updates retain
original anchors and exact edited Markdown; deletion addresses the captured
identity without reconstructing its position. The existing strict API responses,
status-first errors and disabled redirects/authentication replay remain intact.
Only a confirmed current-view outcome refreshes every private reader query for
this MR and shows localized success. No replacement create, public fallback,
publication, automatic retry, analytics or disk persistence is introduced.

## Uncertain results and current views

The shared in-memory inspection requirement is set before dispatch and remains
on failure, malformed acknowledgement or an obsolete completion. It blocks
subsequent private creation, update and deletion. Ordinary controller refresh or
same-account repository/client replacement cannot clear it. Complete explicit
inspection waits for the actual dispatched request to settle before reading.

A failed maintenance dialog retains edited input, displays a generic localized
error, and requires read-only inspection before another attempt. The complete
validated list is displayed together with the latest selected note and metadata.
A separate acknowledgement is required before applying the user's current
change to that freshly inspected target. Editing the input clears that
acknowledgement. Another execution still performs a fresh preflight, so a later
concurrent change is refused again. Missing targets cannot be retried; an
unsupported newly observed anchor cannot be edited. Inspection itself never
writes and never exposes a partial list after a later page fails.

The panel owns the originating view lifetime outside rows that its own detail
refresh replaces. Account/instance, draft/detail/comments repository or route
replacement permanently discards local private input, target and inspection
state. Late data/errors cannot toast, clear another view's input or send a write
through the replacement session. Existing regular-composer behavior shares these
guards and remains covered by its regression tests.

Already dispatched writes cannot be undone. Offset pages and a settled client
request are not an atomic server snapshot; a server may finish processing after
a timeout. Fresh comparison is not a conditional server update and cannot
eliminate a race after the last read. No durable recovery or exactly-once claim
is made. There is no live GitLab, physical-device or store validation.

## Verification and synthetic captures

Tests were written before the new methods and controls and initially failed for
missing implementation. Two later failing regressions reproduced an account
change queued after fresh-target comparison; yielding to queued session
cancellation and checking the current session immediately before dispatch
prevents either write at this boundary. Controller and widget regressions cover exact bodies,
original metadata, stale/missing targets, all-page preflight, typed failures,
shared reservations, uncertain-write settlement, cross-command gating,
account/repository/view replacement, explicit inspection/acknowledgement,
unsupported edit anchors, deletion confirmation and route-scoped refreshes.
Five locales are exercised with large text and keyboard in narrow/wide dialogs.
The existing reader, repository, save, panel and composer suites remain required.

The captures use synthetic notes and dummy credentials; embedded Markdown image
URLs remain selectable text, without image fetching or rendering. All captures
are generated by an optional test harness at 390, 800 and 1200 logical pixels.

| State | Narrow | Tablet | Wide |
|---|---|---|---|
| Edit, light | [390](images/mr-pending-maintenance/edit-390-light.png) | [800](images/mr-pending-maintenance/edit-800-light.png) | [1200](images/mr-pending-maintenance/edit-1200-light.png) |
| Edit, dark | [390](images/mr-pending-maintenance/edit-390-dark.png) | [800](images/mr-pending-maintenance/edit-800-dark.png) | [1200](images/mr-pending-maintenance/edit-1200-dark.png) |
| Delete inspection, light | [390](images/mr-pending-maintenance/delete-inspection-390-light.png) | [800](images/mr-pending-maintenance/delete-inspection-800-light.png) | [1200](images/mr-pending-maintenance/delete-inspection-1200-light.png) |
| Delete inspection, dark | [390](images/mr-pending-maintenance/delete-inspection-390-dark.png) | [800](images/mr-pending-maintenance/delete-inspection-800-dark.png) | [1200](images/mr-pending-maintenance/delete-inspection-1200-dark.png) |

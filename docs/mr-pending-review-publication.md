# Publishing an entire pending MR review

The pending review panel offers **Publish pending review**. The confirmation
reads every saved private-note page, including empty intermediate cursor pages,
and shows the complete list before explicit consent. Publication makes the
current account's pending notes public; it does not approve or merge the MR.

## API and scope

The [official Draft Notes API](https://docs.gitlab.com/api/draft_notes/) defines
`POST /projects/:id/merge_requests/:merge_request_iid/draft_notes/bulk_publish`.
The client sends one request without a body or query, disables redirects and
OAuth replay, and requires HTTP 204 before acknowledging publication. Other
statuses and transport failures remain typed and sanitized; private response
bodies are never parsed or displayed. The repository uses its captured client
and requires a positive global MR identity separately from the route IID.

This slice adds no summary note, reviewer-state update, formal approval, merge,
single-note publication, dependency, telemetry or disk cache. Existing saved
positioned notes can be included, without editing or reconstructing their anchors.

## Confirmation and session isolation

A confirmation snapshot is immutable and bound to the account, client, draft,
detail and comments repositories, route and authoritative global MR ID. The
controller reserves the discussion command slot during preparation, final
comparison and publication. It rereads current MR detail and every private page
before dispatch. Added or removed notes and changes to modeled fields stop publication; reordered
unchanged notes are accepted. Invalid ownership/identity, duplicate IDs and
nonadvancing pagination reject the entire staged list. Queued cancellation is
allowed to settle after comparison before the sole request is sent.

This is an offset-paginated preflight, not an atomic or conditional server write.
GitLab does not accept a selected-ID list for bulk publication. A note created
or edited by another client after the comparison may be included. The dialog
explains this limitation and asks permission to publish the entire pending
review. The originating view stays mounted across the command's detail refresh;
account, repository, client, route or origin changes discard confirmation data
and suppress old-view success. Already dispatched requests cannot be cancelled
at the server.

## Uncertain outcomes and manual recovery

Before dispatch, publication sets a session-scoped inspection gate. A failed,
unconfirmed or obsolete completion leaves the gate in place. Same-account
controller/client/repository refresh cannot prove the request failed and does
not clear it. The gate blocks publication and private create/edit/delete; a
private-only inspection cannot clear publication uncertainty. Private compose/edit/delete
dialogs direct the user to whole-review publication recovery while this gate is set.

**Check notes and discussions** waits for the dispatched request to actually
settle, then stages every private page and every public discussion page. It
checks advancing cursors, unique discussion/note IDs and positive note IDs.
Failure on any later page leaves the gate and loaded discussion state unchanged.
Only a complete current-session inspection clears the gate and displays both
lists. Identical text or missing private notes cannot identify which prior
attempt succeeded. New publication requires new consent and another final full
comparison; recovery never retries automatically. Empty private results cannot
be published. Account replacement discards that account's in-memory gate; no
crash-safe or exactly-once recovery is claimed.

Confirmed current-view success refreshes saved notes, MR detail and public
discussions. Private input and captured snapshots are cleared when the dialog
becomes obsolete. Markdown in private notes and public recovery text does not
fetch remote images.

## Validation

API tests pin exact encoding, self-hosted paths, request count, strict 204,
status-first errors, sanitization, disabled redirects and disabled OAuth replay.
Repository and controller tests cover global identity, all-page comparison,
immutability, ownership, shared reservations, stale-session cancellation,
settlement waits and staged two-sided recovery. Widget tests exercise consent,
changed snapshots, failure/reopen, initial discussion-read recovery, privacy,
in-flight controls, five locales and widths 390/800/1200 in both themes with
large text and keyboard insets. Synthetic screenshots use dummy data and SDK
fonts; no live GitLab credentials or private projects are used.

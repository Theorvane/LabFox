# Publishing one saved private MR review note

Each saved note in the pending review panel offers **Publish this note**. The
separate confirmation shows that note's exact Markdown and saved metadata and
requires explicit consent. The other saved notes stay private. Publication does
not approve or merge the MR or update its reviewer state.

## API contract

The [official Draft Notes API](https://docs.gitlab.com/api/draft_notes/#publish-a-draft-note)
defines `PUT /projects/:id/merge_requests/:merge_request_iid/draft_notes/:draft_note_id/publish`.
The [current primary API contract](https://gitlab.com/gitlab-org/gitlab/-/raw/master/lib/api/draft_notes.rb)
requires HTTP 204 with no response body on success. The client sends one PUT with
no body or query, disables redirects and OAuth replay, and acknowledges only
204. Other statuses and transport failures remain typed and sanitized, including
malformed response bodies. No bulk fallback or automatic retry is used.

The repository requires the captured author, positive draft identity and
matching authoritative global MR ID. The route uses the project and MR IID;
publication uses the saved draft ID. Saved text, image, file, opaque, reply and
commit metadata is not reconstructed or edited for this identity-only request.

## Confirmation and isolation

The shared discussion controller reserves its existing command slot during
fresh MR detail reads, preparation, final comparison and publication. Every
private page is staged, including empty intermediate pages, with advancing
cursors, unique positive draft IDs and matching author/global MR identity. The
selected note must match the immutable captured DTO exactly. Missing notes or
changes to body, position, reply, resolution, commit or line-code metadata refuse
dispatch. Valid changes to unrelated saved notes do not invalidate this selected
confirmation. A selected confirmation cannot authorize the bulk route, and a
whole-review confirmation cannot authorize a single-note write.

Account, client, repository, controller, route and originating-view changes
cancel obsolete commands and suppress old success. The panel's origin remains
mounted during the command's own MR detail refresh. Cancellation queued during
target comparison is checked before dispatch; a request already sent cannot be
undone at the server. Confirmed current-view success refreshes private notes,
MR detail and public discussions.

The exact comparison is a paginated preflight, not an atomic conditional write.
Another client may edit the same draft ID after the check and before GitLab
publishes it. The confirmation explains this race. It does not claim that the
preview is an atomic snapshot of the eventual public note.

## Uncertainty and recovery

Before dispatch the controller sets the existing publication inspection gate.
Failure or obsolete completion preserves it across same-account refresh and
reopen. All private mutations and both publication routes are blocked until
complete explicit recovery; private-only inspection cannot clear it.

**Check notes and discussions** waits for the actual dispatched write to settle
and stages all private and public pages. Failed or invalid later pages leave the
gate and current discussions unchanged. Successful inspection shows current
saved notes and public discussion text without retrying. It adopts only the
original selected draft ID, if still present. Changed metadata is shown again,
and another manual publication requires new consent and a fresh comparison. If
the selected ID is missing, the dialog explains this and cannot publish another
note. Body equality or absence alone cannot identify which uncertain attempt
succeeded. Recovery remains in memory without crash-safe or exactly-once claims.

## Validation

Test-first API, repository, controller and widget cases reproduce missing
publication behavior before implementation. Regression coverage includes strict
204, no auth replay/redirect/fallback, ownership, all-page target comparison,
metadata changes, immutable scope, shared reservations, stale sessions,
settlement waits, recovery, renewed consent and a missing selected target.
Five locales, 390/800/1200 widths, both themes, 1.8 text scale and a 320-pixel
keyboard inset are covered. [Twelve synthetic captures](images/mr-pending-single-publication/README.md)
use dummy notes and SDK fonts; no live-instance or device validation is claimed.

No model, dependency, telemetry or disk persistence is added. Summary and
reviewer-state controls, and image/file/commit/reply draft creation remain
separate slices. MW-07 remains in progress.

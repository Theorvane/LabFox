# Submitting a pending MR review

Issue [#620](https://github.com/Theorvane/LabFox/issues/620) extends whole-review
publication with an optional **public review summary** and explicit reviewer
outcomes: keep the current state, reviewed, or request changes. The same MR
screen and dialog serve mobile, tablet and desktop. Summary Markdown and
whitespace are preserved exactly. Editing either option resets consent. A
summary or outcome can be submitted even when no private draft notes remain.
Selected-note publication retains its identity-only command and consent.

## API and review semantics

The documented [bulk Draft Notes endpoint](https://docs.gitlab.com/api/draft_notes/#publish-all-pending-draft-notes)
accepts `note` and `reviewer_state` (`reviewed`, `requested_changes`). One POST
publishes the authenticated author's entire pending set. A supplied summary
uses explicit `internal: false`; no internal-summary control is offered here.
Plain publication keeps its bodyless request. The response must be HTTP 204;
redirects, authentication replay, fallback writes and automatic retries remain
disabled.

[MR reviewers](https://docs.gitlab.com/api/merge_requests/#retrieve-merge-request-reviewers)
are read through their own paginated endpoint. The outer `state` describes the
review; nested `user.state` describes the account. The generated model retains
unknown future review states, while the UI uses a localized unknown-state label.
The complete reviewer set is validated for positive unique IDs, nonblank states
and advancing cursors. Wire user IDs must be integers before generated model
parsing, so fractional values cannot be truncated into another identity. Missing membership is a successful unassigned state,
not an unavailable endpoint. If a preparation read is unavailable, notes and a
summary remain publishable, but outcome selection is disabled.

The current [primary API implementation](https://gitlab.com/gitlab-org/gitlab/-/raw/master/lib/api/draft_notes.rb)
publishes notes before creating the summary and applying reviewer state. These
steps can succeed separately. Its reviewer-state service result is not checked
before returning 204, so an outcome submission additionally reads all reviewer
pages after the write and confirms the current user's requested state. A
mismatch or failed read leaves the shared uncertainty gate in place.

[Reviewer-state behavior](https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/services/merge_requests/update_reviewer_state_service.rb)
is distinct from formal approval: reviewed does not approve the MR and can
clear the caller's previous change request. Requesting changes can block merging
and remove the caller's existing approval. The dialog explains both effects.
Reviewed cannot replace an existing approved state; that choice is disabled and
the controller refuses it before publication. GitLab may assign the submitting
user as a reviewer; existing reviewer membership is not required by this client.
Server permissions and edition capabilities remain authoritative.

## Confirmation, cancellation and recovery

The immutable preview binds the account, client, repositories, route IID and
global MR ID. Whole-review publication still compares every fresh private draft
against that preview. When an outcome is selected, a complete fresh reviewer
read must also match the preview before dispatch. Shared command reservations
prevent overlapping public or private discussion mutations. Every asynchronous
boundary checks the current session and origin before adopting results.

Unconfirmed or obsolete writes require inspection. Actual write settlement is
awaited before staging complete private notes and public discussions. If the
attempt included reviewer state, a complete current reviewer read is mandatory,
even when recovery is entered through selected-note publication. A failed state
inspection cannot clear the gate or adopt a partial public result. Only a
complete current inspection clears the gate; new consent is then required for
another explicit submission. A new preview clears an outcome that is unavailable
or disabled, so notes and summary publication can remain available. The UI retains the unsent summary/outcome in the
current dialog and warns that they may already have been applied. Closing or
changing the account, client, repository, MR or origin discards local input.
No stored text or missing draft is interpreted as proof of exactly-once success.

## Validation and limits

Tests reproduce missing API options, state confirmation/recovery and UI controls
before implementation. Coverage includes empty intermediate reviewer pages,
unknown state preservation, malformed/status-first responses, exact public
payloads, state-only and summary-only submissions, stale reviewer comparisons,
partial publication, required state recovery, cancellation boundaries, actual
write settlement, renewed consent and obsolete input isolation. Existing whole
and selected publication suites remain regression checks. Five locales, three
widths and both themes are exercised, including 1.8 text scale with a 320-pixel
keyboard inset. Twelve synthetic confirmation/recovery captures are in
[the image directory](images/mr-review-submission).

This is a paginated preflight and observed postwrite state, not an atomic server
transaction or proof that no other client intervened. Recovery remains in memory
and is not durable across app restarts. No live-instance/device validation is
claimed. No dependencies, persistence, telemetry, formal approval or merge
command are added. Model and localization outputs are generated. Additional
private reply/commit/image/file creation remains separate; MW-07 is in progress.

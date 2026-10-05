# Private reply drafts on existing MR discussions

Issue [#622](https://github.com/Theorvane/LabFox/issues/622) adds **Save private
reply** to existing public discussion groups on MR detail. The shared composer
shows the selected discussion, stores exact private Markdown, and leaves unsent
public comments and replies intact. Saving does not publish the reply or resolve
the discussion. The pending review panel handles later inspection, editing,
deletion and publication through its existing guarded commands.

## API and supported targets

The documented [Draft Notes creation endpoint](https://docs.gitlab.com/api/draft_notes/#create-a-draft-note)
accepts `in_reply_to_discussion_id`. One account-bound POST sends the exact
selected ID, exact `note` and explicit `resolve_discussion: false`. It supplies
no position, commit or public comment fallback. The returned HTTP 201 must
confirm a positive draft ID, captured author, authoritative global MR ID, exact
body and discussion ID, false resolution, and no unexpected anchor/commit.
Status-first plain decoding keeps malformed HTTP errors typed and sanitized.
Redirects, OAuth replay and automatic retry are disabled.

[GitLab's primary creation service](https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/services/draft_notes/create_service.rb)
finds an existing MR discussion, rejects a missing/system origin and saves its
reply ID. [Discussion IDs](https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/models/discussion.rb)
can differ from reply IDs in special contexts. This flow offers existing
non-individual discussion groups with a non-system first note and confirms the
exact returned ID; it never guesses another discussion ID. Individual notes,
empty/system origins and invalid identities are ineligible. Public replies on
individual notes retain their existing separate behavior. Replies to existing
positioned threads use the discussion ID without reconstructing a text/image
anchor. Creating a new commit/image/file draft remains a separate slice.

The server can implicitly mark a reviewer as having started a review when it
creates a pending draft. This client sends no reviewer-state command during
private save. Formal approval, reviewer outcomes and publication remain separate
explicit actions, and GitLab permissions/capabilities remain authoritative.

## Freshness, reservations and recovery

Before dispatch, the shared discussion controller captures the authenticated
client/repositories/account, refreshes MR detail and checks route IID separately
from global MR identity. It reads the complete selected public discussion and
compares its notes, order and metadata with the displayed target. A changed,
missing, forged or ineligible target cannot dispatch a private write. Public
comments, replies, resolution, suggestion application, private commands and
pagination share the same reservation while the command runs.

An uncertain or unconfirmed dispatched save keeps the shared private-write
gate across ordinary refresh and same-account repository/client replacement.
Actual request settlement is tracked even if the originating view is cancelled.
**Check pending review** waits for that settlement, follows every private-page
cursor, and reads the original public target. Both sides are validated and staged
before adopting anything. Changed context replaces only that loaded discussion;
other discussions and pagination stay intact. A missing original target stays
missing and disables save; another thread cannot replace it. Failed private or
public reads leave the gate and loaded context intact.

The dialog retains current private input after failure, displays all inspected
pending notes and current discussion context, and requires fresh consent before
an explicit retry. Editing the input resets consent. Even a pre-dispatch stale
context requires visible inspection before another attempt. Closing or changing
the account/client/repository/resource/origin discards private input and context;
obsolete results cannot toast, expose private rows or dispatch further requests.
A regression reproduces origin cancellation at the final authoritative-detail
validation boundary; the captured origin is checked again before the target GET.
The stable conversation parent owns the dialog, so removal of the original
thread during recovery does not prematurely dispose the missing-target message.

Scoped reply recovery cannot clear an uncertain publication or reviewer outcome.
Those attempts still require the complete private/public/reviewer recovery in
the publication flow. No text match or missing note proves exactly-once success.
These read-then-write checks are not an atomic server snapshot or conditional
write. Recovery is in memory and does not survive application restart; a new
explicit retry can still duplicate a write that the server already accepted.

## Validation and boundaries

Behavior tests fail first for missing API/repository/controller/UI behavior.
They cover strict private request/response semantics, typed sanitized failures,
fresh target comparisons, shared reservations, actual settlement, full private
pagination, missing/changed/invalid contexts, publication-gate preservation,
session/origin replacement, public draft preservation and the integrated MR
detail refresh. Five locales use the same responsive UI, including 1.8 text
scale with a 280-pixel keyboard. Resize and theme changes preserve input.

[Twelve synthetic widget captures](images/mr-private-review-replies/README.md)
cover 390/800/1200 widths in light/dark themes for composition and recovery.
Dummy notes/users/credentials are used throughout. These captures and unit/widget
tests do not claim live GitLab, real device or on-device manual validation.
No dependencies, token storage, disk persistence or telemetry were added.
MW-07 remains in progress; additional draft creation types remain follow-ups.

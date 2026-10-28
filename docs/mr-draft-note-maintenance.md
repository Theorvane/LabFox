# Private draft-note update and delete foundations

Issue [#610](https://github.com/Theorvane/LabFox/issues/610) / [PR #611](https://github.com/Theorvane/LabFox/pull/611) adds update/delete
methods to `MergeRequestsApi` and the account-bound `MrDraftNotesRepository`.
They build on [private reads](mr-draft-notes.md) and
[creation](mr-draft-note-creation.md). The existing
[regular composer](mr-pending-review-composer.md) is unchanged. Editing/deletion
controller orchestration, localized UI, target confirmation and recovery remain
the next slice; these methods are not exposed as widget commands yet.

## API contract

The [official Draft Notes API](https://docs.gitlab.com/api/draft_notes/) documents
PUT and DELETE at the project/MR-IID/draft-ID resource route. Numeric projects
must be positive; nonblank namespaced project paths are encoded as one path
segment. IID and draft ID must be positive and distinct from the DTO's global
MR identity. Instance and optional subpath always come from the injected client.

`updateDraftNote` sends exact nonblank Markdown, including leading/trailing
whitespace, and optionally the original complete text position. It does not
send reply, commit or resolution changes. It requires HTTP 200 and a validated
generated draft DTO with the requested draft ID, exact body and confirmed
original position. Regular null/empty text placeholders remain regular notes.
Incomplete, image/file/future and invalid multiline anchors fail before dispatch.
Known multiline endpoint codes and sides are exact; optional display counters
may be omitted in the returned original range.

Positioned updates must explicitly resend the original position. The
[official server's endpoint](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/api/draft_notes.rb)
assigns the position parameter on update, so omission can clear it. Only API
behavior was inspected; no upstream implementation code was copied. The
repository normalizes regular placeholders to omission, passes complete original
text positions through the existing validation/payload helpers, and refuses an
opaque line-code-only target rather than guessing or re-anchoring it.

`deleteDraftNote` sends one DELETE without a body or query. Only HTTP 204
acknowledges deletion. A 404 remains typed failure, not proof this attempt deleted
the note. The endpoint's 204 behavior was checked against the official server;
HTTP conventions are also described in the
[API style guide](https://docs.gitlab.com/development/api_styleguide/#using-http-status-helpers).
The acknowledgement provides no body/global identity or atomic review snapshot.

Both operations disable redirects and authentication replay and make one request
only. They never create a replacement draft, post a public comment or publish a
review. Responses are read as plain wire text so HTTP status is handled before
JSON decoding; deletion ignores its body. A malformed successful update is a
sanitized server failure rather than a connection failure or leaked payload.
401/403/404/429/5xx keep their domain errors; 409/412/422 become conflicts with
the original status. Transport failures remain sanitized connection errors.

## Account-bound repository contract

Update/delete require the selected draft plus fresh authoritative positive global
MR identity separately from route project/IID. Invalid draft IDs, another author
or mismatched global MR identity fail before dispatch. The author comes from the
repository's captured account, not from caller-supplied mutation fields.

Updates also confirm that author/global identity and all modeled non-body metadata remain
unchanged, including reply, commit, resolution and line-code values. Unknown
metadata stays unknown; unexpected additions/removals fail conservatively.
Original position confirmation uses the API's semantic checks, allowing omitted
optional range display counters without replacing exact original codes or sides.
Delete can address owned image/file/opaque notes by ID because it does not need
to reconstruct or retarget their positions.

These methods cannot prove a selected draft is still fresh or prevent another
client from editing concurrently. The subsequent controller must reload fresh
MR detail and private target state, reserve shared discussion writes, verify the
current account/view before dispatch and after completion, and stage visible
read-only recovery after uncertain outcomes. API success cannot undo an already
dispatched write after sign-out, and a client timeout can follow server success.
There is no automatic retry, durable recovery, optimistic publication or
exactly-once guarantee in this foundation.

## Verification

Tests were written before the methods and failed for their missing implementation.
A later raw-wire regression reproduced malformed JSON obscuring HTTP errors,
including 401/403/404/409/412/422/429/500, before the plain-text/status-first fix.
There are 118 API and 48 repository tests covering exact bodies, encoded paths,
positive IDs, valid single/multiline anchors, omitted optional counters,
malformed/unconfirmed responses, typed status/transport errors, OAuth replay
prevention, strict deletion acknowledgement, ownership/global identity and
unchanged original metadata. Existing private reader/create/save/composer/panel
regressions also pass.

No model, generated file, dependency, license, localization, visible layout,
cache or analytics changes are introduced. Tests use synthetic identities and
dummy credentials; no live GitLab, physical-device or store validation is claimed.
Publication and editing/deletion UI remain separate. MW-07 stays in progress.

The subsequent [maintenance UI](mr-pending-review-maintenance.md) connects
guarded private editing and confirmed deletion, with fresh selected-target
comparison and visible inspection before an explicit retry.

# Private drafts on original commit text diffs

Issue [#624](https://github.com/Theorvane/LabFox/issues/624) adds an API and
repository foundation for creating a private review draft with an explicit
commit association. It adds no button, commit selector or controller command.
The existing regular/text MR draft and reply creation methods keep their
contracts.

## Contract and supported inputs

The [official Draft Notes creation API](https://docs.gitlab.com/api/draft_notes/#create-a-draft-note)
accepts `commit_id` and `position` on the MR draft endpoint. The new
`MergeRequestsApi.createCommitDraftNote` requires a full lowercase SHA-1 commit
ID and a complete original text position whose head SHA equals that commit.
It supports added, deleted and context lines, and the existing validated text
range format. Exact Markdown, paths, SHA triplet and supplied range fields are
preserved. Unsupported/incomplete positions, mismatched heads, blank bodies,
invalid route identities, abbreviated hashes and mutable references fail before
dispatch. The method deliberately restricts the documented endpoint; image/file
positions and other hash formats remain separate work.

One account-bound private POST sends the exact commit/body/position and explicit
`resolve_discussion: false`, without a reply target. HTTP 201 must confirm
positive integral draft/author/global MR identities, exact body and commit, no
reply association, false resolution and the same semantic original position.
Optional range display coordinates can be omitted by the server; endpoint codes
and sides cannot change. A server-generated line code is retained without
inventing one. `MrDraftNotesRepository.createCommit` also confirms the captured
author and authoritative global MR ID separately from the routing IID.

Status-first plain decoding keeps malformed error responses typed and sanitized.
Redirects, authentication replay, automatic retry and public-write fallback are
disabled. An invalid acknowledgement or transport failure may follow a successful
server write. This method never infers that the server did not save the draft.

## Boundary before user-facing integration

The [primary GitLab draft model](https://raw.githubusercontent.com/gitlabhq/gitlabhq/master/app/models/draft_note.rb)
validates the commit against the target project and copies commit/diff attributes
on publication only for a complete diff position. This slice therefore excludes
unpositioned commit drafts. Private creation confirms the returned association;
it does not prove later publication retained that target on every GitLab version.
GitLab remains authoritative for permissions, commit availability and capability.
Creation can implicitly move the reviewer to review started; the client sends
no reviewer-state, approval or publication command here.

Before exposing this foundation, a separate controller/UI slice must select a
literal original commit diff, verify MR membership and fresh selected coordinates,
capture account/client/repository/resource/origin identity, share the existing
write reservation, track actual settlement and visibly inspect complete pending
notes plus fresh original commit context before explicit retry. These protections
are not supplied by this low-level method and must not be bypassed by calling it
from a widget. No atomic snapshot, conditional write, durable recovery or
exactly-once guarantee is claimed.

## Validation

The test-first API/repository suite covers exact private payloads, self-hosted
subpaths and encoded project paths, identity/position guards, changed or malformed
acknowledgements, sanitized status-first errors and single-attempt transport/auth
failures. Existing models already represent the association; no model or generated
file changed. No UI, localization, dependency, storage or telemetry was added.
Unit tests use synthetic notes, hashes and dummy credentials, and do not claim
live GitLab or device validation. MW-07 remains in progress: guarded commit UI and
image/file draft creation are follow-ups.

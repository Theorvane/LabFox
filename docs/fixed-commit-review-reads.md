# Fixed commit detail reads

Issue [#632](https://github.com/Theorvane/LabFox/issues/632) adds strict commit
detail reads for original review context. Existing general `commit` reads retain
branch/tag compatibility. No original diff coordinates or private-write UI is
exposed.

## Exact identity and parent metadata

The [official single commit endpoint](https://docs.gitlab.com/api/commits/#retrieve-a-commit)
uses `GET /projects/:id/repository/commits/:sha` and permits a commit hash or a
branch/tag reference. `RepositoryApi.fixedCommit` deliberately requires a full
lowercase SHA-1 and a positive numeric project or nonblank encoded path. It
requests `stats=false`, uses the captured instance/client, disables redirects
and checks HTTP 200 before decoding plain JSON. Returned `id` must exactly equal
the captured head. Missing/mismatched identities and malformed payloads fail
with sanitized domain errors; status/transport errors retain typed mapping.
Existing captured-account read-only OAuth recovery remains available on that
same fixed route.

Nullable generated `Commit.parentIds` retains its existing contract: absent or
null parents stay unknown, an empty array identifies a reported root commit, and
multiple parents retain server order. Every reported parent must be a full
lowercase SHA-1, distinct from the head and from other parents. Text is preserved
without trimming. The returned parent list is immutable through the existing
generated model; no serializer or model changes are required.

## Captured repository read

`HistoryRepository.originalCommit` requires a captured numeric project and head
plus a caller currency guard. It performs one strict detail GET through its
captured account client. The guard runs before dispatch and before successful
exposure or propagating a typed failure. Obsolete results/errors return null;
current failures stay typed. A guard cannot abort a dispatched GET or its
account-bound authentication recovery, and callers must recheck after awaiting.

The caller selects the target from fresh MR identity, not from a screen project,
source branch or list metadata. Availability of a fixed commit in that repository
does not establish current MR membership, original parent/reference semantics,
literal coordinates, complete diff coverage, permissions or an atomic snapshot.
Root/merge metadata is preserved without synthesizing blank/empty-tree references
or choosing a parent. MR-wide `diff_refs` are not a fallback. A future controller
must combine fresh identity/membership and exact original literal selection with
shared private-write reservations, settlement and explicit recovery.

## Validation

Test-first API/repository regressions cover encoded captured routes, exact head
and text preservation, unknown/root/ordered parents, invalid/self/duplicate
parents, input guards, immutable metadata, sanitized status-first failures,
redirect options, read-only OAuth recovery and origin replacement. A general
branch-reference read still works. Full workspace format, analysis and all five
package test gates apply. No UI/localization, dependencies, persistence, telemetry
or private-write behavior changes; live private-instance/device validation is
not claimed. Original reference validation and guarded review UI remain
follow-ups; MW-07 and image/file draft creation remain in progress.

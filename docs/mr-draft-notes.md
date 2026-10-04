# Pending MR review note reader

Issue [#598](https://github.com/Theorvane/labfox/issues/598) /
[PR #599](https://github.com/Theorvane/labfox/pull/599) adds the read-only
foundation for unpublished server-backed review notes in MW-07. The later
[creation prerequisite](mr-draft-note-creation.md) adds a separate single-attempt
mutation; the reader itself never writes. Draft notes are
visible only to their author until publication. This slice does not expose a UI
or create, edit, delete, publish or bulk-publish notes.

## Contract

The [official Draft Notes API](https://docs.gitlab.com/api/draft_notes/)
documents this endpoint for Free, Premium and Ultimate on GitLab.com,
Self-Managed and Dedicated:

```text
GET /projects/:id/merge_requests/:merge_request_iid/draft_notes
```

`mergeRequests.draftNotes(projectId, iid: ..., page: ..., perPage: ...)` reads
exactly one page. Numeric project IDs and URL-encoded full project paths use the
configured instance/subpath. The route always uses the per-project IID; the
returned `merge_request_id` remains a distinct global ID. It never infers an IID
from that field.

Only HTTP 200 confirms a page. HTTP 401, 403, 404, 429 and server/transport
failures retain their domain types; unavailable endpoints are errors, not empty
reviews. Redirects are not followed. Ordinary read-only OAuth refresh can retry
once through the existing authenticated client. No draft mutation is sent.

The generated `MergeRequestDraftNote` preserves exact Markdown and required
positive integral draft/author/global MR identities. Reply discussion ID,
resolve-discussion intent, commit ID, line code and original diff position are
nullable. Missing metadata stays unknown. Regular-note positions with null
coordinates are valid and do not become line anchors. Full text ranges, image
coordinates, file and future position types remain available without inference.

Before generated parsing, the API rejects missing/incorrect identities and note
bodies, duplicate draft IDs, mixed global MR IDs within a page, wrong metadata
types and fractional/nonpositive line coordinates. It reuses the existing diff
position validator. Malformed pages fail completely with a static sanitized
message rather than exposing note text, paths, identifiers or payload details.
Unknown fields are ignored for forward compatibility.

Next-page headers are preserved, including on an empty page. Absent/empty
cursors end the page. Invalid, repeated/backward and multiple-valued cursors are
sanitized failures. Optional total/total-page headers are carried through; they
are not required and do not cause eager reads. Returned items are immutable and
retain server order. Global MR identity consistency is checked within the page;
this foundation does not load MR detail or aggregate multiple pages.

## Account-bound application reads

`MrDraftNotesRepository` holds one authenticated client and captured positive
author user ID. Every returned draft must belong to that author; any mismatch
rejects the whole page with a sanitized ownership error.

`mrDraftNotesRepositoryProvider` watches the account and account-bound client.
Disposal during token/client resolution prevents dispatch through that obsolete
session. Switching to another instance with the same user ID also rebuilds it.

`MrDraftNotesQuery` contains a project/IID reference, page and page size.
`mrDraftNotesReadProvider(query).future` is the read-only future, and invalidating
that provider is the explicit retry/refresh operation. Its auto-dispose lifetime
prevents a removed MR/page consumer from dispatching after repository resolution.
Riverpod discards superseded asynchronous completions and errors.

Presentation must watch `mrDraftNotesPageProvider(query)`, which exposes an
`AsyncValue` with previous data removed during loading and errors. Riverpod's
normal FutureProvider retains old data in these states; private review notes
must not be visible during account replacement, sign-out or a failed refresh.
The tests reproduce that retention failure and verify immediate removal even
before the scheduled rebuild pump. Consumers maintain a subscription while
waiting for a future; unused page and repository providers dispose automatically.

There is no disk cache, new analytics event, localization/UI change, dependency
or licence change. Paging/aggregation, publication confirmation, shared write
reservations, diff-anchor eligibility and pending-review presentation remain
separate follow-up work. Already dispatched reads may finish on the old client;
those results cannot replace a current page.

## Verification

Test-first coverage verifies generated round trips, documented null positions,
exact Markdown, original ranges, strict identity/coordinate parsing, pagination,
HTTP precedence, sanitized transport errors and read-only OAuth refresh. App
coverage verifies authorship rejection, distinct page/resource keys, signed-out
and missing-token states, account/client/instance replacement, pending token
cancellation, old success/error isolation, immediate loaded-row removal,
resource disposal and explicit GET retry. A second reproduced failure checks
multi-valued pagination headers that previously escaped as raw exceptions.

Run format and analysis at the workspace root, build_runner in gitlab_models,
and tests in each package. No live GitLab, device, store or visual presentation
validation is claimed for this API/data slice.

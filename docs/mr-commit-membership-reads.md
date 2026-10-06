# MR commit membership reads

Issue [#626](https://github.com/Theorvane/LabFox/issues/626) adds read-only
MR commit pages and a complete advertised-page traversal needed before guarded
commit review UI. Project history is not substituted for MR membership.
No new user action, original commit diff snapshot or private write is exposed.

## Commit identities and parents

`Commit.parentIds` is nullable generated metadata. Omitted/null parents stay
unknown; an explicit empty list identifies a root commit. Ordered merge parents
are preserved without choosing a parent or inventing an anchor. JSON round trips,
value equality and copy operations retain the distinction; parsed parent lists
cannot be mutated through the model getter.

The [official MR commits endpoint](https://docs.gitlab.com/api/merge_requests/#retrieve-merge-request-commits)
uses `GET /projects/:id/merge_requests/:merge_request_iid/commits`. One captured
account client sends the encoded project, route IID, page and page size. The new
reader currently supports full lowercase SHA-1 identities, consistently with the
commit-draft creation foundation. It rejects duplicate page IDs, malformed or
self/duplicate parent identities, and model parsing failures with typed,
sanitized errors. Missing parents remain unknown; empty commit titles are valid.
Status is checked before plain JSON decoding. Redirects are disabled, while the
existing account-bound read-only OAuth refresh remains available. No writes,
publication commands or public-history fallback are sent.

## Pagination and obsolete origins

The [offset pagination contract](https://docs.gitlab.com/api/rest/#pagination)
provides page cursors and Link targets; totals may be absent. The reader uses
`X-Next-Page` or an offset `Link` next relation and rejects contradictory reported
pages/sizes, duplicate/stale cursors or malformed links. It never generates a
next page from the row count or assumes a total. Standard quoted/unquoted
relations, case-insensitive registered names and relative targets are supported
as described by [RFC 8288](https://www.rfc-editor.org/rfc/rfc8288.html).

A next Link must retain the captured scheme, host, port, resource path and page
size and contain one page and one per-page value. Optional `id` and
`merge_request_iid` route echoes must each occur once and exactly match the
captured identity. GitLab’s [offset header builder](https://github.com/gitlabhq/gitlabhq/blob/master/lib/gitlab/pagination/offset_header_builder.rb)
includes these echoes, confirmed with an unauthenticated public MR commits
header check. They are validated but never forwarded as query overrides.
Credentials, fragments,
context-changing anchor parameters, foreign routes and additional filters are
rejected. Only the validated offset is reused; the next request retains the
captured route rather than dispatching a supplied URL. The parser deliberately
supports this offset subset, not keyset or arbitrary Link extensions.

`MergeRequestsRepository.commits` follows every advertised page with page size
100, rejects cross-page duplicates and returns the ordered immutable list only
after traversal finishes. A required caller-supplied currency guard runs before
each request, after each result/error and before final exposure. An obsolete
origin returns null, separately from a current empty MR; partial or late results
and late typed errors are discarded. A current failed page remains a typed error.
The guard stops further page requests; it does not abort an already dispatched
GET or its account-bound read-only authentication recovery.

These are sequential reads, not an atomic server snapshot. Missing pagination
metadata is not proof of a complete server collection; traversal follows the
advertised connection. Parent references do not themselves prove original diff
coordinates or MR membership at a future write. The caller must still recheck
currency after awaiting and refresh authoritative MR/fork identities, selected
commit membership and literal original diff context before using the existing
private-write reservation and settlement/inspection recovery flow.

## Validation and remaining work

Tests are written before implementation. They cover parent metadata, strict
route/payload/cursor handling, sanitized typed failures, read-only authentication
refresh, complete immutable traversal and origin replacement. Additional failing
regressions pin standard Link case/relative resolution and anchor isolation, and
obsolete-origin errors are reproduced before the cancellation-aware fix.
Malformed relation-token regressions prevent invalid links from silently ending
a traversal. Real-header route-echo regressions fail before their compatibility fix.
Models are regenerated with build runner; no generated file is edited by hand.
No UI, localization, dependency, token storage, persistence or telemetry is added.
The public header spot-check does not validate app/device or private-write behavior. Original commit diff
reads/selection and guarded save/recovery UI remain follow-ups; MW-07 stays in
progress, including image/file draft creation.

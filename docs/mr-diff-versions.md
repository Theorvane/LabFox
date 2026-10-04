# MR diff version reads

The generated `MergeRequestDiffVersion` and `MergeRequestVersionFile` models retain
GitLab's original version metadata and raw file snapshot. The API methods follow
[the documented version endpoints](https://docs.gitlab.com/api/merge_requests/#retrieve-merge-request-diff-versions).

`mergeRequests.diffVersions(projectId, iid: ..., page: ..., perPage: ...)` reads one
page in the server's order. It preserves response pagination headers without
assuming total counts or fetching subsequent pages. Version IDs are positive,
unique within the page, and separate from the MR IID and global MR ID.

`mergeRequests.diffVersion(projectId, iid: ..., versionId: ...)` selects one exact
version and requests `unidiff=true`. The returned version ID must match the
request. It never substitutes the current MR diff when an old version is missing
or malformed. Both methods support encoded project paths and self-hosted base
URLs, map HTTP status before parsing, and sanitize malformed successful payloads.

## Snapshot semantics

- Base/start/head commit SHAs retain their separate meanings. Missing SHAs remain
  unknown, so consumers must verify a complete matching triplet before anchoring
  a discussion or creating a positioned thread.
- `files == null` means no file snapshot was returned; an empty list means an
  explicitly empty snapshot. Neither authorizes inventing a current snapshot.
- Both renamed paths, file modes, raw diff text and supplied file flags are
  preserved. Missing flags remain unknown.
- Missing `diff` text remains nullable. A missing diff must not automatically be
  labelled binary. Explicit empty text, `collapsed`, `too_large` and version
  collection state allow future renderers to explain incomplete snapshots.
- Unfamiliar collection states remain strings for compatibility. The raw size
  value is preserved instead of coercing it to a file count.

This API foundation does not render an inline review screen or create threads.
Future UI must handle unavailable versions, partial snapshots and stale
positions explicitly. Tests use documented synthetic payloads; live GitLab and
physical-device validation are not claimed.

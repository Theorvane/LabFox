# Original commit diff reads

Issue [#628](https://github.com/Theorvane/LabFox/issues/628) adds a read foundation
for literal original commit diffs. The existing parsed `commitDiff` API retains
its contract. No new UI action, private write or write eligibility is exposed.

## Literal file metadata

Generated `CommitDiffFile` preserves exact old/new paths, nullable raw diff text,
modes, required new/deleted/renamed flags and nullable collapsed/too-large/generated
metadata. Missing or null text stays unknown; an explicit empty string stays
empty. Omission flags retain their reported values even alongside text. The
reader does not trim, parse or reconstruct lines, normalize paths, invent hunk
coordinates, or classify every absent diff as binary. The existing renderer may
be used later only through a separately validated original context.

## Fixed commit pages

The [official commits endpoint](https://docs.gitlab.com/api/commits/#retrieve-commit-diff)
uses `GET /projects/:id/repository/commits/:sha/diff`. The new
`RepositoryApi.commitDiffPage` restricts the reference to a full lowercase SHA-1
commit ID, encodes the project route and requests `unidiff=true` with offset page
and size. It checks HTTP 200 before plain JSON decoding, converts malformed
payloads into sanitized domain errors, rejects empty/NUL paths and duplicate
old/new path pairs, and returns immutable files. Redirects are disabled; the
existing captured-account read-only OAuth recovery remains available.

The shared offset validator retains the MR membership contract while supporting
fixed query parameters. It validates page/size/cursor consistency, standard
case-insensitive registered relations and relative same-resource targets. A next
diff Link must retain captured origin, path and size plus exactly one
`unidiff=true`; optional `id`/`sha` route echoes must match exactly and occur once.
Unknown filters, duplicate/mismatched identities, credentials, fragments, anchor
context overrides, stale cursors and contradictory Link/header metadata fail.
Only the validated offset is reused; no supplied URL or route echo is forwarded.
Totals remain optional, and row count never generates a next page.

An unauthenticated public GitLab header spot-check confirmed `id`, `sha` and
`unidiff` query fields. The [primary endpoint](https://github.com/gitlabhq/gitlabhq/blob/master/lib/api/commits.rb)
and [offset header builder](https://github.com/gitlabhq/gitlabhq/blob/master/lib/gitlab/pagination/offset_header_builder.rb)
confirm offset pagination; no upstream implementation code is copied.

## Captured origin and coverage limits

`HistoryRepository.originalCommitDiff` follows advertised pages at size 100
through one captured account client and project/commit identity. It preserves
server file order, rejects cross-page duplicate path pairs and returns an
immutable list only after traversal. A required caller currency guard runs before
each request, after results/typed errors and before final exposure. Obsolete
origins return null, separately from current empty results; partial/late outcomes
are discarded. Current failures stay typed. The guard cannot abort an already
dispatched GET or its account-bound authentication recovery; callers must recheck
currency after awaiting.

GitLab documents that its diff file limit can stop pagination before all changes
are exposed. Completing advertised pages, optional totals and missing metadata
therefore do not prove full file coverage, an atomic snapshot, original parent
coordinates or safe future writes. The caller must choose the project from
authoritative MR/fork context; this reader neither resolves that context nor
substitutes the screen project, MR-wide diffs or branch history. Ordered parent
metadata alone does not choose the correct merge-commit context.

## Validation and follow-ups

Test-first model/API/repository regressions cover literal whitespace and
no-newline markers, missing text/flags, strict immutable routes, payload and cursor
validation, sanitized status-first failures, captured read-only authentication,
nonconsecutive page traversal, duplicate files and origin replacement. Existing
MR membership pagination is rechecked through the extracted shared helper.
Models and serializers are regenerated together. No UI/localization, dependency,
secure token storage, persistence or telemetry behavior is added or changed.
The public header spot-check and tests do not validate app/device or live private
writes. Authoritative MR/fork identity, validated original parent references,
literal selection and guarded reservation/settlement/recovery UI remain follow-ups.
MW-07 remains in progress, including image/file private draft creation.

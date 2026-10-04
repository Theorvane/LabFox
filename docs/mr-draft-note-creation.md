# Unpublished MR review draft creation

Issue [#600](https://github.com/Theorvane/labfox/issues/600) adds the mutation
prerequisite for pending MR review in MW-07. It extends the
[private draft reader](mr-draft-notes.md) with creation of new regular and
original text-positioned drafts, including multiline ranges. No creation UI,
reply/resolution draft, commit/image/file draft, editing/deletion or publication
flow is exposed by this slice.

## Request and confirmation

The [official Draft Notes API](https://docs.gitlab.com/api/draft_notes/#create-a-draft-note)
defines this route:

```text
POST /projects/:id/merge_requests/:merge_request_iid/draft_notes
```

`mergeRequests.createDraftNote(projectId, iid: ..., note: ..., position: ...)`
sends nonempty Markdown exactly, without trimming or replacing it. The route
uses the per-project IID and encodes full project paths. Instance/subpath and
authentication routing come from the account-bound client. An explicitly false
`resolve_discussion` prevents accidental resolution intent. This API does not
send reply, commit-association, publication, reviewer-state or approval commands.

An optional position must be a complete original text anchor: SHA triplet,
both paths, at least one positive old/new line and structurally valid range
endpoints. Image/file/future creation positions and image coordinates are
unsupported. Position nulls are omitted recursively; all supplied non-null
paths, SHAs and coordinates are preserved. The existing published-discussion
validator is shared without changing its behavior. Callers still obtain literal
line/range membership from the authoritative review snapshot; structural
validation cannot prove that an arbitrary position belongs to a real diff.

Creation requires HTTP 201 and a single generated draft object. Required
positive integral draft/author/global MR identities are validated before model
parsing. Confirmation requires the exact submitted Markdown, explicit false
resolution intent, no reply/commit association and the exact original position.
SHA/path/parent coordinates and range codes/sides must match. Optional returned
range display coordinates can be absent; supplied contradictory values fail.

A regular draft can return absent/null position or a text placeholder with all
coordinates absent/null, matching the documented regular-note example. A
position, line code or non-text position unexpectedly attached to a regular
draft cannot confirm that request. Unknown extra JSON fields are ignored.
Server normalization of Markdown or re-anchoring to another diff is an
unconfirmed result, not an invitation to fall back to the latest diff.

## Single-attempt errors

Redirect following and OAuth authentication replay are disabled for the write.
There is no automatic retry or fallback to a published comment. HTTP status
mapping precedes response parsing. HTTP 401/403/404/429 retain their domain
meaning, 409/422 become conflicts with their exact status retained, and other
unexpected statuses remain sanitized server errors. Transport and malformed
payload errors cannot expose private note content or response details.

A timeout, malformed 201 or identity mismatch may follow a successful save.
The caller must inspect authoritative private drafts before offering an explicit
retry; otherwise a second POST can duplicate the saved review note. This
foundation returns/throws once and does not yet enforce UI write reservations,
recovery interaction or session/resource freshness. Those belong to the later
controller/composer slice. A server draft can start its author's review state;
it remains unpublished and does not record formal approval.

## Account-bound repository

`MrDraftNotesRepository.create` uses its captured authenticated client/author
and requires the authoritative positive global `mergeRequestId` separately from
`iid`. It rejects an otherwise successful draft whose author or global MR ID
differs, without exposing those returned identities in an error. The global ID
is never substituted into the route. No extra read or mutation is dispatched as
a fallback; confirmed creation can be inspected with the existing private reader.

The repository itself has no UI lifecycle. Controllers must recheck the current
account/repository/resource before dispatch and isolate obsolete outcomes
before updating state, drafts, caches or analytics. Already dispatched writes
cannot be undone. No disk cache or new analytics event is added here.

## Verification

Test-first API coverage verifies regular, added, removed, context and new/old/
mixed multiline drafts; exact Markdown/path preservation; recursively absent
nulls; original SHA/path/coordinate/range confirmation; invalid inputs before
network dispatch; regular null-position compatibility; malformed/fractional
responses; precise HTTP status mapping; sanitized transport failures; and no
OAuth replay. Repository coverage checks captured authorship, expected global
MR identity, IID routing, pre-dispatch global-ID validation, typed permission
failures and explicit reader inspection after confirmed creation.

The published single-line/multiline discussion regression suites remain green.
Workspace format/analysis and all five package suites are required before push,
followed by exact-head review and CI. No model, dependency, localization or
visual UI changes are introduced. No live GitLab/device/store validation is
claimed. Upstream API/entity/model sources were inspected only to verify the
response contract; no upstream implementation was copied.

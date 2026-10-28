# MR identity for original commit review

Issue [#630](https://github.com/Theorvane/LabFox/issues/630) preserves MR fork
identity and adds a captured-account detail read for future original commit
review. It exposes no UI action, private write or original diff coordinates.

## Reported fork identities

The [official single MR API](https://docs.gitlab.com/api/merge_requests/#retrieve-a-merge-request)
uses the project route and per-project `merge_request_iid`. Its response reports
global `id`, `iid`, `project_id`, `source_project_id` and `target_project_id`
separately. Generated `MergeRequest` now retains nullable source and target
project IDs alongside the existing project metadata. Fork source and target may
differ; absent or deleted source metadata remains unknown. Neither ID is filled
from the screen project, branch names or another project field.

## Detail response validation

`MergeRequestsApi.get` accepts a positive numeric project or nonblank encoded
project path and a positive IID. It preserves the label-details query, disables
redirects and checks HTTP status before decoding plain JSON. The response must
be an object with positive integer global ID and matching integer IID. Optional
project identities, when reported, must be positive integers; fractional values,
floating-point representations and coercible strings are rejected before the
generated serializer can truncate them. Reported project and target IDs must
agree with each other and with a numeric route. A slug cannot establish numeric
identity, so that read checks reported consistency without guessing its ID.
The [primary MR model](https://github.com/gitlabhq/gitlabhq/blob/master/app/models/merge_request.rb)
aliases `project_id` to `target_project_id`, confirming this consistency check.

Missing optional metadata remains compatible with general detail viewing.
Malformed payloads become sanitized domain failures, and status/transport errors
retain their typed mapping. Existing read-only OAuth recovery remains bound to
the captured account and exact route. List/search parsing is unchanged: their
metadata is not a substitute for this fresh validated detail read.

## Captured context reader

`MergeRequestsRepository.commitReviewContext` requires the captured numeric
project, IID and known global MR ID separately. It performs one detail GET
through its captured client and confirms both global MR identity and a reported
target project matching that route. Unknown target metadata fails; even a known
`project_id` is not substituted for the target field. Unknown source metadata is
retained because deletion of a fork does not establish that a selected commit is
unavailable in the target repository.

A required caller currency guard runs before dispatch, after the response or
typed failure, and before exposure. Obsolete results/errors return null; current
failures remain typed. The guard cannot cancel an already dispatched GET or its
account-bound authentication recovery. Callers must recheck after awaiting.

The [primary draft model](https://github.com/gitlabhq/gitlabhq/blob/master/app/models/draft_note.rb)
defaults its project to the MR target and validates the commit there. This
observation motivates preserving target identity; it does not prove selected
commit availability, current membership, original parent/reference semantics,
diff coverage or permission to write. No server implementation code is copied.
Sequential identity/membership/diff reads are not an atomic snapshot. Before
private writes, the future controller must validate those resources, literal
coordinates and currency, then use shared reservations and settlement/recovery.
MR-wide `diff_refs` are not original commit references and are not inferred here.

## Validation and remaining work

Test-first model/API/repository cases cover same-project and fork identities,
unknown/deleted sources, integer validation, route/global identity mismatches,
sanitized status-first errors, redirect options, read-only OAuth recovery,
obsolete successes/failures and final exposure. Freezed and JSON serializers are
regenerated together. No UI/localization, dependencies, persistence, telemetry or
private-write behavior changes. No live private-instance/device verification is
claimed. Original parent/reference validation and guarded literal selection,
private-save and recovery UI remain separate. MW-07 and image/file draft creation
remain in progress.

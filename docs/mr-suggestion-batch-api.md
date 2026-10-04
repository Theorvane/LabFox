# Confirmed batch suggestion application API

`GitLabClient.suggestions.applyBatch(suggestionIds, commitMessage: ...)` uses authenticated `PUT /suggestions/batch_apply` with an `ids` array of global suggestion identities. It sends one batch request, with no fallback to separate suggestion writes. The account-bound instance URL and existing authentication retain self-hosted subpaths and PAT/OAuth support.

The input must be nonempty, positive, and unique. The client rejects invalid inputs before dispatch rather than silently removing duplicates or invalid identities. A snapshot taken before the first asynchronous boundary protects both the outgoing request and confirmation against caller list mutation. The requested order is preserved in the body. A null message is omitted; present strings, including empty or whitespace-only messages, remain exact. GitLab decides their validity and the caller's permissions.

Only HTTP 200 with a valid array confirms the batch. Every requested identity must appear exactly once with `applied=true`; missing, extra, duplicate, fractional, unknown or unapplied identities reject the entire returned confirmation. No partial result is exposed. The returned list is immutable and preserves server order, which need not match request order. Original/replacement code, inclusive line ranges and both applicability spellings use the existing strict validator before generated parsing. Optional metadata remains nullable, empty strings remain empty, and conflicting flags or reversed ranges are rejected.

The write disables redirects and automatic OAuth refresh/replay. Status-first mapping preserves authentication, permission, not-found, rate-limit and other HTTP status information; transport failures are sanitized domain errors. Malformed or incomplete confirmation becomes `Invalid suggestion batch application response.` without source code, identities or raw decoding details.

This confirms returned suggestion states, not a commit count, branch SHA, permission claim or client-side atomicity guarantee. An error or incomplete response can follow an accepted repository write. Callers must freshly inspect every selected discussion and require renewed confirmation before an explicit manual retry. There is no automatic application retry, single-write fallback, rollback or inferred success for part of a batch.

The original API slice changed no models, dependencies or generated files. The app now provides [batch selection, multi-patch confirmation and complete read-only recovery](mr-suggestion-batch-ui.md), alongside single-suggestion application. No live GitLab writes or physical-device validation are claimed.

Test-first coverage includes missing-method failure and 130 failing behavior contracts against a minimal unsafe implementation, followed by all 149 batch contracts and 254 existing single-application/metadata cases passing together. Tests cover exact routing/authentication/messages, invalid inputs, reordered and sparse confirmed payloads, every member's strict metadata boundary, incomplete identities, caller mutation, immutable results, typed failures and no OAuth replay.

Reference: [GitLab batch suggestion application](https://docs.gitlab.com/api/suggestions/#apply-multiple-suggestions).

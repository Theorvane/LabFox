# Single suggestion application API

`GitLabClient.suggestions.apply(suggestionId, commitMessage: ...)` sends authenticated `PUT /suggestions/:id/apply` using the global suggestion ID. The ID is not a note ID, MR IID, discussion ID or diff-version ID; nonpositive values fail before dispatch. The injected instance URL and account headers retain self-hosted subpaths and both PAT/OAuth authentication.

A null commit message omits the parameter and uses GitLab defaults. Present strings, including empty content and leading/trailing whitespace/newlines, are preserved exactly rather than normalized by the client. GitLab decides whether a supplied message is valid. There is no guessed client-side role check.

Writes explicitly disable redirects and the existing automatic OAuth refresh/replay path. Every call sends at most one request through the client's supported transport; no automatic application retry is added. HTTP status mapping precedes payload decoding, preserving distinct 401/403/404/429 and sanitized transport/server failures.

Only HTTP 200 with a strictly validated matching suggestion ID and `applied: true` confirms application. An HTTP success code or `applicable: true` alone is insufficient. The documentation example includes `applied: false`; this client treats it as unconfirmed rather than claiming that repository code changed. Sparse valid original/replacement/range/applicability fields remain null; optional metadata is never invented.

The shared suggestion validator retains the existing MR read/reply/resolution/positioned-creation boundaries: positive integral IDs and supplied coordinates, ordered complete ranges, string content, boolean status, consistent legacy/documented applicability aliases, and response-wide identity uniqueness. It runs before generated numeric parsing so fractional values cannot be truncated. The apply response uses the same validator and generated DTO; malformed or unconfirmed results become `Invalid suggestion application response.` without source text, IDs or raw parser details.

An error or unconfirmed response can follow an accepted repository write. A caller must reload authoritative discussions and inspect the current suggestion state before offering an explicitly confirmed manual retry. The API itself does not own UI confirmation or completion effects. The app now implements single-suggestion confirmation, shared discussion reservations, account/resource isolation and read-only recovery as documented in [the application UI](mr-suggestion-application-ui.md). The [batch API](mr-suggestion-batch-api.md) is a separate foundation; batch selection and confirmation UI remain follow-up work. No live repository change or physical-device validation is claimed.

Tests use documented synthetic payloads and dummy credentials. Reference: [Suggest Changes API](https://docs.gitlab.com/api/suggestions/).

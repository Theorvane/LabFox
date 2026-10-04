# Positioned MR discussion API

`MergeRequestsApi.createPositionedDiscussion` creates one text diff discussion using the documented project/MR-IID discussions endpoint. The caller supplies a complete `DiffNotePosition` from an authoritative diff-version snapshot. This method does not fetch, guess or upgrade the position to a newer version.

## Coordinates and request preservation

Provide the original base/start/head SHA triplet and both file paths. Added lines supply only `newLine`; removed lines supply only `oldLine`; unchanged context lines supply both, which can differ. Coordinates must be positive. Null position fields are omitted from the request. Paths and nonempty Markdown are preserved exactly, including whitespace and renamed paths. SHA strings remain opaque: server validation determines whether they identify valid commits.

This slice supports one text line. Missing anchors, image/file/future types, multiline ranges and image coordinates are rejected before any HTTP request. It introduces no dependency or model generation change.

## Confirmation and failure

The write disables redirects and automatic OAuth authentication refresh/replay. Only HTTP 201 is accepted. The generated discussion response must contain a non-individual thread and a first user DiffNote with the exact supplied SHA triplet, file paths, old/new lines and position type. A returned multiline anchor is not accepted as a single-line confirmation. Existing response validation rejects malformed note/user identities and fractional coordinates. Extra future fields do not change the verified anchor.

The returned body may reflect GitLab Markdown or quick-action processing; request Markdown is preserved, but the confirmation does not require an identical response body. HTTP and transport failures retain existing sanitized domain exception types.

An invalid response or lost connection can follow a write the server accepted. This API never automatically retries. A future composer must retain the draft, refresh authoritative discussions before retrying an uncertain write, share discussion write reservations, and isolate account/resource changes before dispatch and after completion.

## Remaining UI work

This foundation adds no line selection or composer. The UI must select coordinates from an authoritative current version and validate the selected file/line before writing. Existing read-only original context is not itself permission or evidence to create a new thread at an arbitrary old note position. Multiline creation and suggestion application remain separate work.

Tests use documented synthetic payloads, dummy tokens, and a Dio adapter. No live GitLab instance or physical device validation is claimed.

Reference: [GitLab Discussions API](https://docs.gitlab.com/api/discussions/#create-a-new-thread-in-the-merge-request-diff).

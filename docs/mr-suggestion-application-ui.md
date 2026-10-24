# Confirming and applying a code suggestion

An eligible text diff note exposes **Apply suggestion** inside its code preview. The confirmation dialog shows the original and replacement code, inclusive original line range, server application state, and an explanation that application creates a commit on the merge request source branch. Opening or cancelling the dialog sends no application request. A commit message is optional: empty uses the GitLab default; a supplied message retains its whitespace exactly.

Eligibility requires a unique positive global suggestion ID, a user `DiffNote`, text or absent legacy position metadata, complete original/replacement content and a valid range, explicit `applied=false`, and explicit patch applicability. Applicability is not an authorization check. GitLab enforces permissions. Unknown, already applied, non-text, system, malformed, or ambiguous targets offer no application action.

On confirmation, the controller reserves discussion writes and reads that exact discussion again. Its note identity, position, range, content and application flags must still match what was confirmed. Changed patches are not applied. An application is confirmed only by a matching ID, `applied=true`, and agreement with any returned patch metadata. A sparse confirmed response is allowed. Current-session success refreshes discussions, MR detail, and the latest authoritative review snapshot; application is not counted as a posted comment.

Pending application or inspection blocks duplicate discussion commands. Pending pagination also blocks application and inspection, preventing an older page result from replacing fresh state. The dialog disables its commit input and dismissal while the request is pending. Account or merge request replacement hides the previous patch and prevents undispatched writes, late feedback, and refreshes in the replacement view. A write already accepted by GitLab cannot be undone by closing or replacing a view.

An error or unconfirmed result retains the message and requires explicit **Reload discussion** before another confirmation. Reloading is read-only and preserves loaded pagination. Applied, missing, unknown, or ambiguous suggestions remain unavailable; a changed eligible patch is displayed for renewed confirmation. A failed reload keeps application disabled. Neither reload nor authentication recovery automatically replays the application.

The inspection uses the documented [single MR discussion endpoint](https://docs.gitlab.com/api/discussions/#retrieve-a-merge-request-discussion-item). It validates HTTP 200, exact discussion identity and the same strict grouped-note payload boundary as list reads. It disables redirects and allows the ordinary authenticated read refresh path. The write uses the previously reviewed [single suggestion application API](mr-suggestion-application-api.md).

## Verification and captures

Test-first evidence covers the missing confirmation action and a reproduced pagination/application race. Controller and widget tests cover explicit confirmation, exact drafts, changed patches, permission and uncertain failures, manual read-only recovery, duplicate commands, pagination, sparse and mismatching responses, account isolation, and success-only cache refreshes. API tests cover routing, malformed identities/payloads, typed status/transport failures, and ordinary OAuth read refresh. Repository tests exercise the real read/write forwarding boundary. Layout tests cover all five locales at 390, 800, and 1200 logical pixels, both themes, and a 320-pixel window with keyboard insets and doubled text.

These are synthetic Flutter widget-test captures with dummy metadata and SDK fonts; no live GitLab account, device, or store validation is implied. They can be regenerated with `LABFOX_SUGGESTION_APPLY_CAPTURE=<absolute-output-directory>` and `FLUTTER_ROOT=<Flutter-SDK-directory>` when running `mr_suggestion_application_test.dart` with the test name filter `synthetic application confirmation capture`.

| Layout | Light | Dark |
|---|---|---|
| Mobile, 390 × 844 | [Capture](images/mr-suggestion-apply/apply-390-light.png) | [Capture](images/mr-suggestion-apply/apply-390-dark.png) |
| Desktop, 1200 × 900 | [Capture](images/mr-suggestion-apply/apply-1200-light.png) | [Capture](images/mr-suggestion-apply/apply-1200-dark.png) |

The [batch application API](mr-suggestion-batch-api.md) now powers [batch selection, confirmation and complete read-only recovery](mr-suggestion-batch-ui.md). [Multiline original context](mr-discussion-context.md) is available; multiline positioned thread creation remains a separate parity slice.

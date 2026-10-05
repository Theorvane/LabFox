# Regular private pending review composer

Issue [#608](https://github.com/Theorvane/LabFox/issues/608) adds **Add review note**
to [Your pending review](mr-pending-review-panel.md) on MR detail. The modal saves
regular unpublished notes through the existing [guarded save controller](mr-pending-review-save.md).
Saved Markdown preserves its exact whitespace. The public comment draft stays
intact; private notes are never posted as public comments or tracked in analytics.

## Composition and save

The entry requires authenticated, fresh valid detail with a positive global MR
identity separate from route project/IID and ready account-bound repositories.
Opening the dialog prepares the existing discussion controller lazily. Input can
be composed during preparation, but saving requires ready reads, a valid MR and
nonblank text. Failed preparation offers read-only Retry and retains the input.

Save reserves the existing discussion controller, obtains fresh authoritative
identity, and dispatches one regular private create. The UI disables input,
Save, Cancel and back navigation while its command is pending. The existing
controller also reserves public comments, replies, resolution, suggestions and
pagination. Approval/merge actions continue using their separate controller;
this is not a transaction across every MR command.

Only confirmed current-session success closes the dialog and shows a localized
notification. The controller refreshes private-reader variants for this MR. The
entry remains mounted during its own detail refresh so that refresh cannot cancel
its originating view. Generic failed-save feedback retains editable exact input
and never displays a server payload. Idle Cancel discards unsaved input only.

## Uncertain save recovery

A failed or unconfirmed dispatched save requires **Check pending review** before
another save. Closing and reopening the composer or replacing a same-account
client/repository does not clear the controller's uncertainty requirement.
Inspection waits for an unsettled dispatched request, reloads fresh MR detail,
and traverses every private page, including empty intermediate cursors.

Only the complete successful immutable snapshot is displayed. The inspection
list shares the panel's literal selectable Markdown and known original metadata;
embedded images or links are not rendered or requested. Failed, partial or
obsolete results provide no dialog snapshot or retry acknowledgement. The
background panel can independently reload its first page during detail refresh;
that page is not the dialog's complete recovery snapshot.

The user must separately acknowledge the displayed notes and then explicitly
press Save. Inspection never retries a write. Editing resets acknowledgement;
a new inspection clears the previous snapshot and acknowledgement before reading.
Identical saved text does not prove which attempt created it. The user can cancel
rather than create another note when inspection already shows the desired note.

Recovery is in memory, not durable across process/container restarts. A settled
client timeout can leave server processing ongoing; offset traversal is not an
atomic server snapshot. Neither inspection nor acknowledgement guarantees
exactly-once creation or publication authorization.

## Private scope and layout

Account/instance changes, sign-out, MR/origin disposal and captured repository
replacement immediately hide and permanently discard input and inspection state.
Returning to the old account cannot restore it. Obsolete completions cannot show
success notifications, expose private results or dispatch further inspection
pages. Already dispatched server writes cannot be undone. Resize and theme
changes preserve current input without another save.

One width-responsive dialog serves all platforms. Its input, recovery snapshot,
acknowledgement and wrapping buttons share the outer scroll surface. The snapshot
uses a bounded lazy list with separately bounded literal note bodies. A reproduced
320-pixel, doubled Hindi text and keyboard case initially obscured acknowledgement
behind fixed actions; scrolling actions with the content makes it reachable.

All 18 new messages have English source and Korean, Japanese, Hindi and Chinese
translations. Delegates are generated with `flutter gen-l10n`. The existing 109
untranslated messages per non-English locale remain; none of these new messages
is missing. No endpoint, model, dependency, license, disk cache or telemetry is added.

## Verification and synthetic captures

There are 94 new widget regressions using the real discussion/save controllers
and synthetic account-bound repositories. Tests first failed for missing composer
implementation, then reproduced intrinsic viewport sizing and keyboard/large-text
recovery problems before their fixes. Coverage includes exact private saves,
duplicate blocking, pending preparation, invalid identity, failed reads/writes,
complete empty-page inspection, partial-result suppression, explicit
acknowledgement, editing, reopen uncertainty, account/instance/client/repository/
resource changes, late outcomes, public-draft preservation and resize/theme changes.
Both composing and recovery are checked at five locales, three widths and both
themes, with additional compact keyboard, long-body and doubled-text coverage.

Regenerate captures with `LABFOX_PENDING_COMPOSER_CAPTURE=<absolute-directory>`
and `FLUTTER_ROOT=<Flutter-SDK-directory>` while running
`mr_pending_review_composer_test.dart` filtered by `synthetic composer capture`.
Captures use existing SDK Roboto/MaterialIcons fonts and explicit fixture text
fonts. Mobile recovery is scrolled to acknowledgement. These are visually
inspected synthetic widget captures, not live GitLab/device/store validation.

| Width | Composing light | Composing dark | Inspection light | Inspection dark |
| --- | --- | --- | --- | --- |
| 390 | [Light](screenshots/mr-pending-review-composer/composer-390-light.png) | [Dark](screenshots/mr-pending-review-composer/composer-390-dark.png) | [Light](screenshots/mr-pending-review-composer/inspection-390-light.png) | [Dark](screenshots/mr-pending-review-composer/inspection-390-dark.png) |
| 800 | [Light](screenshots/mr-pending-review-composer/composer-800-light.png) | [Dark](screenshots/mr-pending-review-composer/composer-800-dark.png) | [Light](screenshots/mr-pending-review-composer/inspection-800-light.png) | [Dark](screenshots/mr-pending-review-composer/inspection-800-dark.png) |
| 1200 | [Light](screenshots/mr-pending-review-composer/composer-1200-light.png) | [Dark](screenshots/mr-pending-review-composer/composer-1200-dark.png) | [Light](screenshots/mr-pending-review-composer/inspection-1200-light.png) | [Dark](screenshots/mr-pending-review-composer/inspection-1200-dark.png) |

Positioned/reply/commit draft-save orchestration, editing/deletion and publication
remain separate slices. MW-07 stays in progress.

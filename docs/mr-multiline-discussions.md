# Multiline MR discussion creation

The existing MR Changes route supports single lines and explicit multiline selections from its authoritative latest diff-version snapshot. Select a line, choose **Select a range**, then choose a later eligible line in that file. The range summary uses signed old/new coordinates, and every covered line has an icon, border and localized selected accessibility label. **Use single line** returns to the first selected line without discarding Markdown. Submission stays disabled until an end is selected.

## Original position and available ranges

Both endpoints come from literal parsed members of the selected snapshot. Their line codes use SHA1 of the new filename and original raw old/new hunk counters, including the opposite counter that added/removed rows do not display. Endpoint display coordinates retain the actual visible sides. Added endpoints use new; removed and unchanged endpoints use old, following the documented multiline type rule. The parent position anchors the end row and preserves both original paths and all three SHAs.

Same-side ranges include visible lines on that side; mixed-side ranges include the forward interval in unified-diff order. Only two distinct ordered endpoints are accepted by the UI. Every covered hunk must be complete, with both counters continuing across hunk boundaries. Unknown text, omitted/collapsed/too-large files, duplicate paths or line identities, incomplete empty hunks, reversed endpoints and omitted spans offer no end action. Foreign line/file objects and forged positions cannot authorize a write. The per-file index makes each end action's eligibility check constant time; it does not allocate every possible range.

The application does not fetch full blobs to fill gaps, reinterpret reversed mixed endpoints, choose an arbitrary old discussion anchor or silently update a position to a newer diff version. Original discussion context remains a separate read-only flow.

## Write confirmation and recovery

The existing positioned discussion API accepts structurally complete multiline ranges, validates filename hashes, counters, sides, endpoint coordinates and the end anchor before dispatch, and omits null fields at every position depth. It preserves exact nonempty Markdown and sends one project/MR-IID discussion request. Redirect and OAuth authentication replay stay disabled. HTTP 201 must confirm the same original SHA/path/parent coordinates and start/end line codes and sides. Optional returned endpoint display coordinates may be absent; supplied values must agree with the requested code and anchor. A substituted single-line anchor or different range is unconfirmed.

Creation shares root comment, reply, resolution and suggestion reservations. Pending writes disable draft editing, range changes, cancel and back navigation. The current snapshot is rechecked before dispatch. Repository identity is also checked immediately before dispatch and after completion; obsolete-session errors cannot appear as current failures. An already dispatched server write cannot be undone. Confirmed current-session success clears the selection/draft, refreshes authoritative discussion page one and emits only the existing sanitized comment event.

An uncertain write keeps the exact range and draft and requires an explicit discussion refresh before resubmission. Inspection matches the complete range identity, distinguishing other ranges or single lines sharing the same end row. Returned display coordinates may be omitted; known contradictory values are excluded. Existing explicit older-page inspection and cursor-preserving retry remain available, and no-match guidance refers only to loaded pages. No write is automatically retried.

## Responsive presentation and evidence

The same MR Changes screen uses a scrollable composer below the diff on mobile and beside it from 600 logical pixels. Selection and draft survive resize/theme changes and same-version reads. Newer snapshots show no old-range markers and cannot submit an obsolete selection; account or MR replacement clears them. All new controls and recovery text use the five localization delegates. Diff line actions retain the standard 48 dp touch target in both themes; the previous compact density produced a 40 dp target below the repository minimum.

Test-first evidence covers absent range support, incomplete empty hunks, pre-dispatch repository replacement and immediate stale-session failures, same-version refresh editing and stale markers after a newer snapshot before their fixes. Tests cover old/new/context/mixed ranges, new/deleted files with zero opposite counters, renamed paths, adjacent and gapped hunks, duplicate/foreign identities, forged positions, request/response validation and no OAuth replay. Presentation tests cover five locales, three widths and both themes, shared reservations, uncertain-write inspection, session/resource replacement and compact keyboard/doubled-text editing.

The captures below are synthetic Flutter widget renders with SDK Roboto and MaterialIcons fonts; the test aliases Roboto as monospace. Their same-path fixture avoids the SDK-only font's missing rename-arrow glyph. Rename identity is tested separately. No live GitLab account, physical device or store validation is claimed.

Regenerate with LABFOX_RANGE_CAPTURE=<absolute-output-directory> and FLUTTER_ROOT=<Flutter-SDK-directory>, running mr_multiline_discussion_composer_test.dart with the filter "synthetic range composer capture".

| Layout | Light | Dark |
|---|---|---|
| Mobile, 390 × 844 | [Capture](images/mr-multiline-discussions/composer-390-light.png) | [Capture](images/mr-multiline-discussions/composer-390-dark.png) |
| Desktop, 1200 × 900 | [Capture](images/mr-multiline-discussions/composer-1200-light.png) | [Capture](images/mr-multiline-discussions/composer-1200-dark.png) |

References: [GitLab multiline parameters](https://docs.gitlab.com/api/discussions/#parameters-for-multiline-comments), [line codes](https://docs.gitlab.com/api/discussions/#line-code), [original context](mr-discussion-context.md) and [positioned API](mr-positioned-discussions.md). No upstream implementation code was copied.

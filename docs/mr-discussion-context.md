# Original MR discussion context

Positioned notes offer **View original diff** inside the conversation. The panel reads the original version and focuses the containing hunks. Each commented line has an icon, border and localized selected accessibility label. Single-line notes keep their existing marker. Multiline notes display an inclusive signed endpoint summary: minus for old-side coordinates and plus for new-side coordinates. Opening, closing, resizing and changing theme preserve the current top-level comment draft.

The context reader matches all three original commit SHAs and both old/new paths against exactly one available file. A single-line note requires its exact original visible coordinates. A multiline note instead resolves its own start/end line codes and side metadata, without substituting a legacy single-line anchor or current MR files. Complete range endpoints can be resolved when the optional endpoint or top-level line numbers are absent. Supplied endpoint numbers must agree with the line code and visible coordinates.

GitLab line codes include a SHA1 filename hash and the original raw old/new diff counters. The filename uses the new path, including for renamed files. An added or removed line retains the opposite raw counter in its code even though that counter is not a visible coordinate on that row. The independently implemented matcher uses the existing licensed `crypto` package to verify that identity. Same-side ranges mark inclusive visible lines on that side; forward mixed-side ranges mark the available interval between the exact endpoints in unified-diff order. Opposite-side lines in a same-side range are not marked.

Every covered hunk must contain the declared number of old and new lines. A range may span adjacent complete hunks only if both original counters continue without a gap. Missing text, malformed or oversized counters, wrong filename hashes, mismatched side/coordinates, reversed endpoints, duplicate identities and omitted spans remain unavailable. The viewer never unfolds missing blob content, substitutes a newer version, guesses among duplicates or creates a marker for a foreign line. Unsupported range metadata does not dispatch a version read or fall back to a single-line preview.

Version search reads one page at a time. **Look for older versions** explicitly continues the search; failures retain the cursor for retry. Initial read failures provide a read-only retry. The reader sends no comment, suggestion, approval, resolution or merge write. Account and MR replacement reset expanded panels with the conversation. Repository-session observation clears old context during reload, cancels undispatched follow-up reads and isolates late results/errors. A selected snapshot with changed version/SHA identity becomes a typed failure.

## Supported and unavailable contexts

Single-line text positions and complete multiline text ranges require a matching available original snapshot. Missing, collapsed, too-large, uncollected, ambiguous or unmatched data is unavailable. Image, file and unfamiliar position types retain model metadata but have no text preview. Ranges crossing omitted context and reverse mixed-side endpoints are deliberately unavailable; this slice does not fetch full file blobs or reinterpret their ordering. Multiline positioned thread creation remains separate. Existing single-line creation and single/batch suggestion application remain unchanged.

## Verification and captures

Test-first evidence includes missing range state/viewer support, optional-coordinate failures and oversized endpoint/hunk counter failures before fixes. Controller tests cover inclusive old/new/context/mixed ranges, renamed path identity, optional coordinates, zero opposite counters, uniqueness, ordering, complete and adjacent hunks, omitted spans, explicit older-page reads and session cancellation. Shared viewer tests cover per-line accessible markers, duplicate/foreign members and focused versus full context. Existing single-line reader/component regressions pass.

Widget tests cover five locales at 320, 800 and 1200 logical pixels in both themes, retained drafts across resize/theme, MR replacement and a compact window with keyboard insets and doubled text. These four visually checked captures use dummy data and SDK fonts in Flutter widget tests; their fixture has identical old/new paths because the SDK-only font has no rename-arrow glyph. Rename matching is covered by controller/widget tests. No live GitLab account, physical-device or store validation is claimed.

Regenerate with `LABFOX_MULTILINE_CAPTURE=<absolute-output-directory>` and `FLUTTER_ROOT=<Flutter-SDK-directory>`, running `mr_discussion_multiline_context_test.dart` with the name filter `synthetic multiline context capture`.

| Layout | Light | Dark |
|---|---|---|
| Mobile, 390 × 844 | [Capture](images/mr-multiline-context/context-390-light.png) | [Capture](images/mr-multiline-context/context-390-dark.png) |
| Desktop, 1200 × 900 | [Capture](images/mr-multiline-context/context-1200-light.png) | [Capture](images/mr-multiline-context/context-1200-dark.png) |

References: [GitLab multiline fields](https://docs.gitlab.com/api/discussions/#parameters-for-multiline-comments), [line-code identity](https://docs.gitlab.com/api/discussions/#line-code). The upstream [filename selection](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/diff/file.rb) and [raw counter semantics](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/diff/parser.rb) clarify endpoint matching; no implementation code was copied.

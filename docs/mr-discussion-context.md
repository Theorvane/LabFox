# Original MR discussion context

Positioned notes offer **View original diff** inside the conversation. The panel
reads the original version and focuses the containing hunk, marking the commented
line with an icon and a localized accessibility label. Opening, closing, resizing
and changing theme preserve the current top-level comment draft.

The context reader matches all three original commit SHAs, both old/new paths,
and the exact text coordinates. Added, deleted and context lines retain their
separate sides; context lines must match both numbers. It never substitutes the
current MR files or chooses among ambiguous file/line matches.

Version search reads one page at a time. **Look for older versions** explicitly
continues the search; failures retain the cursor for retry. Initial read failures
provide a read-only retry. No note, approval, resolution or merge write is sent by
the context reader.

Account and MR replacement reset expanded panels with the conversation. The
reader observes its repository session, clears old context during reload, prevents
follow-up snapshot dispatch after cancellation, and ignores late page/detail
successes and errors. Closing an unused panel disposes its reader. If a selected
snapshot changes identity or SHA metadata during the read, the result is a typed
failure rather than a guessed location.

## Supported and unavailable contexts

This slice previews single-line text positions with complete version/path/line
metadata and a matching available original snapshot. Missing, collapsed, too-large,
uncollected, ambiguous or unmatched data is shown as unavailable. Explicit older
pages are offered only while searching for the original version.

Multiline, image, file and unfamiliar position types remain preserved by the
models but have no preview in this slice. Creating positioned threads and applying
suggestions remain separate features. No live GitLab or physical-device validation
is claimed. The four checked captures use synthetic component data and bundled
test fonts, including a Roboto alias for the test environment's monospace family.

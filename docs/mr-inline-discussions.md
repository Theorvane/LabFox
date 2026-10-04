# Inline MR discussions

The MR Changes route reads the latest diff-version page and its first version's exact unified snapshot. It displays that version's ID and shared file cards, while commit Changes stays read-only. No current-diff fallback or eager older-version scan is used. Original SHA triplets and selected snapshot IDs must agree; unknown collections, uncollected versions and sparse metadata remain unavailable.

## Selection and composition

Only original parsed lines in an unambiguous file can offer the localized discussion action. Added/deleted/context lines retain their separate old/new coordinates. Foreign line/file objects, duplicate paths or coordinates, binary/omitted/collapsed/too-large files cannot create writable positions. Eligible positions are indexed once per snapshot so each rendered action performs a constant-time lookup.

Select one line, or select a first line and explicitly choose a later range end, write Markdown and start its discussion. See [multiline selection](mr-multiline-discussions.md) for endpoint and available-span rules. The exact original paths, SHAs, line coordinates and nonempty Markdown pass through the repository to the validated API. The selected line or inclusive range remains marked with a non-color accessibility indicator. Selection and unsent draft survive resize and theme changes. Explicit cancel clears them; account or MR replacement resets the composer.

Below 600px, the composer occupies a scrollable pane below the diff. At 600px and above, it sits beside the diff in the same feature code. Editing remains bounded on desktop and scrolls within the allocated pane on small/keyboard-constrained viewports. All controls, messages and progress feedback come from the five localization delegates. Version numbers use intl.

## Writes and uncertain outcomes

Positioned creation shares the existing MR discussion controller reservation with root comments, replies and resolution. The snapshot position is checked both before reserving and immediately before dispatch. Busy controls prevent duplicate submission, editing, selection changes, dismissal and back navigation. Account changes before dispatch cancel the old request; already dispatched server writes cannot be undone. Late old-session successes/errors cannot clear a new draft, refresh new-account data or show a current-account success message.

Confirmed current-session success clears the draft, refreshes authoritative discussion page one, and emits only the existing sanitized comment event. The API disables redirect and OAuth replay and confirms the created thread's original anchor.

After a failed or unconfirmed creation, keep the draft and require an explicit discussion refresh before resubmission. The previous write may have reached GitLab. Show the refreshed user-note bodies that exactly match this line or complete range position, with explicit older-page inspection and cursor-preserving retry. No-match wording applies only to the loaded pages, not to unread pages or the whole MR. The user can inspect accepted content before deciding whether another submission is appropriate; the application never retries the write automatically. Recovery guidance resets when a new discussion is selected.

## Evidence and remaining scope

Tests use synthetic diff snapshots, discussions, dummy tokens and repository/Dio fakes. Both original sides, shared reservations, forged-position rejection, pre-dispatch cancellation, late completions, read/write retry, five locales and narrow/compact/wide light/dark layouts are covered. Four synthetic component captures show the composer with bundled Roboto test fonts (also aliased for the test monospace family); no font dependency or product asset was added.

No live GitLab session or physical device validation is claimed. Original multiline context and positioned creation are available; single and batch suggestion application use their separate confirmation/recovery flows.

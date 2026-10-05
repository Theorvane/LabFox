# Private inline MR draft creation

Issue #616 adds private draft creation to the existing MR changes screen.
Select one displayed text line, or use the existing same-file forward range
selection, then choose **Save private inline note**. A separate modal shows the
original version, old/new paths, and line or range coordinates. Its private
input starts empty; the public discussion composer and its unsent text remain
available after dismissal or a successful private save.

The controller shares the discussion command/pagination reservation. Before
one existing `createDraftNote` request it refreshes the MR identity and the
latest authoritative diff version. The original SHA triplet, version ID,
paths, valid range and selected parsed text must still match. Missing,
ambiguous, binary, omitted, collapsed or oversized positions remain ineligible.
There is no current-diff fallback, guessed anchor or automatic reanchoring.
The selection fingerprint is immutable even though parsed diff lists are
mutable. A lifecycle token detects additional refreshes while the snapshot is
already loading.

Account, client, draft/detail/comment/diff repository, snapshot and origin-view
changes isolate the command. Intentional detail/diff refreshes keep the dialog
mounted. A changed loaded selection discards private input and staged inspection
rows and requires closing the obsolete dialog. Disposal checks the origin
signal before reading providers from a deactivated element.

The existing draft endpoint sends exact Markdown and text position with no
redirect, auth replay or automatic retry. A returned note must confirm author,
global MR ID, exact body and semantic position; multiline response endpoints
may omit optional counters but must retain matching type and line code.
No public comment, publication, approval, merge or analytics event is sent.

After a dispatched failure or obsolete outcome the existing same-account
in-memory uncertainty gate applies to private writes. Recovery waits for the
actual request to settle and reads all private pages. The dialog requires
visible inspection and explicit new consent before a manual save. Matching
text or coordinates cannot identify which create attempt succeeded. An
uncertain bulk publication still requires the separate two-sided publication
recovery flow. A final current-session check after page validation prevents a queued client
replacement from clearing uncertainty or returning old private rows. No durable
or exactly-once guarantee is implied.

The fresh diff check is a preflight check: another client can change the MR
between the final read and server-side creation. GitLab's position validation
remains authoritative; this flow does not claim an atomic conditional write.
Image/file positions, commit-associated/reply drafts, single-note publication
and reviewer-state controls remain separate slices. MW-07 remains in progress.

## Validation

Test-first controller and widget regressions cover fresh changed diffs,
reservation, unconfirmed acknowledgements, immutable selection, snapshot
refresh cancellation, session/view replacement and late success/error,
unchanged public input, explicit inspection and read-only retry. Widget tests
exercise five locales at 390/800/1200 widths in both themes, plus large text and
keyboard constraints. Synthetic rendered captures show multiline composition
and uncertain-save inspection at all three widths in both themes. Fixtures use
fake Markdown, paths, accounts and credentials; no live GitLab session is
claimed by these tests.

Official API reference: https://docs.gitlab.com/api/draft_notes/

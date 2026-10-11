# Captured original MR review snapshots

`MrOriginalReviewController` routes a target project, MR IID, known global MR ID and fixed commit SHA through the captured `MergeRequestsRepository.originalCommitContext`. It binds its currency guard to the generation, authenticated account and repository future. Reload/replacement/disposal ends the old session. Every await is checked; obsolete results and failures are discarded, while current typed failures remain visible. Invalid origins and signed-out sessions dispatch no reads.

`MrOriginalReviewSnapshot` copies the literal file collection and validates each file before exposing immutable hunks. Duplicate old or new paths are unselectable. Position lookup requires the actual captured row object, so fabricated coordinates or rows from another snapshot cannot become a selection. Single-line and multiline positions retain exact paths and literal counters; multiline matching uses the strict whole-file validator and existing uniqueness/contiguity rules. Path hashes are captured once per file. Immutable returned ranges contain captured row objects, without replacing them with reparsed rows.

## Supported original references

This slice supports one explicitly reported, canonical, distinct parent only. The selected fixed commit is the head; that parent is both base and start. Unknown parents, root commits and multiple parents remain readable but unselectable. No blank reference, empty-tree hash, MR-wide diff reference or branch-name substitute is invented.

This is an independently implemented interpretation of GitLab's original commit convention, not a new field returned by the REST API. The [Commit model](https://github.com/gitlabhq/gitlabhq/blob/master/app/models/commit.rb) constructs original diff refs using the parent (or repository blank ref for root) and selected head. [Git commit handling](https://github.com/gitlabhq/gitlabhq/blob/master/lib/gitlab/git/commit.rb) reads the first parent and describes the original diff as the first-parent diff. [DiffRefs](https://github.com/gitlabhq/gitlabhq/blob/master/lib/gitlab/diff/diff_refs.rb) defaults start to base. This slice conservatively avoids root and multi-parent choices. No server implementation was copied.

The [Draft Notes API](https://docs.gitlab.com/api/draft_notes/) documents commit association and positioned drafts, but its generic MR position description does not establish every original-commit case. No live GitLab version or self-hosted compatibility guarantee is claimed. The local snapshot is not a write authorization or atomic server snapshot; the guarded private-save workflow below separately confirms parent availability and original references.

## Captured selections

`MrOriginalReviewSelection` stores the canonical position, MR global/per-project identity, target/source project and branches, plus the entire literal file DTO. Reconfirmation rejects changed origin, commit/parent references, metadata or raw text even when the selected row itself is unchanged. An unrelated MR title change does not invalidate a selection. The selection fingerprint is resource-bound; account/provider/session currency remains the controller and write reservation's responsibility.

## Guarded private saves

`MrDiscussionsController.savePendingCommitNote` accepts the captured original query and canonical position. It shares the discussion write/pagination reservation and captures the authenticated account, client, repositories, detail and original snapshot session. A fresh original snapshot must match the complete selection fingerprint. Fresh private detail must retain the global MR ID and target project. The same captured client reads the fixed parent in the target project before one private `createCommit` call. Every await and the final dispatch boundary check currency; reload, account/repository replacement and disposal cancel obsolete outcomes. View guards are checked at await boundaries.

The acknowledgement must retain the author, global MR ID, exact Markdown, selected commit, canonical position and unpublished/non-resolution metadata. An uncertain dispatched write blocks another save until explicit read-only inspection waits for the actual request to settle and traverses all advertised private-note pages. Cancellation cannot undo an already dispatched server write. There is no automatic replay, public fallback, publication or analytics emission.

These sequential reads are not an atomic server snapshot or a live-version compatibility guarantee. Root, unknown-parent and multiple-parent commits remain unselectable. The original-commit list, literal-row renderer and localized private-save UI remain the next connection; this controller command does not expose a user action yet.

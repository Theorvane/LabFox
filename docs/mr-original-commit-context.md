# Captured original MR commit context

`MergeRequestsRepository.originalCommitContext` combines existing strict readers through the same captured account client. A caller supplies the target project, per-project IID, known global MR ID, fixed full lowercase commit SHA and origin/session currency guard.

The reader loads MR identity and all advertised commit membership pages before fetching the selected commit and its literal original diff from the reported target project. It then reloads MR identity and all advertised membership pages. Changed source/target project or branch metadata and missing selected membership fail with a typed conflict; mismatched identity and contradictory known ordered parent lists fail with sanitized server errors. Fork source metadata is retained without routing reads to the fork or another account.

Target commit parent metadata remains authoritative: unknown stays unknown, an empty list stays a reported root, and multiple parents retain their order. Membership does not fill missing target parents. Literal diff text, paths and omission flags remain untouched; the returned file list is immutable. Advertised pagination is exhausted without partial results.

Every await is guarded. An expired captured origin returns null and suppresses obsolete typed failures without dispatching later reads. Current failures remain typed. The caller must recheck currency after awaiting. Guards do not cancel dispatched reads or account authentication recovery.

These sequential reads are not an atomic server snapshot or private-write eligibility proof. This aggregate does not select an original parent, derive original diff references, establish literal line coordinates or validate complete hunks. The controller, guarded literal selection and private-save reservation/recovery UI remain follow-ups. No write, persistence, dependency, generated model or localization change is included.

The regression suite uses real injected API adapters to cover target routing, forks, unknown/root/ordered parents, origin and membership changes, advertised traversal, immutable omitted diffs, invalid inputs and obsolete outcomes at all six read phases. No live GitLab or device validation is claimed.

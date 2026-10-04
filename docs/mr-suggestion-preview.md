# MR suggestion previews

User notes with a server-provided suggestion collection show each suggestion in its original order. The conversation uses the existing account-bound discussion controller; opening a preview makes no additional read, mutation or analytics event. System notes are excluded. Omitted/null and empty collections produce no invented preview.

Each preview displays an Intl-formatted global suggestion ID and the inclusive original line range when both coordinates are valid. Missing or invalid ranges remain unavailable. Applied status and patch applicability are independent three-state labels. Legacy `appliable` and documented `applicable` metadata use the DTO getter; unknown or contradictory directly constructed values remain unknown. Applicability is not a permission check.

Opening a preview exposes separately labelled original and suggested code. Content is selectable literal text, with exact whitespace and newlines and no Markdown/HTML interpretation. Null content is unavailable; an empty string is explicitly empty, preserving insertion/deletion semantics. Long lines scroll horizontally and large content scrolls vertically within bounded panes. The same layout serves mobile, tablet and desktop inside the conversation's existing width cap.

Preview expansion and the conversation draft survive viewport/theme changes. The existing conversation key resets state when account/resource changes; per-note suggestion keys reset expansion when server metadata changes. Collapsing a preview performs no write and does not submit or clear drafts.

There is no apply or batch control in this slice. Suggestion application must have a separate reviewed write path, current-session checks, explicit confirmation and recovery after uncertain writes. Multiline context/creation remain separate work.

Tests use synthetic discussions and dummy credentials. Optional synthetic captures load SDK-bundled fonts for readability; they are widget renderings, not live GitLab or physical-device evidence. English source and all five localized delegates are generated together.

References: [GitLab suggestion review](https://docs.gitlab.com/user/project/merge_requests/reviews/suggestions/) and [Suggest Changes API](https://docs.gitlab.com/api/suggestions/).

# MR discussion diff positions

GitLab's [Discussions API](https://docs.gitlab.com/api/discussions/#list-all-merge-request-discussion-items)
returns a `position` on diff notes. `Note.position` preserves it as a generated
`DiffNotePosition`; overview comments and replies may have no position.

## Preserved metadata

- The `base_sha`, `start_sha`, and `head_sha` identify the original diff version.
- `old_path` and `new_path` retain both sides of a rename.
- Text positions keep separate `old_line` and `new_line` values. Added lines may
  have only the new line; deleted lines may have only the old line. Context lines
  may have different numbers on each side.
- A multiline `line_range` keeps its start/end line codes, side types, and
  old/new line numbers independently.
- Image positions keep `width`, `height`, `x`, and `y` without inventing text
  lines. File positions and unfamiliar position types remain identifiable.

All metadata fields are nullable. Missing legacy fields remain unknown;
readers do not substitute the current MR version, line zero, or a default side.
Sparse metadata is preserved but is not sufficient authorization or context for
creating a new positioned discussion.

## API boundary

MR discussion reads, reply responses, and resolution responses validate supplied
position values before generated parsing. Line numbers and image dimensions must
be positive integers; fractional values must not be truncated into another line.
Image coordinates must be finite, nonnegative numbers. Present nested ranges and
endpoints must be objects, and present identity/path/type/code fields must be
strings. Unknown position types remain compatible; absent values remain nullable.

Malformed successful responses become the existing sanitized domain failures.
HTTP failures retain their existing typed status mapping before payload parsing.
No payload, file path, or source content is included in parsing error messages.

## Remaining integration

This foundation does not attach comments to the current diff or create positioned
threads. Inline rendering must match the original version and file/line metadata,
including renamed paths and old/new sides. A stale position must not be silently
attached to a newer diff. Creating a thread must use an authoritative version and
validate its writable text position separately. Suggestions remain a separate
feature.

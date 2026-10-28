# MR suggestion metadata

`Note.suggestions` preserves the server-provided suggestion collection. The generated Freezed `Suggestion` DTO retains its global suggestion ID, original/replacement content, original inclusive line range, applicability fields and applied status. IDs do not identify notes, MR IIDs or diff versions.

## Omission and applicability

An omitted/null suggestion collection remains unknown; an explicit empty list stays empty. Missing legacy coordinates, content and boolean state remain null. Empty original/replacement strings remain present: they can represent insertion or deletion. Original whitespace and newlines are never normalized. Nested note/discussion collections are immutable through their exposed DTO lists.

The official Discussions API example uses `appliable`, while the Suggest Changes API documents `applicable`. Preserve both independently. `patchApplicable` reads the known spelling or their agreed value; a direct model with conflicting values yields unknown. This describes patch applicability only, not current-user permission, and is independent of `applied`. Future UI must verify the current loaded state and let GitLab enforce write permission.

## MR API boundary validation

Discussion reads, reply responses, resolution responses and positioned creation validate suggestion collections before generated deserialization. IDs must be positive integral numbers and unique throughout each decoded response. Provided line coordinates must be positive integers; a complete range cannot be reversed. Provided content must be strings, and provided status flags must be booleans. Conflicting applicability spellings are a malformed response, never a choice of whichever enables an action.

HTTP status mapping precedes parsing. Malformed suggestion metadata becomes the existing sanitized domain error for that response context; source text, identifiers and parsing details are not exposed. Numeric validation avoids generated `toInt()` truncation directing a future action at another suggestion or line. Sparse valid metadata remains available as unknown fields instead of fabricated defaults.

This slice adds no suggestion mutation endpoint, preview control, apply button or automatic repository change. It supplies the read foundation for those later slices. Multiline context/creation and suggestion presentation/application remain separate work. Tests use documented synthetic payloads and dummy credentials; no live GitLab/device validation is claimed.

References: [Discussions API](https://docs.gitlab.com/api/discussions/#list-merge-request-discussion-items) and [Suggest Changes API](https://docs.gitlab.com/api/suggestions/).

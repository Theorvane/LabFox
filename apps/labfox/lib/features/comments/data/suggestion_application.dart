import 'package:gitlab_models/gitlab_models.dart';

/// Patch eligibility is not a permission check: GitLab enforces write access.
bool canApplySuggestion(Note note, Suggestion suggestion) =>
    !note.isSystem &&
    note.type == 'DiffNote' &&
    (note.position == null || note.position!.positionType == 'text') &&
    suggestion.id > 0 &&
    suggestion.applied == false &&
    suggestion.patchApplicable == true &&
    suggestion.fromContent != null &&
    suggestion.toContent != null &&
    suggestion.fromLine != null &&
    suggestion.toLine != null &&
    suggestion.fromLine! > 0 &&
    suggestion.toLine! >= suggestion.fromLine!;

bool containsApplicableSuggestion(
  List<Discussion> groups, {
  required String discussionId,
  required Note note,
  required Suggestion suggestion,
}) {
  if (!canApplySuggestion(note, suggestion)) return false;
  var count = 0, matching = false;
  for (final group in groups) {
    for (final currentNote in group.notes) {
      for (final current in currentNote.suggestions ?? <Suggestion>[]) {
        if (current.id != suggestion.id) continue;
        count++;
        if (group.id == discussionId &&
            currentNote.id == note.id &&
            currentNote.type == note.type &&
            currentNote.position == note.position &&
            canApplySuggestion(currentNote, current) &&
            current.fromLine == suggestion.fromLine &&
            current.toLine == suggestion.toLine &&
            current.fromContent == suggestion.fromContent &&
            current.toContent == suggestion.toContent) {
          matching = true;
        }
      }
    }
  }
  return count == 1 && matching;
}

bool confirmsAppliedSuggestion(Suggestion returned, Suggestion expected) =>
    returned.id == expected.id &&
    returned.applied == true &&
    (returned.fromLine == null || returned.fromLine == expected.fromLine) &&
    (returned.toLine == null || returned.toLine == expected.toLine) &&
    (returned.fromContent == null ||
        returned.fromContent == expected.fromContent) &&
    (returned.toContent == null || returned.toContent == expected.toContent);

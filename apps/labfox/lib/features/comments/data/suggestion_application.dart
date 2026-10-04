import 'package:gitlab_models/gitlab_models.dart';

typedef SuggestionTarget = ({
  String discussionId,
  Note note,
  Suggestion suggestion,
});

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

List<SuggestionTarget> applicableSuggestionTargets(List<Discussion> groups) {
  final counts = <int, int>{};
  for (final group in groups) {
    for (final note in group.notes) {
      for (final suggestion in note.suggestions ?? <Suggestion>[]) {
        counts.update(suggestion.id, (v) => v + 1, ifAbsent: () => 1);
      }
    }
  }
  return List<SuggestionTarget>.unmodifiable([
    for (final group in groups)
      for (final note in group.notes)
        for (final suggestion in note.suggestions ?? <Suggestion>[])
          if (counts[suggestion.id] == 1 &&
              canApplySuggestion(note, suggestion))
            (discussionId: group.id, note: note, suggestion: suggestion),
  ]);
}

bool containsApplicableSuggestionTargets(
  List<Discussion> groups,
  List<SuggestionTarget> targets,
) =>
    targets.length >= 2 &&
    targets.map((t) => t.suggestion.id).toSet().length == targets.length &&
    targets.every(
      (t) => containsApplicableSuggestion(
        groups,
        discussionId: t.discussionId,
        note: t.note,
        suggestion: t.suggestion,
      ),
    );

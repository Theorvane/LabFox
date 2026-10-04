import 'package:gitlab_models/gitlab_models.dart';

/// Unknown metadata must not claim a discussion is resolved or actionable.
bool? discussionResolution(Discussion discussion) {
  final notes = discussion.notes.where((note) => note.resolvable == true);
  if (notes.any((note) => note.resolved == false)) return false;
  if (notes.isNotEmpty && notes.every((note) => note.resolved == true)) {
    return true;
  }
  return null;
}

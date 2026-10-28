import 'package:freezed_annotation/freezed_annotation.dart';

import 'note.dart';

part 'discussion.freezed.dart';
part 'discussion.g.dart';

/// A server-defined discussion group, including its replies in server order.
@freezed
abstract class Discussion with _$Discussion {
  const factory Discussion({
    required String id,
    @JsonKey(name: 'individual_note') required bool individualNote,
    required List<Note> notes,
  }) = _Discussion;

  factory Discussion.fromJson(Map<String, dynamic> json) =>
      _$DiscussionFromJson(json);
}

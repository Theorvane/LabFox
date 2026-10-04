import 'package:freezed_annotation/freezed_annotation.dart';

part 'diff_note_position.freezed.dart';
part 'diff_note_position.g.dart';

/// The original diff version and coordinates of a positioned MR note.
///
/// Omitted fields stay unknown. A position can describe text, an image, a file,
/// or a future GitLab position type; readers must not assume text coordinates.
@freezed
abstract class DiffNotePosition with _$DiffNotePosition {
  const factory DiffNotePosition({
    @JsonKey(name: 'base_sha') String? baseSha,
    @JsonKey(name: 'start_sha') String? startSha,
    @JsonKey(name: 'head_sha') String? headSha,
    @JsonKey(name: 'old_path') String? oldPath,
    @JsonKey(name: 'new_path') String? newPath,
    @JsonKey(name: 'position_type') String? positionType,
    @JsonKey(name: 'old_line') int? oldLine,
    @JsonKey(name: 'new_line') int? newLine,
    @JsonKey(name: 'line_range') DiffNoteLineRange? lineRange,
    int? width,
    int? height,
    double? x,
    double? y,
  }) = _DiffNotePosition;

  factory DiffNotePosition.fromJson(Map<String, dynamic> json) =>
      _$DiffNotePositionFromJson(json);
}

/// Multiline endpoints retain their own side and line code from GitLab.
@freezed
abstract class DiffNoteLineRange with _$DiffNoteLineRange {
  const factory DiffNoteLineRange({
    DiffNoteRangeEndpoint? start,
    DiffNoteRangeEndpoint? end,
  }) = _DiffNoteLineRange;

  factory DiffNoteLineRange.fromJson(Map<String, dynamic> json) =>
      _$DiffNoteLineRangeFromJson(json);
}

@freezed
abstract class DiffNoteRangeEndpoint with _$DiffNoteRangeEndpoint {
  const factory DiffNoteRangeEndpoint({
    @JsonKey(name: 'line_code') String? lineCode,
    String? type,
    @JsonKey(name: 'old_line') int? oldLine,
    @JsonKey(name: 'new_line') int? newLine,
  }) = _DiffNoteRangeEndpoint;

  factory DiffNoteRangeEndpoint.fromJson(Map<String, dynamic> json) =>
      _$DiffNoteRangeEndpointFromJson(json);
}

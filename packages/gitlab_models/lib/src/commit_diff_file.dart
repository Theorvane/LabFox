import 'package:freezed_annotation/freezed_annotation.dart';

part 'commit_diff_file.freezed.dart';
part 'commit_diff_file.g.dart';

/// Literal file metadata from an original commit diff, before parsing/rendering.
/// Nullable text and omission flags remain unknown when GitLab omits them.
/// This is not evidence of complete file coverage or write-safe coordinates.
@freezed
abstract class CommitDiffFile with _$CommitDiffFile {
  const factory CommitDiffFile({
    @JsonKey(name: 'old_path') required String oldPath,
    @JsonKey(name: 'new_path') required String newPath,
    @JsonKey(name: 'new_file') required bool isNew,
    @JsonKey(name: 'deleted_file') required bool isDeleted,
    @JsonKey(name: 'renamed_file') required bool isRenamed,
    String? diff,
    @JsonKey(name: 'a_mode') String? oldMode,
    @JsonKey(name: 'b_mode') String? newMode,
    @JsonKey(name: 'collapsed') bool? isCollapsed,
    @JsonKey(name: 'too_large') bool? isTooLarge,
    @JsonKey(name: 'generated_file') bool? isGenerated,
  }) = _CommitDiffFile;

  factory CommitDiffFile.fromJson(Map<String, dynamic> json) =>
      _$CommitDiffFileFromJson(json);
}

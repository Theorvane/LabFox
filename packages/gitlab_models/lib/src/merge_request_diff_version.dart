import 'package:freezed_annotation/freezed_annotation.dart';

part 'merge_request_diff_version.freezed.dart';
part 'merge_request_diff_version.g.dart';

/// One MR diff version, optionally including its original file snapshot.
///
/// Missing SHAs remain unknown. An omitted file collection differs from an
/// explicitly empty snapshot; callers must not replace either with current diffs.
@freezed
abstract class MergeRequestDiffVersion with _$MergeRequestDiffVersion {
  const factory MergeRequestDiffVersion({
    required int id,
    @JsonKey(name: 'base_commit_sha') String? baseCommitSha,
    @JsonKey(name: 'start_commit_sha') String? startCommitSha,
    @JsonKey(name: 'head_commit_sha') String? headCommitSha,
    @JsonKey(name: 'merge_request_id') int? mergeRequestId,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    String? state,
    @JsonKey(name: 'real_size') String? realSize,
    @JsonKey(name: 'patch_id_sha') String? patchIdSha,
    @JsonKey(name: 'diffs') List<MergeRequestVersionFile>? files,
  }) = _MergeRequestDiffVersion;

  factory MergeRequestDiffVersion.fromJson(Map<String, dynamic> json) =>
      _$MergeRequestDiffVersionFromJson(json);
}

/// Raw file metadata for the selected diff version, before diff rendering.
///
/// Nullable text and omission flags retain incomplete/truncated response state
/// instead of labelling every absent diff as a binary file.
@freezed
abstract class MergeRequestVersionFile with _$MergeRequestVersionFile {
  const factory MergeRequestVersionFile({
    @JsonKey(name: 'old_path') required String oldPath,
    @JsonKey(name: 'new_path') required String newPath,
    String? diff,
    @JsonKey(name: 'a_mode') String? oldMode,
    @JsonKey(name: 'b_mode') String? newMode,
    @JsonKey(name: 'new_file') bool? isNew,
    @JsonKey(name: 'deleted_file') bool? isDeleted,
    @JsonKey(name: 'renamed_file') bool? isRenamed,
    @JsonKey(name: 'collapsed') bool? isCollapsed,
    @JsonKey(name: 'too_large') bool? isTooLarge,
    @JsonKey(name: 'generated_file') bool? isGenerated,
  }) = _MergeRequestVersionFile;

  factory MergeRequestVersionFile.fromJson(Map<String, dynamic> json) =>
      _$MergeRequestVersionFileFromJson(json);
}

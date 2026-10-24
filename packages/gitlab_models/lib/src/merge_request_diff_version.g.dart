// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'merge_request_diff_version.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MergeRequestDiffVersion _$MergeRequestDiffVersionFromJson(
  Map<String, dynamic> json,
) => _MergeRequestDiffVersion(
  id: (json['id'] as num).toInt(),
  baseCommitSha: json['base_commit_sha'] as String?,
  startCommitSha: json['start_commit_sha'] as String?,
  headCommitSha: json['head_commit_sha'] as String?,
  mergeRequestId: (json['merge_request_id'] as num?)?.toInt(),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  state: json['state'] as String?,
  realSize: json['real_size'] as String?,
  patchIdSha: json['patch_id_sha'] as String?,
  files: (json['diffs'] as List<dynamic>?)
      ?.map((e) => MergeRequestVersionFile.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MergeRequestDiffVersionToJson(
  _MergeRequestDiffVersion instance,
) => <String, dynamic>{
  'id': instance.id,
  'base_commit_sha': instance.baseCommitSha,
  'start_commit_sha': instance.startCommitSha,
  'head_commit_sha': instance.headCommitSha,
  'merge_request_id': instance.mergeRequestId,
  'created_at': instance.createdAt?.toIso8601String(),
  'state': instance.state,
  'real_size': instance.realSize,
  'patch_id_sha': instance.patchIdSha,
  'diffs': instance.files?.map((e) => e.toJson()).toList(),
};

_MergeRequestVersionFile _$MergeRequestVersionFileFromJson(
  Map<String, dynamic> json,
) => _MergeRequestVersionFile(
  oldPath: json['old_path'] as String,
  newPath: json['new_path'] as String,
  diff: json['diff'] as String?,
  oldMode: json['a_mode'] as String?,
  newMode: json['b_mode'] as String?,
  isNew: json['new_file'] as bool?,
  isDeleted: json['deleted_file'] as bool?,
  isRenamed: json['renamed_file'] as bool?,
  isCollapsed: json['collapsed'] as bool?,
  isTooLarge: json['too_large'] as bool?,
  isGenerated: json['generated_file'] as bool?,
);

Map<String, dynamic> _$MergeRequestVersionFileToJson(
  _MergeRequestVersionFile instance,
) => <String, dynamic>{
  'old_path': instance.oldPath,
  'new_path': instance.newPath,
  'diff': instance.diff,
  'a_mode': instance.oldMode,
  'b_mode': instance.newMode,
  'new_file': instance.isNew,
  'deleted_file': instance.isDeleted,
  'renamed_file': instance.isRenamed,
  'collapsed': instance.isCollapsed,
  'too_large': instance.isTooLarge,
  'generated_file': instance.isGenerated,
};

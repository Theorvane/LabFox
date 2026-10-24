// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commit_diff_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CommitDiffFile _$CommitDiffFileFromJson(Map<String, dynamic> json) =>
    _CommitDiffFile(
      oldPath: json['old_path'] as String,
      newPath: json['new_path'] as String,
      isNew: json['new_file'] as bool,
      isDeleted: json['deleted_file'] as bool,
      isRenamed: json['renamed_file'] as bool,
      diff: json['diff'] as String?,
      oldMode: json['a_mode'] as String?,
      newMode: json['b_mode'] as String?,
      isCollapsed: json['collapsed'] as bool?,
      isTooLarge: json['too_large'] as bool?,
      isGenerated: json['generated_file'] as bool?,
    );

Map<String, dynamic> _$CommitDiffFileToJson(_CommitDiffFile instance) =>
    <String, dynamic>{
      'old_path': instance.oldPath,
      'new_path': instance.newPath,
      'new_file': instance.isNew,
      'deleted_file': instance.isDeleted,
      'renamed_file': instance.isRenamed,
      'diff': instance.diff,
      'a_mode': instance.oldMode,
      'b_mode': instance.newMode,
      'collapsed': instance.isCollapsed,
      'too_large': instance.isTooLarge,
      'generated_file': instance.isGenerated,
    };

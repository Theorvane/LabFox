// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_label.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProjectLabel _$ProjectLabelFromJson(Map<String, dynamic> json) =>
    _ProjectLabel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      color: json['color'] as String,
      textColor: json['text_color'] as String?,
      description: json['description'] as String?,
      openIssuesCount: (json['open_issues_count'] as num?)?.toInt() ?? 0,
      closedIssuesCount: (json['closed_issues_count'] as num?)?.toInt() ?? 0,
      openMergeRequestsCount:
          (json['open_merge_requests_count'] as num?)?.toInt() ?? 0,
      isProjectLabel: json['is_project_label'] as bool? ?? true,
      archived: json['archived'] as bool? ?? false,
    );

Map<String, dynamic> _$ProjectLabelToJson(_ProjectLabel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'color': instance.color,
      'text_color': instance.textColor,
      'description': instance.description,
      'open_issues_count': instance.openIssuesCount,
      'closed_issues_count': instance.closedIssuesCount,
      'open_merge_requests_count': instance.openMergeRequestsCount,
      'is_project_label': instance.isProjectLabel,
      'archived': instance.archived,
    };

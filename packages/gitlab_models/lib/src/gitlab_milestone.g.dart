// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gitlab_milestone.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GitLabMilestone _$GitLabMilestoneFromJson(Map<String, dynamic> json) =>
    _GitLabMilestone(
      id: (json['id'] as num).toInt(),
      iid: (json['iid'] as num).toInt(),
      title: json['title'] as String,
      state: json['state'] as String,
      projectId: (json['project_id'] as num?)?.toInt(),
      groupId: (json['group_id'] as num?)?.toInt(),
      description: json['description'] as String?,
      startDate: json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
      dueDate: json['due_date'] == null
          ? null
          : DateTime.parse(json['due_date'] as String),
      expired: json['expired'] as bool?,
      webUrl: json['web_url'] as String?,
    );

Map<String, dynamic> _$GitLabMilestoneToJson(_GitLabMilestone instance) =>
    <String, dynamic>{
      'id': instance.id,
      'iid': instance.iid,
      'title': instance.title,
      'state': instance.state,
      'project_id': instance.projectId,
      'group_id': instance.groupId,
      'description': instance.description,
      'start_date': instance.startDate?.toIso8601String(),
      'due_date': instance.dueDate?.toIso8601String(),
      'expired': instance.expired,
      'web_url': instance.webUrl,
    };

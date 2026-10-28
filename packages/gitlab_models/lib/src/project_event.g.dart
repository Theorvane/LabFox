// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProjectEvent _$ProjectEventFromJson(Map<String, dynamic> json) =>
    _ProjectEvent(
      id: (json['id'] as num).toInt(),
      projectId: (json['project_id'] as num).toInt(),
      actionName: json['action_name'] as String,
      targetId: (json['target_id'] as num?)?.toInt(),
      targetIid: (json['target_iid'] as num?)?.toInt(),
      targetType: json['target_type'] as String?,
      targetTitle: json['target_title'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      author: json['author'] == null
          ? null
          : EventActor.fromJson(json['author'] as Map<String, dynamic>),
      authorUsername: json['author_username'] as String?,
      pushData: json['push_data'] == null
          ? null
          : EventPushData.fromJson(json['push_data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProjectEventToJson(_ProjectEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'project_id': instance.projectId,
      'action_name': instance.actionName,
      'target_id': instance.targetId,
      'target_iid': instance.targetIid,
      'target_type': instance.targetType,
      'target_title': instance.targetTitle,
      'created_at': instance.createdAt?.toIso8601String(),
      'author': instance.author?.toJson(),
      'author_username': instance.authorUsername,
      'push_data': instance.pushData?.toJson(),
    };

_EventActor _$EventActorFromJson(Map<String, dynamic> json) => _EventActor(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  username: json['username'] as String,
  avatarUrl: json['avatar_url'] as String?,
);

Map<String, dynamic> _$EventActorToJson(_EventActor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'username': instance.username,
      'avatar_url': instance.avatarUrl,
    };

_EventPushData _$EventPushDataFromJson(Map<String, dynamic> json) =>
    _EventPushData(
      commitCount: (json['commit_count'] as num?)?.toInt(),
      refCount: (json['ref_count'] as num?)?.toInt(),
      refType: json['ref_type'] as String?,
      ref: json['ref'] as String?,
      commitTo: json['commit_to'] as String?,
      commitTitle: json['commit_title'] as String?,
    );

Map<String, dynamic> _$EventPushDataToJson(_EventPushData instance) =>
    <String, dynamic>{
      'commit_count': instance.commitCount,
      'ref_count': instance.refCount,
      'ref_type': instance.refType,
      'ref': instance.ref,
      'commit_to': instance.commitTo,
      'commit_title': instance.commitTitle,
    };

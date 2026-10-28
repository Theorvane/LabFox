// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProjectMember _$ProjectMemberFromJson(Map<String, dynamic> json) =>
    _ProjectMember(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      name: json['name'] as String,
      accessLevel: (json['access_level'] as num).toInt(),
      state: json['state'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      webUrl: json['web_url'] as String?,
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
    );

Map<String, dynamic> _$ProjectMemberToJson(_ProjectMember instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'name': instance.name,
      'access_level': instance.accessLevel,
      'state': instance.state,
      'avatar_url': instance.avatarUrl,
      'web_url': instance.webUrl,
      'expires_at': instance.expiresAt?.toIso8601String(),
    };

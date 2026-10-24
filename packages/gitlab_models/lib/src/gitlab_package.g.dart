// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gitlab_package.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GitLabPackage _$GitLabPackageFromJson(Map<String, dynamic> json) =>
    _GitLabPackage(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      packageType: json['package_type'] as String,
      version: json['version'] as String?,
      status: json['status'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      lastDownloadedAt: json['last_downloaded_at'] == null
          ? null
          : DateTime.parse(json['last_downloaded_at'] as String),
    );

Map<String, dynamic> _$GitLabPackageToJson(_GitLabPackage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'package_type': instance.packageType,
      'version': instance.version,
      'status': instance.status,
      'created_at': instance.createdAt?.toIso8601String(),
      'last_downloaded_at': instance.lastDownloadedAt?.toIso8601String(),
    };

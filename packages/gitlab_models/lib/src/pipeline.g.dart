// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pipeline.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Pipeline _$PipelineFromJson(Map<String, dynamic> json) => _Pipeline(
  id: (json['id'] as num).toInt(),
  status: json['status'] as String,
  projectId: (json['project_id'] as num?)?.toInt(),
  ref: json['ref'] as String?,
  sha: json['sha'] as String?,
  source: json['source'] as String?,
  webUrl: json['web_url'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$PipelineToJson(_Pipeline instance) => <String, dynamic>{
  'id': instance.id,
  'status': instance.status,
  'project_id': instance.projectId,
  'ref': instance.ref,
  'sha': instance.sha,
  'source': instance.source,
  'web_url': instance.webUrl,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};

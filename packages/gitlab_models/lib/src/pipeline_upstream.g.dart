// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pipeline_upstream.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PipelineUpstream _$PipelineUpstreamFromJson(Map<String, dynamic> json) =>
    _PipelineUpstream(
      id: json['id'] as String,
      status: json['status'] as String,
      ref: json['ref'] as String?,
      project: json['project'] == null
          ? null
          : PipelineUpstreamProject.fromJson(
              json['project'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$PipelineUpstreamToJson(_PipelineUpstream instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'ref': instance.ref,
      'project': instance.project?.toJson(),
    };

_PipelineUpstreamProject _$PipelineUpstreamProjectFromJson(
  Map<String, dynamic> json,
) => _PipelineUpstreamProject(id: json['id'] as String);

Map<String, dynamic> _$PipelineUpstreamProjectToJson(
  _PipelineUpstreamProject instance,
) => <String, dynamic>{'id': instance.id};

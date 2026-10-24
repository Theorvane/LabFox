// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pipeline_trigger_job.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PipelineTriggerJob _$PipelineTriggerJobFromJson(Map<String, dynamic> json) =>
    _PipelineTriggerJob(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      status: json['status'] as String,
      stage: json['stage'] as String?,
      downstreamPipeline: json['downstream_pipeline'] == null
          ? null
          : Pipeline.fromJson(
              json['downstream_pipeline'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$PipelineTriggerJobToJson(_PipelineTriggerJob instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'status': instance.status,
      'stage': instance.stage,
      'downstream_pipeline': instance.downstreamPipeline?.toJson(),
    };

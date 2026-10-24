// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pipeline_schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PipelineSchedule _$PipelineScheduleFromJson(Map<String, dynamic> json) =>
    _PipelineSchedule(
      id: (json['id'] as num).toInt(),
      description: json['description'] as String,
      ref: json['ref'] as String,
      cron: json['cron'] as String,
      cronTimezone: json['cron_timezone'] as String?,
      active: json['active'] as bool,
      nextRunAt: json['next_run_at'] == null
          ? null
          : DateTime.parse(json['next_run_at'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      lastPipeline: json['last_pipeline'] == null
          ? null
          : ScheduleLastPipeline.fromJson(
              json['last_pipeline'] as Map<String, dynamic>,
            ),
      owner: json['owner'] == null
          ? null
          : ScheduleOwner.fromJson(json['owner'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PipelineScheduleToJson(_PipelineSchedule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'ref': instance.ref,
      'cron': instance.cron,
      'cron_timezone': instance.cronTimezone,
      'active': instance.active,
      'next_run_at': instance.nextRunAt?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'last_pipeline': instance.lastPipeline?.toJson(),
      'owner': instance.owner?.toJson(),
    };

_ScheduleLastPipeline _$ScheduleLastPipelineFromJson(
  Map<String, dynamic> json,
) => _ScheduleLastPipeline(
  id: (json['id'] as num).toInt(),
  status: json['status'] as String?,
  ref: json['ref'] as String?,
  sha: json['sha'] as String?,
);

Map<String, dynamic> _$ScheduleLastPipelineToJson(
  _ScheduleLastPipeline instance,
) => <String, dynamic>{
  'id': instance.id,
  'status': instance.status,
  'ref': instance.ref,
  'sha': instance.sha,
};

_ScheduleOwner _$ScheduleOwnerFromJson(Map<String, dynamic> json) =>
    _ScheduleOwner(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      username: json['username'] as String?,
    );

Map<String, dynamic> _$ScheduleOwnerToJson(_ScheduleOwner instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'username': instance.username,
    };

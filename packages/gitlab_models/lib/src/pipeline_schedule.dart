import 'package:freezed_annotation/freezed_annotation.dart';

part 'pipeline_schedule.freezed.dart';
part 'pipeline_schedule.g.dart';

/// A project pipeline schedule. Variables and inputs are intentionally omitted.
@freezed
abstract class PipelineSchedule with _$PipelineSchedule {
  const factory PipelineSchedule({
    required int id,
    required String description,
    required String ref,
    required String cron,
    @JsonKey(name: 'cron_timezone') String? cronTimezone,
    required bool active,
    @JsonKey(name: 'next_run_at') DateTime? nextRunAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'last_pipeline') ScheduleLastPipeline? lastPipeline,
    ScheduleOwner? owner,
  }) = _PipelineSchedule;

  factory PipelineSchedule.fromJson(Map<String, dynamic> json) =>
      _$PipelineScheduleFromJson(json);
}

@freezed
abstract class ScheduleLastPipeline with _$ScheduleLastPipeline {
  const factory ScheduleLastPipeline({
    required int id,
    String? status,
    String? ref,
    String? sha,
  }) = _ScheduleLastPipeline;

  factory ScheduleLastPipeline.fromJson(Map<String, dynamic> json) =>
      _$ScheduleLastPipelineFromJson(json);
}

@freezed
abstract class ScheduleOwner with _$ScheduleOwner {
  const factory ScheduleOwner({int? id, String? name, String? username}) =
      _ScheduleOwner;

  factory ScheduleOwner.fromJson(Map<String, dynamic> json) =>
      _$ScheduleOwnerFromJson(json);
}

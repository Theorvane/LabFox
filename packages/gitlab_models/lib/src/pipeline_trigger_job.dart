import 'package:freezed_annotation/freezed_annotation.dart';
import 'ci_status.dart';
import 'pipeline.dart';
part 'pipeline_trigger_job.freezed.dart';
part 'pipeline_trigger_job.g.dart';

/// A trigger job and the downstream pipeline it may have created.
@freezed
abstract class PipelineTriggerJob with _$PipelineTriggerJob {
  const factory PipelineTriggerJob({
    required int id,
    required String name,
    required String status,
    String? stage,
    @JsonKey(name: 'downstream_pipeline') Pipeline? downstreamPipeline,
  }) = _PipelineTriggerJob;
  const PipelineTriggerJob._();
  factory PipelineTriggerJob.fromJson(Map<String, dynamic> json) =>
      _$PipelineTriggerJobFromJson(json);
  CiStatus get ciStatus => CiStatus.parse(status);
}

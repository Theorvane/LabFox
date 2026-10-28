import 'package:freezed_annotation/freezed_annotation.dart';
import 'ci_status.dart';
part 'pipeline_upstream.freezed.dart';
part 'pipeline_upstream.g.dart';

/// One visible upstream pipeline from the selected GraphQL relationship.
@freezed
abstract class PipelineUpstream with _$PipelineUpstream {
  const factory PipelineUpstream({
    required String id,
    required String status,
    String? ref,
    PipelineUpstreamProject? project,
  }) = _PipelineUpstream;
  const PipelineUpstream._();
  factory PipelineUpstream.fromJson(Map<String, dynamic> json) =>
      _$PipelineUpstreamFromJson(json);
  int? get pipelineId => _numericGlobalId(id, 'Ci::Pipeline');
  int? get projectId =>
      project == null ? null : _numericGlobalId(project!.id, 'Project');
  CiStatus get ciStatus => CiStatus.parse(status.toLowerCase());
}

/// Project identity is nullable when the server cannot expose the target.
@freezed
abstract class PipelineUpstreamProject with _$PipelineUpstreamProject {
  const factory PipelineUpstreamProject({required String id}) =
      _PipelineUpstreamProject;
  factory PipelineUpstreamProject.fromJson(Map<String, dynamic> json) =>
      _$PipelineUpstreamProjectFromJson(json);
}

// Convert only the documented model-specific global ID, never a web URL or iid.
int? _numericGlobalId(String id, String type) {
  final prefix = 'gid://gitlab/$type/';
  if (!id.startsWith(prefix)) return null;
  final number = id.substring(prefix.length);
  final match = RegExp(r'^[1-9][0-9]*$').firstMatch(number);
  if (match == null || match.end != number.length) return null;
  return int.tryParse(number);
}

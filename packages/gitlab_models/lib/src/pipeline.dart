import 'package:freezed_annotation/freezed_annotation.dart';

import 'ci_status.dart';

part 'pipeline.freezed.dart';
part 'pipeline.g.dart';

/// A CI/CD pipeline.
@freezed
abstract class Pipeline with _$Pipeline {
  const factory Pipeline({
    required int id,
    required String status,
    @JsonKey(name: 'project_id') int? projectId,
    String? ref,
    String? sha,

    /// Why the pipeline ran: `push`, `schedule`, `merge_request_event`, and
    /// others GitLab adds over time. Null on instances that omit it.
    String? source,
    @JsonKey(name: 'web_url') String? webUrl,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Pipeline;

  const Pipeline._();

  factory Pipeline.fromJson(Map<String, dynamic> json) =>
      _$PipelineFromJson(json);

  CiStatus get ciStatus => CiStatus.parse(status);

  /// [source] as something to show a person.
  ///
  /// GitLab sends snake_case tokens like `merge_request_event`. Printing those
  /// beside human text reads as a leaked internal, and the trailing `_event` is
  /// noise, so both are stripped. An unmapped source still degrades to readable
  /// words rather than to a blank.
  String? get sourceLabel {
    final value = source;
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value == 'schedule') {
      return 'scheduled';
    }
    final trimmed = value.endsWith('_event')
        ? value.substring(0, value.length - '_event'.length)
        : value;
    return trimmed.replaceAll('_', ' ');
  }

  /// The short SHA a user sees, or null when the pipeline has no commit.
  String? get shortSha {
    final value = sha;
    if (value == null) {
      return null;
    }
    return value.length <= 8 ? value : value.substring(0, 8);
  }

  /// A finished pipeline can be retried.
  bool get canRetry => switch (ciStatus) {
    CiStatus.success || CiStatus.failed || CiStatus.canceled => true,
    _ => false,
  };

  /// An active pipeline can be cancelled.
  bool get canCancel => switch (ciStatus) {
    CiStatus.running || CiStatus.pending || CiStatus.created => true,
    _ => false,
  };
}

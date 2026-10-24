import 'package:freezed_annotation/freezed_annotation.dart';

part 'container_cleanup_policy.freezed.dart';
part 'container_cleanup_policy.g.dart';

/// Project-wide cleanup settings; unreported fields are not inferred defaults.
@freezed
abstract class ContainerCleanupPolicy with _$ContainerCleanupPolicy {
  const factory ContainerCleanupPolicy({
    bool? enabled,
    String? cadence,
    @JsonKey(name: 'keep_n') int? keepN,
    @JsonKey(name: 'older_than') String? olderThan,
    @JsonKey(name: 'name_regex_delete') String? nameRegexDelete,
    @JsonKey(name: 'name_regex') String? nameRegex,
    @JsonKey(name: 'name_regex_keep') String? nameRegexKeep,
    @JsonKey(name: 'next_run_at') DateTime? nextRunAt,
  }) = _ContainerCleanupPolicy;

  factory ContainerCleanupPolicy.fromJson(Map<String, dynamic> json) =>
      _$ContainerCleanupPolicyFromJson(json);
}

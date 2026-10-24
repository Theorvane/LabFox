import 'package:freezed_annotation/freezed_annotation.dart';

import 'container_cleanup_policy.dart';

part 'container_cleanup_policy_snapshot.freezed.dart';
part 'container_cleanup_policy_snapshot.g.dart';

/// A project policy read with field-presence information preserved by the API.
@freezed
abstract class ContainerCleanupPolicySnapshot
    with _$ContainerCleanupPolicySnapshot {
  const factory ContainerCleanupPolicySnapshot({
    required bool reported,
    ContainerCleanupPolicy? policy,
  }) = _ContainerCleanupPolicySnapshot;

  factory ContainerCleanupPolicySnapshot.fromJson(Map<String, dynamic> json) =>
      _$ContainerCleanupPolicySnapshotFromJson(json);
}

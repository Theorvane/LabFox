import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

void main() {
  test('reported absence round trips distinctly from unreported state', () {
    const absent = ContainerCleanupPolicySnapshot(reported: true);
    const unknown = ContainerCleanupPolicySnapshot(reported: false);
    expect(absent, isNot(unknown));
    expect(ContainerCleanupPolicySnapshot.fromJson(absent.toJson()), absent);
    expect(ContainerCleanupPolicySnapshot.fromJson(unknown.toJson()), unknown);
  });
  test('disabled and incomplete policies remain existing policies', () {
    for (final policy in [
      const ContainerCleanupPolicy(enabled: false),
      const ContainerCleanupPolicy(),
    ]) {
      final snapshot = ContainerCleanupPolicySnapshot(
        reported: true,
        policy: policy,
      );
      expect(snapshot.policy, policy);
      expect(
        ContainerCleanupPolicySnapshot.fromJson(snapshot.toJson()),
        snapshot,
      );
    }
  });
  test(
    'snapshot retains unknown nonempty patterns without invented defaults',
    () {
      final snapshot = ContainerCleanupPolicySnapshot.fromJson({
        'reported': true,
        'policy': {'name_regex_keep': ' future .+ ', 'cadence': 'future'},
      });
      expect(snapshot.policy!.enabled, isNull);
      expect(snapshot.policy!.nameRegexKeep, ' future .+ ');
      expect(snapshot.policy!.cadence, 'future');
    },
  );
}

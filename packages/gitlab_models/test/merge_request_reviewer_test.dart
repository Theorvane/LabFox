import 'dart:convert';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

void main() {
  for (final state in [
    'unreviewed',
    'reviewed',
    'requested_changes',
    'approved',
    'unapproved',
    'review_started',
    'future_state',
  ]) {
    test('outer review state $state stays separate from account status', () {
      final value = MergeRequestReviewer.fromJson({
        'user': {
          'id': 23,
          'username': 'reviewer',
          'name': 'Reviewer',
          'state': 'blocked',
        },
        'state': state,
      });
      expect(value.state, state);
      expect(value.user.state, 'blocked');
      expect(value.createdAt, isNull);
      expect(
        MergeRequestReviewer.fromJson(
          jsonDecode(jsonEncode(value)) as Map<String, dynamic>,
        ),
        value,
      );
    });
  }
  test(
    'review state must be present even when nested account state is present',
    () {
      expect(
        () => MergeRequestReviewer.fromJson({
          'user': {'id': 23, 'username': 'r', 'name': 'R', 'state': 'active'},
        }),
        throwsA(isA<TypeError>()),
      );
    },
  );
}

import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

Map<String, dynamic> payload() => {
  'id': 55123,
  'iid': 142,
  'title': 'Review original commit',
  'state': 'opened',
  'source_branch': 'feature',
  'target_branch': 'main',
  'project_id': 8,
};

void main() {
  for (final source in [8, 19]) {
    test('preserves separate fork identities for source $source', () {
      final mr = MergeRequest.fromJson({
        ...payload(),
        'source_project_id': source,
        'target_project_id': 8,
      });
      expect(mr.id, 55123);
      expect(mr.iid, 142);
      expect(mr.projectId, 8);
      expect(mr.sourceProjectId, source);
      expect(mr.targetProjectId, 8);
      expect(MergeRequest.fromJson(mr.toJson()), mr);
      expect(mr.copyWith(sourceProjectId: null).sourceProjectId, isNull);
      expect(mr.copyWith(targetProjectId: 9), isNot(mr));
    });
  }
  for (final explicitNull in [false, true]) {
    test('does not infer absent or null project identities $explicitNull', () {
      final mr = MergeRequest.fromJson({
        ...payload(),
        if (explicitNull) 'source_project_id': null,
        if (explicitNull) 'target_project_id': null,
      });
      expect(mr.sourceProjectId, isNull);
      expect(mr.targetProjectId, isNull);
      expect(mr.toJson()['source_project_id'], isNull);
      expect(mr.toJson()['target_project_id'], isNull);
    });
  }
  test('deleted source stays unknown while target remains available', () {
    final mr = MergeRequest.fromJson({
      ...payload(),
      'source_project_id': null,
      'target_project_id': 8,
    });
    expect(mr.sourceProjectId, isNull);
    expect(mr.targetProjectId, 8);
  });
}

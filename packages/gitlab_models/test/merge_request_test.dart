import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

void main() {
  group('MergeRequest', () {
    test('keeps iid and id distinct', () {
      // The number a user sees (!142) is the iid, not the global id.
      final mr = MergeRequest.fromJson(const {
        'id': 55123,
        'iid': 142,
        'title': 'Add OAuth authentication',
        'state': 'opened',
        'source_branch': 'feature/oauth',
        'target_branch': 'develop',
      });

      expect(mr.id, 55123);
      expect(mr.iid, 142);
      expect(mr.sourceBranch, 'feature/oauth');
      expect(mr.targetBranch, 'develop');
    });

    test('parses project_id so a search hit can be opened in its project', () {
      final mr = MergeRequest.fromJson(const {
        'id': 1,
        'iid': 1,
        'title': 't',
        'state': 'opened',
        'source_branch': 'a',
        'target_branch': 'b',
        'project_id': 42,
      });

      expect(mr.projectId, 42);
    });

    test('parses the three states', () {
      MergeRequest state(String s) => MergeRequest.fromJson({
        'id': 1,
        'iid': 1,
        'title': 'x',
        'state': s,
        'source_branch': 'a',
        'target_branch': 'b',
      });

      expect(state('opened').isOpen, isTrue);
      expect(state('merged').isMerged, isTrue);
      expect(state('closed').isClosed, isTrue);
      expect(state('opened').isMerged, isFalse);
    });

    test('flags a draft merge request', () {
      final mr = MergeRequest.fromJson(const {
        'id': 1,
        'iid': 1,
        'title': 'Draft: wip',
        'state': 'opened',
        'source_branch': 'a',
        'target_branch': 'b',
        'draft': true,
      });
      expect(mr.isDraft, isTrue);
    });

    test('parses labels with colours and change counts', () {
      final mr = MergeRequest.fromJson(const {
        'id': 1,
        'iid': 1,
        'title': 'x',
        'state': 'opened',
        'source_branch': 'a',
        'target_branch': 'b',
        'labels': [
          {'name': 'backend', 'color': '#0e8a16'},
        ],
        'merge_status': 'can_be_merged',
      });
      expect(mr.labels.single.name, 'backend');
      expect(mr.labels.single.color, '#0e8a16');
      expect(mr.mergeStatus, 'can_be_merged');
    });

    test('defaults draft to false and labels to empty', () {
      final mr = MergeRequest.fromJson(const {
        'id': 1,
        'iid': 1,
        'title': 'x',
        'state': 'opened',
        'source_branch': 'a',
        'target_branch': 'b',
      });
      expect(mr.isDraft, isFalse);
      expect(mr.labels, isEmpty);
    });

    test('distinguishes subscribed from an absent subscription field', () {
      final subscribed = MergeRequest.fromJson(const {
        'id': 1,
        'iid': 1,
        'title': 'x',
        'state': 'opened',
        'source_branch': 'a',
        'target_branch': 'b',
        'subscribed': true,
      });
      final absent = MergeRequest.fromJson(const {
        'id': 1,
        'iid': 1,
        'title': 'x',
        'state': 'opened',
        'source_branch': 'a',
        'target_branch': 'b',
      });

      expect(subscribed.subscribed, isTrue);
      expect(absent.subscribed, isNull);
    });
  });
}

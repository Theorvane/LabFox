import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

void main() {
  group('Issue', () {
    test('distinguishes locked, unlocked, and absent discussions', () {
      const base = {'id': 1, 'iid': 5, 'title': 'x', 'state': 'opened'};
      expect(
        Issue.fromJson({...base, 'discussion_locked': true}).discussionLocked,
        isTrue,
      );
      expect(
        Issue.fromJson({...base, 'discussion_locked': false}).discussionLocked,
        isFalse,
      );
      expect(Issue.fromJson(base).discussionLocked, isNull);
    });

    test('distinguishes confidential, public, and absent values', () {
      const base = {'id': 1, 'iid': 5, 'title': 'x', 'state': 'opened'};
      expect(
        Issue.fromJson({...base, 'confidential': true}).confidential,
        isTrue,
      );
      expect(
        Issue.fromJson({...base, 'confidential': false}).confidential,
        isFalse,
      );
      expect(Issue.fromJson(base).confidential, isNull);
    });

    test('parses an assigned milestone and preserves its global id', () {
      final issue = Issue.fromJson(const {
        'id': 1,
        'iid': 5,
        'title': 'x',
        'state': 'opened',
        'milestone': {'id': 17, 'iid': 2, 'title': 'v4.0', 'state': 'active'},
      });

      expect(issue.milestone?.id, 17);
      expect(issue.milestone?.iid, 2);
      expect(issue.milestone?.title, 'v4.0');
    });

    test('parses an optional issue due date', () {
      final dated = Issue.fromJson(const {
        'id': 1,
        'iid': 5,
        'title': 'x',
        'state': 'opened',
        'due_date': '2026-10-15',
      });
      final undated = Issue.fromJson(const {
        'id': 1,
        'iid': 6,
        'title': 'y',
        'state': 'opened',
        'due_date': null,
      });

      expect(dated.dueDate, DateTime(2026, 10, 15));
      expect(undated.dueDate, isNull);
    });

    test('keeps iid and id distinct', () {
      // The number a user sees (#282) is the iid; id is the global identifier.
      // Flattening them would route to the wrong resource.
      final issue = Issue.fromJson(const {
        'id': 99401,
        'iid': 282,
        'title': 'Android login error',
        'state': 'opened',
      });

      expect(issue.id, 99401);
      expect(issue.iid, 282);
      expect(issue.id, isNot(issue.iid));
    });

    test('parses project_id so a search hit can be opened in its project', () {
      final issue = Issue.fromJson(const {
        'id': 1,
        'iid': 5,
        'title': 't',
        'state': 'opened',
        'project_id': 42,
      });

      expect(issue.projectId, 42);
    });

    test('leaves project_id null when absent', () {
      final issue = Issue.fromJson(const {
        'id': 1,
        'iid': 5,
        'title': 't',
        'state': 'opened',
      });

      expect(issue.projectId, isNull);
    });

    test('parses state, author, and description', () {
      final issue = Issue.fromJson(const {
        'id': 1,
        'iid': 5,
        'title': 'Cache optimization',
        'state': 'closed',
        'description': 'Use Redis.',
        'author': {'id': 7, 'username': 'jungwon', 'name': 'Jungwon'},
      });

      expect(issue.isOpen, isFalse);
      expect(issue.state, 'closed');
      expect(issue.description, 'Use Redis.');
      expect(issue.author?.username, 'jungwon');
    });

    test('isOpen is true for the opened state', () {
      final issue = Issue.fromJson(const {
        'id': 1,
        'iid': 1,
        'title': 'x',
        'state': 'opened',
      });
      expect(issue.isOpen, isTrue);
    });

    test('parses detailed labels with their colours', () {
      // with_labels_details=true returns objects; the colour must survive so
      // GitLabLabel can compute a readable foreground.
      final issue = Issue.fromJson(const {
        'id': 1,
        'iid': 1,
        'title': 'x',
        'state': 'opened',
        'labels': [
          {'name': 'bug', 'color': '#d73a4a', 'text_color': '#ffffff'},
          {'name': 'android', 'color': '#0e8a16'},
        ],
      });
      expect(issue.labels.map((l) => l.name), ['bug', 'android']);
      expect(issue.labels.first.color, '#d73a4a');
    });

    test('parses plain string labels as names without a colour', () {
      final issue = Issue.fromJson(const {
        'id': 1,
        'iid': 1,
        'title': 'x',
        'state': 'opened',
        'labels': ['bug', 'android'],
      });
      expect(issue.labels.map((l) => l.name), ['bug', 'android']);
      expect(issue.labels.first.color, isNull);
    });

    test('defaults labels to empty when absent', () {
      final issue = Issue.fromJson(const {
        'id': 1,
        'iid': 1,
        'title': 'x',
        'state': 'opened',
      });
      expect(issue.labels, isEmpty);
    });

    test('keeps subscription state distinct from an absent field', () {
      final subscribed = Issue.fromJson(const {
        'id': 1,
        'iid': 1,
        'title': 'x',
        'state': 'opened',
        'subscribed': true,
      });
      final absent = Issue.fromJson(const {
        'id': 1,
        'iid': 1,
        'title': 'x',
        'state': 'opened',
      });

      expect(subscribed.subscribed, isTrue);
      expect(absent.subscribed, isNull);
    });
  });
}

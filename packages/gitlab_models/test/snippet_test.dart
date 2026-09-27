import 'package:gitlab_models/gitlab_models.dart';
import 'package:test/test.dart';

void main() {
  test('parses snippet visibility when returned by GitLab', () {
    final snippet = Snippet.fromJson({
      'id': 73,
      'title': 'Deploy helper',
      'visibility': 'private',
    });

    expect(snippet.visibility, 'private');
  });

  test('accepts older snippet responses without visibility', () {
    final snippet = Snippet.fromJson({'id': 73, 'title': 'Deploy helper'});

    expect(snippet.visibility, isNull);
  });
}

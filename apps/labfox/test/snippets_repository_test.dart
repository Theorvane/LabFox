import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/snippets/data/snippets_repository.dart';

void main() {
  test('uses the file raw URL ref for older snippet repositories', () {
    const file = SnippetFile(
      path: 'src/code.rb',
      rawUrl: 'https://git.example/-/snippets/7/raw/master/src/code.rb',
    );
    expect(snippetRefForFile(file), 'master');
  });

  test('defaults to main when a snippet file has no raw URL', () {
    expect(snippetRefForFile(const SnippetFile(path: 'code.rb')), 'main');
  });
}

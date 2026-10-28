import 'package:freezed_annotation/freezed_annotation.dart';

part 'wiki_page.freezed.dart';
part 'wiki_page.g.dart';

/// A page in a GitLab project wiki.
@freezed
abstract class WikiPage with _$WikiPage {
  const factory WikiPage({
    required String title,
    required String slug,
    String? content,
    String? format,
  }) = _WikiPage;

  factory WikiPage.fromJson(Map<String, dynamic> json) =>
      _$WikiPageFromJson(json);
}

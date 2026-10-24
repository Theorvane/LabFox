import 'package:freezed_annotation/freezed_annotation.dart';

part 'snippet.freezed.dart';
part 'snippet.g.dart';

/// A file in a project snippet repository.
@freezed
abstract class SnippetFile with _$SnippetFile {
  const factory SnippetFile({
    required String path,
    @JsonKey(name: 'raw_url') String? rawUrl,
  }) = _SnippetFile;

  factory SnippetFile.fromJson(Map<String, dynamic> json) =>
      _$SnippetFileFromJson(json);
}

/// A GitLab project snippet. Its id is global, unlike an issue iid.
@freezed
abstract class Snippet with _$Snippet {
  const factory Snippet({
    required int id,
    required String title,
    String? description,
    String? visibility,
    @JsonKey(name: 'file_name') String? fileName,
    @Default([]) List<SnippetFile> files,
    @JsonKey(name: 'web_url') String? webUrl,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Snippet;

  factory Snippet.fromJson(Map<String, dynamic> json) =>
      _$SnippetFromJson(json);
}

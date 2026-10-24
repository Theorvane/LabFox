import 'package:freezed_annotation/freezed_annotation.dart';

import 'commit.dart';

part 'repository_tag.freezed.dart';
part 'repository_tag.g.dart';

/// Release summary attached to a repository tag when one exists.
@freezed
abstract class TagRelease with _$TagRelease {
  const factory TagRelease({
    @JsonKey(name: 'tag_name') required String tagName,
    String? description,
  }) = _TagRelease;

  factory TagRelease.fromJson(Map<String, dynamic> json) =>
      _$TagReleaseFromJson(json);
}

/// A Git repository tag, which is identified by name rather than a numeric id.
@freezed
abstract class RepositoryTag with _$RepositoryTag {
  const factory RepositoryTag({
    required String name,
    String? message,
    String? target,
    @JsonKey(name: 'protected') @Default(false) bool isProtected,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    Commit? commit,
    TagRelease? release,
  }) = _RepositoryTag;

  factory RepositoryTag.fromJson(Map<String, dynamic> json) =>
      _$RepositoryTagFromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'registry_tag.freezed.dart';
part 'registry_tag.g.dart';

/// A container image tag; detail fields are absent from a list response.
@freezed
abstract class RegistryTag with _$RegistryTag {
  const factory RegistryTag({
    required String name,
    required String path,
    String? location,
    String? revision,
    @JsonKey(name: 'short_revision') String? shortRevision,
    String? digest,
    @JsonKey(name: 'total_size') int? totalSize,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _RegistryTag;

  factory RegistryTag.fromJson(Map<String, dynamic> json) =>
      _$RegistryTagFromJson(json);
}

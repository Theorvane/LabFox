import 'package:freezed_annotation/freezed_annotation.dart';

import 'protected_branch.dart';

part 'protected_tag.freezed.dart';
part 'protected_tag.g.dart';

/// A GitLab protected tag rule; [name] may be a wildcard.
@freezed
abstract class ProtectedTag with _$ProtectedTag {
  const factory ProtectedTag({
    required String name,
    @JsonKey(name: 'create_access_levels')
    @Default(<ProtectedBranchAccess>[])
    List<ProtectedBranchAccess> createAccessLevels,
  }) = _ProtectedTag;

  factory ProtectedTag.fromJson(Map<String, dynamic> json) =>
      _$ProtectedTagFromJson(json);
}

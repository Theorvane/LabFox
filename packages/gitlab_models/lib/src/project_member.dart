import 'package:freezed_annotation/freezed_annotation.dart';

part 'project_member.freezed.dart';
part 'project_member.g.dart';

/// A member's effective access to a project or group.
@freezed
abstract class ProjectMember with _$ProjectMember {
  const factory ProjectMember({
    required int id,
    required String username,
    required String name,
    @JsonKey(name: 'access_level') required int accessLevel,
    String? state,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'web_url') String? webUrl,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
  }) = _ProjectMember;

  factory ProjectMember.fromJson(Map<String, dynamic> json) =>
      _$ProjectMemberFromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'project_event.freezed.dart';
part 'project_event.g.dart';

/// Activity visible to the current user in one GitLab project.
@freezed
abstract class ProjectEvent with _$ProjectEvent {
  const factory ProjectEvent({
    required int id,
    @JsonKey(name: 'project_id') required int projectId,
    @JsonKey(name: 'action_name') required String actionName,
    @JsonKey(name: 'target_id') int? targetId,
    @JsonKey(name: 'target_iid') int? targetIid,
    @JsonKey(name: 'target_type') String? targetType,
    @JsonKey(name: 'target_title') String? targetTitle,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    EventActor? author,
    @JsonKey(name: 'author_username') String? authorUsername,
    @JsonKey(name: 'push_data') EventPushData? pushData,
  }) = _ProjectEvent;

  factory ProjectEvent.fromJson(Map<String, dynamic> json) =>
      _$ProjectEventFromJson(json);
}

@freezed
abstract class EventActor with _$EventActor {
  const factory EventActor({
    required int id,
    required String name,
    required String username,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
  }) = _EventActor;

  factory EventActor.fromJson(Map<String, dynamic> json) =>
      _$EventActorFromJson(json);
}

/// Push details can be incomplete for bulk push activity.
@freezed
abstract class EventPushData with _$EventPushData {
  const factory EventPushData({
    @JsonKey(name: 'commit_count') int? commitCount,
    @JsonKey(name: 'ref_count') int? refCount,
    @JsonKey(name: 'ref_type') String? refType,
    String? ref,
    @JsonKey(name: 'commit_to') String? commitTo,
    @JsonKey(name: 'commit_title') String? commitTitle,
  }) = _EventPushData;

  factory EventPushData.fromJson(Map<String, dynamic> json) =>
      _$EventPushDataFromJson(json);
}

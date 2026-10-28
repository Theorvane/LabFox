// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'merge_request_reviewer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MergeRequestReviewer _$MergeRequestReviewerFromJson(
  Map<String, dynamic> json,
) => _MergeRequestReviewer(
  user: User.fromJson(json['user'] as Map<String, dynamic>),
  state: json['state'] as String,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$MergeRequestReviewerToJson(
  _MergeRequestReviewer instance,
) => <String, dynamic>{
  'user': instance.user.toJson(),
  'state': instance.state,
  'created_at': instance.createdAt?.toIso8601String(),
};

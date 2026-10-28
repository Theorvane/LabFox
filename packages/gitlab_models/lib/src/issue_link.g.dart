// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'issue_link.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_IssueLink _$IssueLinkFromJson(Map<String, dynamic> json) => _IssueLink(
  id: (json['id'] as num).toInt(),
  iid: (json['iid'] as num).toInt(),
  projectId: (json['project_id'] as num).toInt(),
  title: json['title'] as String,
  state: json['state'] as String,
  linkType: json['link_type'] as String,
  issueLinkId: (json['issue_link_id'] as num?)?.toInt(),
);

Map<String, dynamic> _$IssueLinkToJson(_IssueLink instance) =>
    <String, dynamic>{
      'id': instance.id,
      'iid': instance.iid,
      'project_id': instance.projectId,
      'title': instance.title,
      'state': instance.state,
      'link_type': instance.linkType,
      'issue_link_id': instance.issueLinkId,
    };

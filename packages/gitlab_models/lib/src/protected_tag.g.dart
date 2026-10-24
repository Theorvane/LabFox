// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'protected_tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProtectedTag _$ProtectedTagFromJson(Map<String, dynamic> json) =>
    _ProtectedTag(
      name: json['name'] as String,
      createAccessLevels:
          (json['create_access_levels'] as List<dynamic>?)
              ?.map(
                (e) =>
                    ProtectedBranchAccess.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <ProtectedBranchAccess>[],
    );

Map<String, dynamic> _$ProtectedTagToJson(_ProtectedTag instance) =>
    <String, dynamic>{
      'name': instance.name,
      'create_access_levels': instance.createAccessLevels
          .map((e) => e.toJson())
          .toList(),
    };

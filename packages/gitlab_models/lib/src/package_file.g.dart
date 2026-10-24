// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PackageFile _$PackageFileFromJson(Map<String, dynamic> json) => _PackageFile(
  id: (json['id'] as num).toInt(),
  packageId: (json['package_id'] as num).toInt(),
  fileName: json['file_name'] as String,
  size: (json['size'] as num?)?.toInt(),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$PackageFileToJson(_PackageFile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'package_id': instance.packageId,
      'file_name': instance.fileName,
      'size': instance.size,
      'created_at': instance.createdAt?.toIso8601String(),
    };

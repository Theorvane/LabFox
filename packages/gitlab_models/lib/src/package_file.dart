import 'package:freezed_annotation/freezed_annotation.dart';

part 'package_file.freezed.dart';
part 'package_file.g.dart';

/// A file belonging to a published package.
@freezed
abstract class PackageFile with _$PackageFile {
  const factory PackageFile({
    required int id,
    @JsonKey(name: 'package_id') required int packageId,
    @JsonKey(name: 'file_name') required String fileName,
    int? size,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _PackageFile;

  factory PackageFile.fromJson(Map<String, dynamic> json) =>
      _$PackageFileFromJson(json);
}

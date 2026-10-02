// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'package_file.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PackageFile {
  int get id;
  @JsonKey(name: 'package_id')
  int get packageId;
  @JsonKey(name: 'file_name')
  String get fileName;
  int? get size;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;

  /// Create a copy of PackageFile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PackageFileCopyWith<PackageFile> get copyWith =>
      _$PackageFileCopyWithImpl<PackageFile>(this as PackageFile, _$identity);

  /// Serializes this PackageFile to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PackageFile &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.packageId, packageId) ||
                other.packageId == packageId) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, packageId, fileName, size, createdAt);

  @override
  String toString() {
    return 'PackageFile(id: $id, packageId: $packageId, fileName: $fileName, size: $size, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $PackageFileCopyWith<$Res> {
  factory $PackageFileCopyWith(
    PackageFile value,
    $Res Function(PackageFile) _then,
  ) = _$PackageFileCopyWithImpl;
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'package_id') int packageId,
    @JsonKey(name: 'file_name') String fileName,
    int? size,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class _$PackageFileCopyWithImpl<$Res> implements $PackageFileCopyWith<$Res> {
  _$PackageFileCopyWithImpl(this._self, this._then);

  final PackageFile _self;
  final $Res Function(PackageFile) _then;

  /// Create a copy of PackageFile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? packageId = null,
    Object? fileName = null,
    Object? size = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _self.copyWith(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        packageId: null == packageId
            ? _self.packageId
            : packageId // ignore: cast_nullable_to_non_nullable
                  as int,
        fileName: null == fileName
            ? _self.fileName
            : fileName // ignore: cast_nullable_to_non_nullable
                  as String,
        size: freezed == size
            ? _self.size
            : size // ignore: cast_nullable_to_non_nullable
                  as int?,
        createdAt: freezed == createdAt
            ? _self.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [PackageFile].
extension PackageFilePatterns on PackageFile {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_PackageFile value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PackageFile() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_PackageFile value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PackageFile():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_PackageFile value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PackageFile() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      int id,
      @JsonKey(name: 'package_id') int packageId,
      @JsonKey(name: 'file_name') String fileName,
      int? size,
      @JsonKey(name: 'created_at') DateTime? createdAt,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PackageFile() when $default != null:
        return $default(
          _that.id,
          _that.packageId,
          _that.fileName,
          _that.size,
          _that.createdAt,
        );
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      int id,
      @JsonKey(name: 'package_id') int packageId,
      @JsonKey(name: 'file_name') String fileName,
      int? size,
      @JsonKey(name: 'created_at') DateTime? createdAt,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PackageFile():
        return $default(
          _that.id,
          _that.packageId,
          _that.fileName,
          _that.size,
          _that.createdAt,
        );
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      int id,
      @JsonKey(name: 'package_id') int packageId,
      @JsonKey(name: 'file_name') String fileName,
      int? size,
      @JsonKey(name: 'created_at') DateTime? createdAt,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PackageFile() when $default != null:
        return $default(
          _that.id,
          _that.packageId,
          _that.fileName,
          _that.size,
          _that.createdAt,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _PackageFile implements PackageFile {
  const _PackageFile({
    required this.id,
    @JsonKey(name: 'package_id') required this.packageId,
    @JsonKey(name: 'file_name') required this.fileName,
    this.size,
    @JsonKey(name: 'created_at') this.createdAt,
  });
  factory _PackageFile.fromJson(Map<String, dynamic> json) =>
      _$PackageFileFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'package_id')
  final int packageId;
  @override
  @JsonKey(name: 'file_name')
  final String fileName;
  @override
  final int? size;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  /// Create a copy of PackageFile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PackageFileCopyWith<_PackageFile> get copyWith =>
      __$PackageFileCopyWithImpl<_PackageFile>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PackageFileToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PackageFile &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.packageId, packageId) ||
                other.packageId == packageId) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, packageId, fileName, size, createdAt);

  @override
  String toString() {
    return 'PackageFile(id: $id, packageId: $packageId, fileName: $fileName, size: $size, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$PackageFileCopyWith<$Res>
    implements $PackageFileCopyWith<$Res> {
  factory _$PackageFileCopyWith(
    _PackageFile value,
    $Res Function(_PackageFile) _then,
  ) = __$PackageFileCopyWithImpl;
  @override
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'package_id') int packageId,
    @JsonKey(name: 'file_name') String fileName,
    int? size,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class __$PackageFileCopyWithImpl<$Res> implements _$PackageFileCopyWith<$Res> {
  __$PackageFileCopyWithImpl(this._self, this._then);

  final _PackageFile _self;
  final $Res Function(_PackageFile) _then;

  /// Create a copy of PackageFile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? packageId = null,
    Object? fileName = null,
    Object? size = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _PackageFile(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        packageId: null == packageId
            ? _self.packageId
            : packageId // ignore: cast_nullable_to_non_nullable
                  as int,
        fileName: null == fileName
            ? _self.fileName
            : fileName // ignore: cast_nullable_to_non_nullable
                  as String,
        size: freezed == size
            ? _self.size
            : size // ignore: cast_nullable_to_non_nullable
                  as int?,
        createdAt: freezed == createdAt
            ? _self.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

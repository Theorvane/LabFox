// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'registry_tag.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RegistryTag {
  String get name;
  String get path;
  String? get location;
  String? get revision;
  @JsonKey(name: 'short_revision')
  String? get shortRevision;
  String? get digest;
  @JsonKey(name: 'total_size')
  int? get totalSize;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;

  /// Create a copy of RegistryTag
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RegistryTagCopyWith<RegistryTag> get copyWith =>
      _$RegistryTagCopyWithImpl<RegistryTag>(this as RegistryTag, _$identity);

  /// Serializes this RegistryTag to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RegistryTag &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.revision, revision) ||
                other.revision == revision) &&
            (identical(other.shortRevision, shortRevision) ||
                other.shortRevision == shortRevision) &&
            (identical(other.digest, digest) || other.digest == digest) &&
            (identical(other.totalSize, totalSize) ||
                other.totalSize == totalSize) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    path,
    location,
    revision,
    shortRevision,
    digest,
    totalSize,
    createdAt,
  );

  @override
  String toString() {
    return 'RegistryTag(name: $name, path: $path, location: $location, revision: $revision, shortRevision: $shortRevision, digest: $digest, totalSize: $totalSize, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $RegistryTagCopyWith<$Res> {
  factory $RegistryTagCopyWith(
    RegistryTag value,
    $Res Function(RegistryTag) _then,
  ) = _$RegistryTagCopyWithImpl;
  @useResult
  $Res call({
    String name,
    String path,
    String? location,
    String? revision,
    @JsonKey(name: 'short_revision') String? shortRevision,
    String? digest,
    @JsonKey(name: 'total_size') int? totalSize,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class _$RegistryTagCopyWithImpl<$Res> implements $RegistryTagCopyWith<$Res> {
  _$RegistryTagCopyWithImpl(this._self, this._then);

  final RegistryTag _self;
  final $Res Function(RegistryTag) _then;

  /// Create a copy of RegistryTag
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? path = null,
    Object? location = freezed,
    Object? revision = freezed,
    Object? shortRevision = freezed,
    Object? digest = freezed,
    Object? totalSize = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _self.copyWith(
        name: null == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        path: null == path
            ? _self.path
            : path // ignore: cast_nullable_to_non_nullable
                  as String,
        location: freezed == location
            ? _self.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
        revision: freezed == revision
            ? _self.revision
            : revision // ignore: cast_nullable_to_non_nullable
                  as String?,
        shortRevision: freezed == shortRevision
            ? _self.shortRevision
            : shortRevision // ignore: cast_nullable_to_non_nullable
                  as String?,
        digest: freezed == digest
            ? _self.digest
            : digest // ignore: cast_nullable_to_non_nullable
                  as String?,
        totalSize: freezed == totalSize
            ? _self.totalSize
            : totalSize // ignore: cast_nullable_to_non_nullable
                  as int?,
        createdAt: freezed == createdAt
            ? _self.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [RegistryTag].
extension RegistryTagPatterns on RegistryTag {
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
    TResult Function(_RegistryTag value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RegistryTag() when $default != null:
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
    TResult Function(_RegistryTag value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RegistryTag():
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
    TResult? Function(_RegistryTag value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RegistryTag() when $default != null:
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
      String name,
      String path,
      String? location,
      String? revision,
      @JsonKey(name: 'short_revision') String? shortRevision,
      String? digest,
      @JsonKey(name: 'total_size') int? totalSize,
      @JsonKey(name: 'created_at') DateTime? createdAt,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RegistryTag() when $default != null:
        return $default(
          _that.name,
          _that.path,
          _that.location,
          _that.revision,
          _that.shortRevision,
          _that.digest,
          _that.totalSize,
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
      String name,
      String path,
      String? location,
      String? revision,
      @JsonKey(name: 'short_revision') String? shortRevision,
      String? digest,
      @JsonKey(name: 'total_size') int? totalSize,
      @JsonKey(name: 'created_at') DateTime? createdAt,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RegistryTag():
        return $default(
          _that.name,
          _that.path,
          _that.location,
          _that.revision,
          _that.shortRevision,
          _that.digest,
          _that.totalSize,
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
      String name,
      String path,
      String? location,
      String? revision,
      @JsonKey(name: 'short_revision') String? shortRevision,
      String? digest,
      @JsonKey(name: 'total_size') int? totalSize,
      @JsonKey(name: 'created_at') DateTime? createdAt,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RegistryTag() when $default != null:
        return $default(
          _that.name,
          _that.path,
          _that.location,
          _that.revision,
          _that.shortRevision,
          _that.digest,
          _that.totalSize,
          _that.createdAt,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _RegistryTag implements RegistryTag {
  const _RegistryTag({
    required this.name,
    required this.path,
    this.location,
    this.revision,
    @JsonKey(name: 'short_revision') this.shortRevision,
    this.digest,
    @JsonKey(name: 'total_size') this.totalSize,
    @JsonKey(name: 'created_at') this.createdAt,
  });
  factory _RegistryTag.fromJson(Map<String, dynamic> json) =>
      _$RegistryTagFromJson(json);

  @override
  final String name;
  @override
  final String path;
  @override
  final String? location;
  @override
  final String? revision;
  @override
  @JsonKey(name: 'short_revision')
  final String? shortRevision;
  @override
  final String? digest;
  @override
  @JsonKey(name: 'total_size')
  final int? totalSize;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  /// Create a copy of RegistryTag
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RegistryTagCopyWith<_RegistryTag> get copyWith =>
      __$RegistryTagCopyWithImpl<_RegistryTag>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$RegistryTagToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _RegistryTag &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.revision, revision) ||
                other.revision == revision) &&
            (identical(other.shortRevision, shortRevision) ||
                other.shortRevision == shortRevision) &&
            (identical(other.digest, digest) || other.digest == digest) &&
            (identical(other.totalSize, totalSize) ||
                other.totalSize == totalSize) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    path,
    location,
    revision,
    shortRevision,
    digest,
    totalSize,
    createdAt,
  );

  @override
  String toString() {
    return 'RegistryTag(name: $name, path: $path, location: $location, revision: $revision, shortRevision: $shortRevision, digest: $digest, totalSize: $totalSize, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$RegistryTagCopyWith<$Res>
    implements $RegistryTagCopyWith<$Res> {
  factory _$RegistryTagCopyWith(
    _RegistryTag value,
    $Res Function(_RegistryTag) _then,
  ) = __$RegistryTagCopyWithImpl;
  @override
  @useResult
  $Res call({
    String name,
    String path,
    String? location,
    String? revision,
    @JsonKey(name: 'short_revision') String? shortRevision,
    String? digest,
    @JsonKey(name: 'total_size') int? totalSize,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class __$RegistryTagCopyWithImpl<$Res> implements _$RegistryTagCopyWith<$Res> {
  __$RegistryTagCopyWithImpl(this._self, this._then);

  final _RegistryTag _self;
  final $Res Function(_RegistryTag) _then;

  /// Create a copy of RegistryTag
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? name = null,
    Object? path = null,
    Object? location = freezed,
    Object? revision = freezed,
    Object? shortRevision = freezed,
    Object? digest = freezed,
    Object? totalSize = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _RegistryTag(
        name: null == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        path: null == path
            ? _self.path
            : path // ignore: cast_nullable_to_non_nullable
                  as String,
        location: freezed == location
            ? _self.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
        revision: freezed == revision
            ? _self.revision
            : revision // ignore: cast_nullable_to_non_nullable
                  as String?,
        shortRevision: freezed == shortRevision
            ? _self.shortRevision
            : shortRevision // ignore: cast_nullable_to_non_nullable
                  as String?,
        digest: freezed == digest
            ? _self.digest
            : digest // ignore: cast_nullable_to_non_nullable
                  as String?,
        totalSize: freezed == totalSize
            ? _self.totalSize
            : totalSize // ignore: cast_nullable_to_non_nullable
                  as int?,
        createdAt: freezed == createdAt
            ? _self.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'registry_repository.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RegistryRepository {
  int get id;
  String get name;
  String get path;
  @JsonKey(name: 'project_id')
  int get projectId;
  String? get location;
  String? get status;
  @JsonKey(name: 'tags_count')
  int? get tagsCount;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;

  /// Create a copy of RegistryRepository
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RegistryRepositoryCopyWith<RegistryRepository> get copyWith =>
      _$RegistryRepositoryCopyWithImpl<RegistryRepository>(
        this as RegistryRepository,
        _$identity,
      );

  /// Serializes this RegistryRepository to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RegistryRepository &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.projectId, projectId) ||
                other.projectId == projectId) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.tagsCount, tagsCount) ||
                other.tagsCount == tagsCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    path,
    projectId,
    location,
    status,
    tagsCount,
    createdAt,
  );

  @override
  String toString() {
    return 'RegistryRepository(id: $id, name: $name, path: $path, projectId: $projectId, location: $location, status: $status, tagsCount: $tagsCount, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $RegistryRepositoryCopyWith<$Res> {
  factory $RegistryRepositoryCopyWith(
    RegistryRepository value,
    $Res Function(RegistryRepository) _then,
  ) = _$RegistryRepositoryCopyWithImpl;
  @useResult
  $Res call({
    int id,
    String name,
    String path,
    @JsonKey(name: 'project_id') int projectId,
    String? location,
    String? status,
    @JsonKey(name: 'tags_count') int? tagsCount,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class _$RegistryRepositoryCopyWithImpl<$Res>
    implements $RegistryRepositoryCopyWith<$Res> {
  _$RegistryRepositoryCopyWithImpl(this._self, this._then);

  final RegistryRepository _self;
  final $Res Function(RegistryRepository) _then;

  /// Create a copy of RegistryRepository
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? path = null,
    Object? projectId = null,
    Object? location = freezed,
    Object? status = freezed,
    Object? tagsCount = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _self.copyWith(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        path: null == path
            ? _self.path
            : path // ignore: cast_nullable_to_non_nullable
                  as String,
        projectId: null == projectId
            ? _self.projectId
            : projectId // ignore: cast_nullable_to_non_nullable
                  as int,
        location: freezed == location
            ? _self.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: freezed == status
            ? _self.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
        tagsCount: freezed == tagsCount
            ? _self.tagsCount
            : tagsCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        createdAt: freezed == createdAt
            ? _self.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [RegistryRepository].
extension RegistryRepositoryPatterns on RegistryRepository {
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
    TResult Function(_RegistryRepository value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RegistryRepository() when $default != null:
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
    TResult Function(_RegistryRepository value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RegistryRepository():
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
    TResult? Function(_RegistryRepository value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RegistryRepository() when $default != null:
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
      String name,
      String path,
      @JsonKey(name: 'project_id') int projectId,
      String? location,
      String? status,
      @JsonKey(name: 'tags_count') int? tagsCount,
      @JsonKey(name: 'created_at') DateTime? createdAt,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RegistryRepository() when $default != null:
        return $default(
          _that.id,
          _that.name,
          _that.path,
          _that.projectId,
          _that.location,
          _that.status,
          _that.tagsCount,
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
      String name,
      String path,
      @JsonKey(name: 'project_id') int projectId,
      String? location,
      String? status,
      @JsonKey(name: 'tags_count') int? tagsCount,
      @JsonKey(name: 'created_at') DateTime? createdAt,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RegistryRepository():
        return $default(
          _that.id,
          _that.name,
          _that.path,
          _that.projectId,
          _that.location,
          _that.status,
          _that.tagsCount,
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
      String name,
      String path,
      @JsonKey(name: 'project_id') int projectId,
      String? location,
      String? status,
      @JsonKey(name: 'tags_count') int? tagsCount,
      @JsonKey(name: 'created_at') DateTime? createdAt,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RegistryRepository() when $default != null:
        return $default(
          _that.id,
          _that.name,
          _that.path,
          _that.projectId,
          _that.location,
          _that.status,
          _that.tagsCount,
          _that.createdAt,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _RegistryRepository implements RegistryRepository {
  const _RegistryRepository({
    required this.id,
    required this.name,
    required this.path,
    @JsonKey(name: 'project_id') required this.projectId,
    this.location,
    this.status,
    @JsonKey(name: 'tags_count') this.tagsCount,
    @JsonKey(name: 'created_at') this.createdAt,
  });
  factory _RegistryRepository.fromJson(Map<String, dynamic> json) =>
      _$RegistryRepositoryFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String path;
  @override
  @JsonKey(name: 'project_id')
  final int projectId;
  @override
  final String? location;
  @override
  final String? status;
  @override
  @JsonKey(name: 'tags_count')
  final int? tagsCount;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  /// Create a copy of RegistryRepository
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RegistryRepositoryCopyWith<_RegistryRepository> get copyWith =>
      __$RegistryRepositoryCopyWithImpl<_RegistryRepository>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$RegistryRepositoryToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _RegistryRepository &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.projectId, projectId) ||
                other.projectId == projectId) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.tagsCount, tagsCount) ||
                other.tagsCount == tagsCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    path,
    projectId,
    location,
    status,
    tagsCount,
    createdAt,
  );

  @override
  String toString() {
    return 'RegistryRepository(id: $id, name: $name, path: $path, projectId: $projectId, location: $location, status: $status, tagsCount: $tagsCount, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$RegistryRepositoryCopyWith<$Res>
    implements $RegistryRepositoryCopyWith<$Res> {
  factory _$RegistryRepositoryCopyWith(
    _RegistryRepository value,
    $Res Function(_RegistryRepository) _then,
  ) = __$RegistryRepositoryCopyWithImpl;
  @override
  @useResult
  $Res call({
    int id,
    String name,
    String path,
    @JsonKey(name: 'project_id') int projectId,
    String? location,
    String? status,
    @JsonKey(name: 'tags_count') int? tagsCount,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class __$RegistryRepositoryCopyWithImpl<$Res>
    implements _$RegistryRepositoryCopyWith<$Res> {
  __$RegistryRepositoryCopyWithImpl(this._self, this._then);

  final _RegistryRepository _self;
  final $Res Function(_RegistryRepository) _then;

  /// Create a copy of RegistryRepository
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? path = null,
    Object? projectId = null,
    Object? location = freezed,
    Object? status = freezed,
    Object? tagsCount = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _RegistryRepository(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        path: null == path
            ? _self.path
            : path // ignore: cast_nullable_to_non_nullable
                  as String,
        projectId: null == projectId
            ? _self.projectId
            : projectId // ignore: cast_nullable_to_non_nullable
                  as int,
        location: freezed == location
            ? _self.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: freezed == status
            ? _self.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
        tagsCount: freezed == tagsCount
            ? _self.tagsCount
            : tagsCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        createdAt: freezed == createdAt
            ? _self.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

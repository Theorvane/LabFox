// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gitlab_package.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GitLabPackage {
  int get id;
  String get name;
  @JsonKey(name: 'package_type')
  String get packageType;
  String? get version;
  String? get status;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @JsonKey(name: 'last_downloaded_at')
  DateTime? get lastDownloadedAt;

  /// Create a copy of GitLabPackage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GitLabPackageCopyWith<GitLabPackage> get copyWith =>
      _$GitLabPackageCopyWithImpl<GitLabPackage>(
        this as GitLabPackage,
        _$identity,
      );

  /// Serializes this GitLabPackage to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GitLabPackage &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.packageType, packageType) ||
                other.packageType == packageType) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastDownloadedAt, lastDownloadedAt) ||
                other.lastDownloadedAt == lastDownloadedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    packageType,
    version,
    status,
    createdAt,
    lastDownloadedAt,
  );

  @override
  String toString() {
    return 'GitLabPackage(id: $id, name: $name, packageType: $packageType, version: $version, status: $status, createdAt: $createdAt, lastDownloadedAt: $lastDownloadedAt)';
  }
}

/// @nodoc
abstract mixin class $GitLabPackageCopyWith<$Res> {
  factory $GitLabPackageCopyWith(
    GitLabPackage value,
    $Res Function(GitLabPackage) _then,
  ) = _$GitLabPackageCopyWithImpl;
  @useResult
  $Res call({
    int id,
    String name,
    @JsonKey(name: 'package_type') String packageType,
    String? version,
    String? status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'last_downloaded_at') DateTime? lastDownloadedAt,
  });
}

/// @nodoc
class _$GitLabPackageCopyWithImpl<$Res>
    implements $GitLabPackageCopyWith<$Res> {
  _$GitLabPackageCopyWithImpl(this._self, this._then);

  final GitLabPackage _self;
  final $Res Function(GitLabPackage) _then;

  /// Create a copy of GitLabPackage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? packageType = null,
    Object? version = freezed,
    Object? status = freezed,
    Object? createdAt = freezed,
    Object? lastDownloadedAt = freezed,
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
        packageType: null == packageType
            ? _self.packageType
            : packageType // ignore: cast_nullable_to_non_nullable
                  as String,
        version: freezed == version
            ? _self.version
            : version // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: freezed == status
            ? _self.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _self.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        lastDownloadedAt: freezed == lastDownloadedAt
            ? _self.lastDownloadedAt
            : lastDownloadedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [GitLabPackage].
extension GitLabPackagePatterns on GitLabPackage {
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
    TResult Function(_GitLabPackage value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GitLabPackage() when $default != null:
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
    TResult Function(_GitLabPackage value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GitLabPackage():
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
    TResult? Function(_GitLabPackage value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GitLabPackage() when $default != null:
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
      @JsonKey(name: 'package_type') String packageType,
      String? version,
      String? status,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'last_downloaded_at') DateTime? lastDownloadedAt,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GitLabPackage() when $default != null:
        return $default(
          _that.id,
          _that.name,
          _that.packageType,
          _that.version,
          _that.status,
          _that.createdAt,
          _that.lastDownloadedAt,
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
      @JsonKey(name: 'package_type') String packageType,
      String? version,
      String? status,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'last_downloaded_at') DateTime? lastDownloadedAt,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GitLabPackage():
        return $default(
          _that.id,
          _that.name,
          _that.packageType,
          _that.version,
          _that.status,
          _that.createdAt,
          _that.lastDownloadedAt,
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
      @JsonKey(name: 'package_type') String packageType,
      String? version,
      String? status,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'last_downloaded_at') DateTime? lastDownloadedAt,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GitLabPackage() when $default != null:
        return $default(
          _that.id,
          _that.name,
          _that.packageType,
          _that.version,
          _that.status,
          _that.createdAt,
          _that.lastDownloadedAt,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _GitLabPackage implements GitLabPackage {
  const _GitLabPackage({
    required this.id,
    required this.name,
    @JsonKey(name: 'package_type') required this.packageType,
    this.version,
    this.status,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'last_downloaded_at') this.lastDownloadedAt,
  });
  factory _GitLabPackage.fromJson(Map<String, dynamic> json) =>
      _$GitLabPackageFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  @JsonKey(name: 'package_type')
  final String packageType;
  @override
  final String? version;
  @override
  final String? status;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'last_downloaded_at')
  final DateTime? lastDownloadedAt;

  /// Create a copy of GitLabPackage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GitLabPackageCopyWith<_GitLabPackage> get copyWith =>
      __$GitLabPackageCopyWithImpl<_GitLabPackage>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$GitLabPackageToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GitLabPackage &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.packageType, packageType) ||
                other.packageType == packageType) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastDownloadedAt, lastDownloadedAt) ||
                other.lastDownloadedAt == lastDownloadedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    packageType,
    version,
    status,
    createdAt,
    lastDownloadedAt,
  );

  @override
  String toString() {
    return 'GitLabPackage(id: $id, name: $name, packageType: $packageType, version: $version, status: $status, createdAt: $createdAt, lastDownloadedAt: $lastDownloadedAt)';
  }
}

/// @nodoc
abstract mixin class _$GitLabPackageCopyWith<$Res>
    implements $GitLabPackageCopyWith<$Res> {
  factory _$GitLabPackageCopyWith(
    _GitLabPackage value,
    $Res Function(_GitLabPackage) _then,
  ) = __$GitLabPackageCopyWithImpl;
  @override
  @useResult
  $Res call({
    int id,
    String name,
    @JsonKey(name: 'package_type') String packageType,
    String? version,
    String? status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'last_downloaded_at') DateTime? lastDownloadedAt,
  });
}

/// @nodoc
class __$GitLabPackageCopyWithImpl<$Res>
    implements _$GitLabPackageCopyWith<$Res> {
  __$GitLabPackageCopyWithImpl(this._self, this._then);

  final _GitLabPackage _self;
  final $Res Function(_GitLabPackage) _then;

  /// Create a copy of GitLabPackage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? packageType = null,
    Object? version = freezed,
    Object? status = freezed,
    Object? createdAt = freezed,
    Object? lastDownloadedAt = freezed,
  }) {
    return _then(
      _GitLabPackage(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        packageType: null == packageType
            ? _self.packageType
            : packageType // ignore: cast_nullable_to_non_nullable
                  as String,
        version: freezed == version
            ? _self.version
            : version // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: freezed == status
            ? _self.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _self.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        lastDownloadedAt: freezed == lastDownloadedAt
            ? _self.lastDownloadedAt
            : lastDownloadedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

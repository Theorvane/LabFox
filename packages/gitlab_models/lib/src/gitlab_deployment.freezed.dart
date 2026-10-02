// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gitlab_deployment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GitLabDeployment {
  int get id;
  int? get iid;
  String? get ref;
  String? get sha;
  String? get status;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  DeploymentEnvironment? get environment;
  DeploymentJob? get deployable;
  DeploymentActor? get user;

  /// Create a copy of GitLabDeployment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GitLabDeploymentCopyWith<GitLabDeployment> get copyWith =>
      _$GitLabDeploymentCopyWithImpl<GitLabDeployment>(
        this as GitLabDeployment,
        _$identity,
      );

  /// Serializes this GitLabDeployment to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GitLabDeployment &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.iid, iid) || other.iid == iid) &&
            (identical(other.ref, ref) || other.ref == ref) &&
            (identical(other.sha, sha) || other.sha == sha) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.environment, environment) ||
                other.environment == environment) &&
            (identical(other.deployable, deployable) ||
                other.deployable == deployable) &&
            (identical(other.user, user) || other.user == user));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    iid,
    ref,
    sha,
    status,
    createdAt,
    updatedAt,
    environment,
    deployable,
    user,
  );

  @override
  String toString() {
    return 'GitLabDeployment(id: $id, iid: $iid, ref: $ref, sha: $sha, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, environment: $environment, deployable: $deployable, user: $user)';
  }
}

/// @nodoc
abstract mixin class $GitLabDeploymentCopyWith<$Res> {
  factory $GitLabDeploymentCopyWith(
    GitLabDeployment value,
    $Res Function(GitLabDeployment) _then,
  ) = _$GitLabDeploymentCopyWithImpl;
  @useResult
  $Res call({
    int id,
    int? iid,
    String? ref,
    String? sha,
    String? status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    DeploymentEnvironment? environment,
    DeploymentJob? deployable,
    DeploymentActor? user,
  });

  $DeploymentEnvironmentCopyWith<$Res>? get environment;
  $DeploymentJobCopyWith<$Res>? get deployable;
  $DeploymentActorCopyWith<$Res>? get user;
}

/// @nodoc
class _$GitLabDeploymentCopyWithImpl<$Res>
    implements $GitLabDeploymentCopyWith<$Res> {
  _$GitLabDeploymentCopyWithImpl(this._self, this._then);

  final GitLabDeployment _self;
  final $Res Function(GitLabDeployment) _then;

  /// Create a copy of GitLabDeployment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? iid = freezed,
    Object? ref = freezed,
    Object? sha = freezed,
    Object? status = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? environment = freezed,
    Object? deployable = freezed,
    Object? user = freezed,
  }) {
    return _then(
      _self.copyWith(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        iid: freezed == iid
            ? _self.iid
            : iid // ignore: cast_nullable_to_non_nullable
                  as int?,
        ref: freezed == ref
            ? _self.ref
            : ref // ignore: cast_nullable_to_non_nullable
                  as String?,
        sha: freezed == sha
            ? _self.sha
            : sha // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: freezed == status
            ? _self.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _self.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _self.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        environment: freezed == environment
            ? _self.environment
            : environment // ignore: cast_nullable_to_non_nullable
                  as DeploymentEnvironment?,
        deployable: freezed == deployable
            ? _self.deployable
            : deployable // ignore: cast_nullable_to_non_nullable
                  as DeploymentJob?,
        user: freezed == user
            ? _self.user
            : user // ignore: cast_nullable_to_non_nullable
                  as DeploymentActor?,
      ),
    );
  }

  /// Create a copy of GitLabDeployment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DeploymentEnvironmentCopyWith<$Res>? get environment {
    if (_self.environment == null) {
      return null;
    }

    return $DeploymentEnvironmentCopyWith<$Res>(_self.environment!, (value) {
      return _then(_self.copyWith(environment: value));
    });
  }

  /// Create a copy of GitLabDeployment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DeploymentJobCopyWith<$Res>? get deployable {
    if (_self.deployable == null) {
      return null;
    }

    return $DeploymentJobCopyWith<$Res>(_self.deployable!, (value) {
      return _then(_self.copyWith(deployable: value));
    });
  }

  /// Create a copy of GitLabDeployment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DeploymentActorCopyWith<$Res>? get user {
    if (_self.user == null) {
      return null;
    }

    return $DeploymentActorCopyWith<$Res>(_self.user!, (value) {
      return _then(_self.copyWith(user: value));
    });
  }
}

/// Adds pattern-matching-related methods to [GitLabDeployment].
extension GitLabDeploymentPatterns on GitLabDeployment {
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
    TResult Function(_GitLabDeployment value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GitLabDeployment() when $default != null:
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
    TResult Function(_GitLabDeployment value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GitLabDeployment():
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
    TResult? Function(_GitLabDeployment value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GitLabDeployment() when $default != null:
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
      int? iid,
      String? ref,
      String? sha,
      String? status,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      DeploymentEnvironment? environment,
      DeploymentJob? deployable,
      DeploymentActor? user,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GitLabDeployment() when $default != null:
        return $default(
          _that.id,
          _that.iid,
          _that.ref,
          _that.sha,
          _that.status,
          _that.createdAt,
          _that.updatedAt,
          _that.environment,
          _that.deployable,
          _that.user,
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
      int? iid,
      String? ref,
      String? sha,
      String? status,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      DeploymentEnvironment? environment,
      DeploymentJob? deployable,
      DeploymentActor? user,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GitLabDeployment():
        return $default(
          _that.id,
          _that.iid,
          _that.ref,
          _that.sha,
          _that.status,
          _that.createdAt,
          _that.updatedAt,
          _that.environment,
          _that.deployable,
          _that.user,
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
      int? iid,
      String? ref,
      String? sha,
      String? status,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      DeploymentEnvironment? environment,
      DeploymentJob? deployable,
      DeploymentActor? user,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GitLabDeployment() when $default != null:
        return $default(
          _that.id,
          _that.iid,
          _that.ref,
          _that.sha,
          _that.status,
          _that.createdAt,
          _that.updatedAt,
          _that.environment,
          _that.deployable,
          _that.user,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _GitLabDeployment implements GitLabDeployment {
  const _GitLabDeployment({
    required this.id,
    this.iid,
    this.ref,
    this.sha,
    this.status,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
    this.environment,
    this.deployable,
    this.user,
  });
  factory _GitLabDeployment.fromJson(Map<String, dynamic> json) =>
      _$GitLabDeploymentFromJson(json);

  @override
  final int id;
  @override
  final int? iid;
  @override
  final String? ref;
  @override
  final String? sha;
  @override
  final String? status;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @override
  final DeploymentEnvironment? environment;
  @override
  final DeploymentJob? deployable;
  @override
  final DeploymentActor? user;

  /// Create a copy of GitLabDeployment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GitLabDeploymentCopyWith<_GitLabDeployment> get copyWith =>
      __$GitLabDeploymentCopyWithImpl<_GitLabDeployment>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$GitLabDeploymentToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GitLabDeployment &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.iid, iid) || other.iid == iid) &&
            (identical(other.ref, ref) || other.ref == ref) &&
            (identical(other.sha, sha) || other.sha == sha) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.environment, environment) ||
                other.environment == environment) &&
            (identical(other.deployable, deployable) ||
                other.deployable == deployable) &&
            (identical(other.user, user) || other.user == user));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    iid,
    ref,
    sha,
    status,
    createdAt,
    updatedAt,
    environment,
    deployable,
    user,
  );

  @override
  String toString() {
    return 'GitLabDeployment(id: $id, iid: $iid, ref: $ref, sha: $sha, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, environment: $environment, deployable: $deployable, user: $user)';
  }
}

/// @nodoc
abstract mixin class _$GitLabDeploymentCopyWith<$Res>
    implements $GitLabDeploymentCopyWith<$Res> {
  factory _$GitLabDeploymentCopyWith(
    _GitLabDeployment value,
    $Res Function(_GitLabDeployment) _then,
  ) = __$GitLabDeploymentCopyWithImpl;
  @override
  @useResult
  $Res call({
    int id,
    int? iid,
    String? ref,
    String? sha,
    String? status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    DeploymentEnvironment? environment,
    DeploymentJob? deployable,
    DeploymentActor? user,
  });

  @override
  $DeploymentEnvironmentCopyWith<$Res>? get environment;
  @override
  $DeploymentJobCopyWith<$Res>? get deployable;
  @override
  $DeploymentActorCopyWith<$Res>? get user;
}

/// @nodoc
class __$GitLabDeploymentCopyWithImpl<$Res>
    implements _$GitLabDeploymentCopyWith<$Res> {
  __$GitLabDeploymentCopyWithImpl(this._self, this._then);

  final _GitLabDeployment _self;
  final $Res Function(_GitLabDeployment) _then;

  /// Create a copy of GitLabDeployment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? iid = freezed,
    Object? ref = freezed,
    Object? sha = freezed,
    Object? status = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? environment = freezed,
    Object? deployable = freezed,
    Object? user = freezed,
  }) {
    return _then(
      _GitLabDeployment(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        iid: freezed == iid
            ? _self.iid
            : iid // ignore: cast_nullable_to_non_nullable
                  as int?,
        ref: freezed == ref
            ? _self.ref
            : ref // ignore: cast_nullable_to_non_nullable
                  as String?,
        sha: freezed == sha
            ? _self.sha
            : sha // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: freezed == status
            ? _self.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _self.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _self.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        environment: freezed == environment
            ? _self.environment
            : environment // ignore: cast_nullable_to_non_nullable
                  as DeploymentEnvironment?,
        deployable: freezed == deployable
            ? _self.deployable
            : deployable // ignore: cast_nullable_to_non_nullable
                  as DeploymentJob?,
        user: freezed == user
            ? _self.user
            : user // ignore: cast_nullable_to_non_nullable
                  as DeploymentActor?,
      ),
    );
  }

  /// Create a copy of GitLabDeployment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DeploymentEnvironmentCopyWith<$Res>? get environment {
    if (_self.environment == null) {
      return null;
    }

    return $DeploymentEnvironmentCopyWith<$Res>(_self.environment!, (value) {
      return _then(_self.copyWith(environment: value));
    });
  }

  /// Create a copy of GitLabDeployment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DeploymentJobCopyWith<$Res>? get deployable {
    if (_self.deployable == null) {
      return null;
    }

    return $DeploymentJobCopyWith<$Res>(_self.deployable!, (value) {
      return _then(_self.copyWith(deployable: value));
    });
  }

  /// Create a copy of GitLabDeployment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DeploymentActorCopyWith<$Res>? get user {
    if (_self.user == null) {
      return null;
    }

    return $DeploymentActorCopyWith<$Res>(_self.user!, (value) {
      return _then(_self.copyWith(user: value));
    });
  }
}

/// @nodoc
mixin _$DeploymentEnvironment {
  int? get id;
  String get name;
  @JsonKey(name: 'external_url')
  String? get externalUrl;

  /// Create a copy of DeploymentEnvironment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DeploymentEnvironmentCopyWith<DeploymentEnvironment> get copyWith =>
      _$DeploymentEnvironmentCopyWithImpl<DeploymentEnvironment>(
        this as DeploymentEnvironment,
        _$identity,
      );

  /// Serializes this DeploymentEnvironment to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DeploymentEnvironment &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.externalUrl, externalUrl) ||
                other.externalUrl == externalUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, externalUrl);

  @override
  String toString() {
    return 'DeploymentEnvironment(id: $id, name: $name, externalUrl: $externalUrl)';
  }
}

/// @nodoc
abstract mixin class $DeploymentEnvironmentCopyWith<$Res> {
  factory $DeploymentEnvironmentCopyWith(
    DeploymentEnvironment value,
    $Res Function(DeploymentEnvironment) _then,
  ) = _$DeploymentEnvironmentCopyWithImpl;
  @useResult
  $Res call({
    int? id,
    String name,
    @JsonKey(name: 'external_url') String? externalUrl,
  });
}

/// @nodoc
class _$DeploymentEnvironmentCopyWithImpl<$Res>
    implements $DeploymentEnvironmentCopyWith<$Res> {
  _$DeploymentEnvironmentCopyWithImpl(this._self, this._then);

  final DeploymentEnvironment _self;
  final $Res Function(DeploymentEnvironment) _then;

  /// Create a copy of DeploymentEnvironment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? externalUrl = freezed,
  }) {
    return _then(
      _self.copyWith(
        id: freezed == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        name: null == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        externalUrl: freezed == externalUrl
            ? _self.externalUrl
            : externalUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [DeploymentEnvironment].
extension DeploymentEnvironmentPatterns on DeploymentEnvironment {
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
    TResult Function(_DeploymentEnvironment value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DeploymentEnvironment() when $default != null:
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
    TResult Function(_DeploymentEnvironment value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeploymentEnvironment():
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
    TResult? Function(_DeploymentEnvironment value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeploymentEnvironment() when $default != null:
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
      int? id,
      String name,
      @JsonKey(name: 'external_url') String? externalUrl,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DeploymentEnvironment() when $default != null:
        return $default(_that.id, _that.name, _that.externalUrl);
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
      int? id,
      String name,
      @JsonKey(name: 'external_url') String? externalUrl,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeploymentEnvironment():
        return $default(_that.id, _that.name, _that.externalUrl);
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
      int? id,
      String name,
      @JsonKey(name: 'external_url') String? externalUrl,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeploymentEnvironment() when $default != null:
        return $default(_that.id, _that.name, _that.externalUrl);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _DeploymentEnvironment implements DeploymentEnvironment {
  const _DeploymentEnvironment({
    this.id,
    required this.name,
    @JsonKey(name: 'external_url') this.externalUrl,
  });
  factory _DeploymentEnvironment.fromJson(Map<String, dynamic> json) =>
      _$DeploymentEnvironmentFromJson(json);

  @override
  final int? id;
  @override
  final String name;
  @override
  @JsonKey(name: 'external_url')
  final String? externalUrl;

  /// Create a copy of DeploymentEnvironment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DeploymentEnvironmentCopyWith<_DeploymentEnvironment> get copyWith =>
      __$DeploymentEnvironmentCopyWithImpl<_DeploymentEnvironment>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$DeploymentEnvironmentToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DeploymentEnvironment &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.externalUrl, externalUrl) ||
                other.externalUrl == externalUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, externalUrl);

  @override
  String toString() {
    return 'DeploymentEnvironment(id: $id, name: $name, externalUrl: $externalUrl)';
  }
}

/// @nodoc
abstract mixin class _$DeploymentEnvironmentCopyWith<$Res>
    implements $DeploymentEnvironmentCopyWith<$Res> {
  factory _$DeploymentEnvironmentCopyWith(
    _DeploymentEnvironment value,
    $Res Function(_DeploymentEnvironment) _then,
  ) = __$DeploymentEnvironmentCopyWithImpl;
  @override
  @useResult
  $Res call({
    int? id,
    String name,
    @JsonKey(name: 'external_url') String? externalUrl,
  });
}

/// @nodoc
class __$DeploymentEnvironmentCopyWithImpl<$Res>
    implements _$DeploymentEnvironmentCopyWith<$Res> {
  __$DeploymentEnvironmentCopyWithImpl(this._self, this._then);

  final _DeploymentEnvironment _self;
  final $Res Function(_DeploymentEnvironment) _then;

  /// Create a copy of DeploymentEnvironment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? externalUrl = freezed,
  }) {
    return _then(
      _DeploymentEnvironment(
        id: freezed == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        name: null == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        externalUrl: freezed == externalUrl
            ? _self.externalUrl
            : externalUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
mixin _$DeploymentJob {
  int get id;
  String? get name;
  String? get status;
  DeploymentPipeline? get pipeline;
  DeploymentCommit? get commit;

  /// Create a copy of DeploymentJob
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DeploymentJobCopyWith<DeploymentJob> get copyWith =>
      _$DeploymentJobCopyWithImpl<DeploymentJob>(
        this as DeploymentJob,
        _$identity,
      );

  /// Serializes this DeploymentJob to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DeploymentJob &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.pipeline, pipeline) ||
                other.pipeline == pipeline) &&
            (identical(other.commit, commit) || other.commit == commit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, status, pipeline, commit);

  @override
  String toString() {
    return 'DeploymentJob(id: $id, name: $name, status: $status, pipeline: $pipeline, commit: $commit)';
  }
}

/// @nodoc
abstract mixin class $DeploymentJobCopyWith<$Res> {
  factory $DeploymentJobCopyWith(
    DeploymentJob value,
    $Res Function(DeploymentJob) _then,
  ) = _$DeploymentJobCopyWithImpl;
  @useResult
  $Res call({
    int id,
    String? name,
    String? status,
    DeploymentPipeline? pipeline,
    DeploymentCommit? commit,
  });

  $DeploymentPipelineCopyWith<$Res>? get pipeline;
  $DeploymentCommitCopyWith<$Res>? get commit;
}

/// @nodoc
class _$DeploymentJobCopyWithImpl<$Res>
    implements $DeploymentJobCopyWith<$Res> {
  _$DeploymentJobCopyWithImpl(this._self, this._then);

  final DeploymentJob _self;
  final $Res Function(DeploymentJob) _then;

  /// Create a copy of DeploymentJob
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? status = freezed,
    Object? pipeline = freezed,
    Object? commit = freezed,
  }) {
    return _then(
      _self.copyWith(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: freezed == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: freezed == status
            ? _self.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
        pipeline: freezed == pipeline
            ? _self.pipeline
            : pipeline // ignore: cast_nullable_to_non_nullable
                  as DeploymentPipeline?,
        commit: freezed == commit
            ? _self.commit
            : commit // ignore: cast_nullable_to_non_nullable
                  as DeploymentCommit?,
      ),
    );
  }

  /// Create a copy of DeploymentJob
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DeploymentPipelineCopyWith<$Res>? get pipeline {
    if (_self.pipeline == null) {
      return null;
    }

    return $DeploymentPipelineCopyWith<$Res>(_self.pipeline!, (value) {
      return _then(_self.copyWith(pipeline: value));
    });
  }

  /// Create a copy of DeploymentJob
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DeploymentCommitCopyWith<$Res>? get commit {
    if (_self.commit == null) {
      return null;
    }

    return $DeploymentCommitCopyWith<$Res>(_self.commit!, (value) {
      return _then(_self.copyWith(commit: value));
    });
  }
}

/// Adds pattern-matching-related methods to [DeploymentJob].
extension DeploymentJobPatterns on DeploymentJob {
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
    TResult Function(_DeploymentJob value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DeploymentJob() when $default != null:
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
    TResult Function(_DeploymentJob value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeploymentJob():
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
    TResult? Function(_DeploymentJob value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeploymentJob() when $default != null:
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
      String? name,
      String? status,
      DeploymentPipeline? pipeline,
      DeploymentCommit? commit,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DeploymentJob() when $default != null:
        return $default(
          _that.id,
          _that.name,
          _that.status,
          _that.pipeline,
          _that.commit,
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
      String? name,
      String? status,
      DeploymentPipeline? pipeline,
      DeploymentCommit? commit,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeploymentJob():
        return $default(
          _that.id,
          _that.name,
          _that.status,
          _that.pipeline,
          _that.commit,
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
      String? name,
      String? status,
      DeploymentPipeline? pipeline,
      DeploymentCommit? commit,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeploymentJob() when $default != null:
        return $default(
          _that.id,
          _that.name,
          _that.status,
          _that.pipeline,
          _that.commit,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _DeploymentJob implements DeploymentJob {
  const _DeploymentJob({
    required this.id,
    this.name,
    this.status,
    this.pipeline,
    this.commit,
  });
  factory _DeploymentJob.fromJson(Map<String, dynamic> json) =>
      _$DeploymentJobFromJson(json);

  @override
  final int id;
  @override
  final String? name;
  @override
  final String? status;
  @override
  final DeploymentPipeline? pipeline;
  @override
  final DeploymentCommit? commit;

  /// Create a copy of DeploymentJob
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DeploymentJobCopyWith<_DeploymentJob> get copyWith =>
      __$DeploymentJobCopyWithImpl<_DeploymentJob>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DeploymentJobToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DeploymentJob &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.pipeline, pipeline) ||
                other.pipeline == pipeline) &&
            (identical(other.commit, commit) || other.commit == commit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, status, pipeline, commit);

  @override
  String toString() {
    return 'DeploymentJob(id: $id, name: $name, status: $status, pipeline: $pipeline, commit: $commit)';
  }
}

/// @nodoc
abstract mixin class _$DeploymentJobCopyWith<$Res>
    implements $DeploymentJobCopyWith<$Res> {
  factory _$DeploymentJobCopyWith(
    _DeploymentJob value,
    $Res Function(_DeploymentJob) _then,
  ) = __$DeploymentJobCopyWithImpl;
  @override
  @useResult
  $Res call({
    int id,
    String? name,
    String? status,
    DeploymentPipeline? pipeline,
    DeploymentCommit? commit,
  });

  @override
  $DeploymentPipelineCopyWith<$Res>? get pipeline;
  @override
  $DeploymentCommitCopyWith<$Res>? get commit;
}

/// @nodoc
class __$DeploymentJobCopyWithImpl<$Res>
    implements _$DeploymentJobCopyWith<$Res> {
  __$DeploymentJobCopyWithImpl(this._self, this._then);

  final _DeploymentJob _self;
  final $Res Function(_DeploymentJob) _then;

  /// Create a copy of DeploymentJob
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? status = freezed,
    Object? pipeline = freezed,
    Object? commit = freezed,
  }) {
    return _then(
      _DeploymentJob(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: freezed == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: freezed == status
            ? _self.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
        pipeline: freezed == pipeline
            ? _self.pipeline
            : pipeline // ignore: cast_nullable_to_non_nullable
                  as DeploymentPipeline?,
        commit: freezed == commit
            ? _self.commit
            : commit // ignore: cast_nullable_to_non_nullable
                  as DeploymentCommit?,
      ),
    );
  }

  /// Create a copy of DeploymentJob
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DeploymentPipelineCopyWith<$Res>? get pipeline {
    if (_self.pipeline == null) {
      return null;
    }

    return $DeploymentPipelineCopyWith<$Res>(_self.pipeline!, (value) {
      return _then(_self.copyWith(pipeline: value));
    });
  }

  /// Create a copy of DeploymentJob
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DeploymentCommitCopyWith<$Res>? get commit {
    if (_self.commit == null) {
      return null;
    }

    return $DeploymentCommitCopyWith<$Res>(_self.commit!, (value) {
      return _then(_self.copyWith(commit: value));
    });
  }
}

/// @nodoc
mixin _$DeploymentPipeline {
  int get id;
  String? get status;

  /// Create a copy of DeploymentPipeline
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DeploymentPipelineCopyWith<DeploymentPipeline> get copyWith =>
      _$DeploymentPipelineCopyWithImpl<DeploymentPipeline>(
        this as DeploymentPipeline,
        _$identity,
      );

  /// Serializes this DeploymentPipeline to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DeploymentPipeline &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, status);

  @override
  String toString() {
    return 'DeploymentPipeline(id: $id, status: $status)';
  }
}

/// @nodoc
abstract mixin class $DeploymentPipelineCopyWith<$Res> {
  factory $DeploymentPipelineCopyWith(
    DeploymentPipeline value,
    $Res Function(DeploymentPipeline) _then,
  ) = _$DeploymentPipelineCopyWithImpl;
  @useResult
  $Res call({int id, String? status});
}

/// @nodoc
class _$DeploymentPipelineCopyWithImpl<$Res>
    implements $DeploymentPipelineCopyWith<$Res> {
  _$DeploymentPipelineCopyWithImpl(this._self, this._then);

  final DeploymentPipeline _self;
  final $Res Function(DeploymentPipeline) _then;

  /// Create a copy of DeploymentPipeline
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? status = freezed}) {
    return _then(
      _self.copyWith(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        status: freezed == status
            ? _self.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [DeploymentPipeline].
extension DeploymentPipelinePatterns on DeploymentPipeline {
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
    TResult Function(_DeploymentPipeline value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DeploymentPipeline() when $default != null:
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
    TResult Function(_DeploymentPipeline value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeploymentPipeline():
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
    TResult? Function(_DeploymentPipeline value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeploymentPipeline() when $default != null:
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
    TResult Function(int id, String? status)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DeploymentPipeline() when $default != null:
        return $default(_that.id, _that.status);
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
    TResult Function(int id, String? status) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeploymentPipeline():
        return $default(_that.id, _that.status);
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
    TResult? Function(int id, String? status)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeploymentPipeline() when $default != null:
        return $default(_that.id, _that.status);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _DeploymentPipeline implements DeploymentPipeline {
  const _DeploymentPipeline({required this.id, this.status});
  factory _DeploymentPipeline.fromJson(Map<String, dynamic> json) =>
      _$DeploymentPipelineFromJson(json);

  @override
  final int id;
  @override
  final String? status;

  /// Create a copy of DeploymentPipeline
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DeploymentPipelineCopyWith<_DeploymentPipeline> get copyWith =>
      __$DeploymentPipelineCopyWithImpl<_DeploymentPipeline>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DeploymentPipelineToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DeploymentPipeline &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, status);

  @override
  String toString() {
    return 'DeploymentPipeline(id: $id, status: $status)';
  }
}

/// @nodoc
abstract mixin class _$DeploymentPipelineCopyWith<$Res>
    implements $DeploymentPipelineCopyWith<$Res> {
  factory _$DeploymentPipelineCopyWith(
    _DeploymentPipeline value,
    $Res Function(_DeploymentPipeline) _then,
  ) = __$DeploymentPipelineCopyWithImpl;
  @override
  @useResult
  $Res call({int id, String? status});
}

/// @nodoc
class __$DeploymentPipelineCopyWithImpl<$Res>
    implements _$DeploymentPipelineCopyWith<$Res> {
  __$DeploymentPipelineCopyWithImpl(this._self, this._then);

  final _DeploymentPipeline _self;
  final $Res Function(_DeploymentPipeline) _then;

  /// Create a copy of DeploymentPipeline
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({Object? id = null, Object? status = freezed}) {
    return _then(
      _DeploymentPipeline(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        status: freezed == status
            ? _self.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
mixin _$DeploymentCommit {
  String get id;
  String? get title;

  /// Create a copy of DeploymentCommit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DeploymentCommitCopyWith<DeploymentCommit> get copyWith =>
      _$DeploymentCommitCopyWithImpl<DeploymentCommit>(
        this as DeploymentCommit,
        _$identity,
      );

  /// Serializes this DeploymentCommit to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DeploymentCommit &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title);

  @override
  String toString() {
    return 'DeploymentCommit(id: $id, title: $title)';
  }
}

/// @nodoc
abstract mixin class $DeploymentCommitCopyWith<$Res> {
  factory $DeploymentCommitCopyWith(
    DeploymentCommit value,
    $Res Function(DeploymentCommit) _then,
  ) = _$DeploymentCommitCopyWithImpl;
  @useResult
  $Res call({String id, String? title});
}

/// @nodoc
class _$DeploymentCommitCopyWithImpl<$Res>
    implements $DeploymentCommitCopyWith<$Res> {
  _$DeploymentCommitCopyWithImpl(this._self, this._then);

  final DeploymentCommit _self;
  final $Res Function(DeploymentCommit) _then;

  /// Create a copy of DeploymentCommit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? title = freezed}) {
    return _then(
      _self.copyWith(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: freezed == title
            ? _self.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [DeploymentCommit].
extension DeploymentCommitPatterns on DeploymentCommit {
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
    TResult Function(_DeploymentCommit value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DeploymentCommit() when $default != null:
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
    TResult Function(_DeploymentCommit value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeploymentCommit():
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
    TResult? Function(_DeploymentCommit value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeploymentCommit() when $default != null:
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
    TResult Function(String id, String? title)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DeploymentCommit() when $default != null:
        return $default(_that.id, _that.title);
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
    TResult Function(String id, String? title) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeploymentCommit():
        return $default(_that.id, _that.title);
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
    TResult? Function(String id, String? title)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeploymentCommit() when $default != null:
        return $default(_that.id, _that.title);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _DeploymentCommit implements DeploymentCommit {
  const _DeploymentCommit({required this.id, this.title});
  factory _DeploymentCommit.fromJson(Map<String, dynamic> json) =>
      _$DeploymentCommitFromJson(json);

  @override
  final String id;
  @override
  final String? title;

  /// Create a copy of DeploymentCommit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DeploymentCommitCopyWith<_DeploymentCommit> get copyWith =>
      __$DeploymentCommitCopyWithImpl<_DeploymentCommit>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DeploymentCommitToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DeploymentCommit &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title);

  @override
  String toString() {
    return 'DeploymentCommit(id: $id, title: $title)';
  }
}

/// @nodoc
abstract mixin class _$DeploymentCommitCopyWith<$Res>
    implements $DeploymentCommitCopyWith<$Res> {
  factory _$DeploymentCommitCopyWith(
    _DeploymentCommit value,
    $Res Function(_DeploymentCommit) _then,
  ) = __$DeploymentCommitCopyWithImpl;
  @override
  @useResult
  $Res call({String id, String? title});
}

/// @nodoc
class __$DeploymentCommitCopyWithImpl<$Res>
    implements _$DeploymentCommitCopyWith<$Res> {
  __$DeploymentCommitCopyWithImpl(this._self, this._then);

  final _DeploymentCommit _self;
  final $Res Function(_DeploymentCommit) _then;

  /// Create a copy of DeploymentCommit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({Object? id = null, Object? title = freezed}) {
    return _then(
      _DeploymentCommit(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: freezed == title
            ? _self.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
mixin _$DeploymentActor {
  int? get id;
  String? get name;
  String? get username;

  /// Create a copy of DeploymentActor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DeploymentActorCopyWith<DeploymentActor> get copyWith =>
      _$DeploymentActorCopyWithImpl<DeploymentActor>(
        this as DeploymentActor,
        _$identity,
      );

  /// Serializes this DeploymentActor to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DeploymentActor &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.username, username) ||
                other.username == username));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, username);

  @override
  String toString() {
    return 'DeploymentActor(id: $id, name: $name, username: $username)';
  }
}

/// @nodoc
abstract mixin class $DeploymentActorCopyWith<$Res> {
  factory $DeploymentActorCopyWith(
    DeploymentActor value,
    $Res Function(DeploymentActor) _then,
  ) = _$DeploymentActorCopyWithImpl;
  @useResult
  $Res call({int? id, String? name, String? username});
}

/// @nodoc
class _$DeploymentActorCopyWithImpl<$Res>
    implements $DeploymentActorCopyWith<$Res> {
  _$DeploymentActorCopyWithImpl(this._self, this._then);

  final DeploymentActor _self;
  final $Res Function(DeploymentActor) _then;

  /// Create a copy of DeploymentActor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? username = freezed,
  }) {
    return _then(
      _self.copyWith(
        id: freezed == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        name: freezed == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        username: freezed == username
            ? _self.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [DeploymentActor].
extension DeploymentActorPatterns on DeploymentActor {
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
    TResult Function(_DeploymentActor value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DeploymentActor() when $default != null:
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
    TResult Function(_DeploymentActor value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeploymentActor():
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
    TResult? Function(_DeploymentActor value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeploymentActor() when $default != null:
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
    TResult Function(int? id, String? name, String? username)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DeploymentActor() when $default != null:
        return $default(_that.id, _that.name, _that.username);
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
    TResult Function(int? id, String? name, String? username) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeploymentActor():
        return $default(_that.id, _that.name, _that.username);
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
    TResult? Function(int? id, String? name, String? username)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeploymentActor() when $default != null:
        return $default(_that.id, _that.name, _that.username);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _DeploymentActor implements DeploymentActor {
  const _DeploymentActor({this.id, this.name, this.username});
  factory _DeploymentActor.fromJson(Map<String, dynamic> json) =>
      _$DeploymentActorFromJson(json);

  @override
  final int? id;
  @override
  final String? name;
  @override
  final String? username;

  /// Create a copy of DeploymentActor
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DeploymentActorCopyWith<_DeploymentActor> get copyWith =>
      __$DeploymentActorCopyWithImpl<_DeploymentActor>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DeploymentActorToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DeploymentActor &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.username, username) ||
                other.username == username));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, username);

  @override
  String toString() {
    return 'DeploymentActor(id: $id, name: $name, username: $username)';
  }
}

/// @nodoc
abstract mixin class _$DeploymentActorCopyWith<$Res>
    implements $DeploymentActorCopyWith<$Res> {
  factory _$DeploymentActorCopyWith(
    _DeploymentActor value,
    $Res Function(_DeploymentActor) _then,
  ) = __$DeploymentActorCopyWithImpl;
  @override
  @useResult
  $Res call({int? id, String? name, String? username});
}

/// @nodoc
class __$DeploymentActorCopyWithImpl<$Res>
    implements _$DeploymentActorCopyWith<$Res> {
  __$DeploymentActorCopyWithImpl(this._self, this._then);

  final _DeploymentActor _self;
  final $Res Function(_DeploymentActor) _then;

  /// Create a copy of DeploymentActor
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? username = freezed,
  }) {
    return _then(
      _DeploymentActor(
        id: freezed == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        name: freezed == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        username: freezed == username
            ? _self.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

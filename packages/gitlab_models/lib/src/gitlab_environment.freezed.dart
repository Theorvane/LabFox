// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gitlab_environment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GitLabEnvironment {
  int get id;
  String get name;
  String get state;
  String? get slug;
  String? get tier;
  String? get description;
  @JsonKey(name: 'external_url')
  String? get externalUrl;
  @JsonKey(name: 'auto_stop_at')
  DateTime? get autoStopAt;
  @JsonKey(name: 'last_deployment')
  EnvironmentDeployment? get lastDeployment;

  /// Create a copy of GitLabEnvironment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GitLabEnvironmentCopyWith<GitLabEnvironment> get copyWith =>
      _$GitLabEnvironmentCopyWithImpl<GitLabEnvironment>(
        this as GitLabEnvironment,
        _$identity,
      );

  /// Serializes this GitLabEnvironment to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GitLabEnvironment &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.externalUrl, externalUrl) ||
                other.externalUrl == externalUrl) &&
            (identical(other.autoStopAt, autoStopAt) ||
                other.autoStopAt == autoStopAt) &&
            (identical(other.lastDeployment, lastDeployment) ||
                other.lastDeployment == lastDeployment));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    state,
    slug,
    tier,
    description,
    externalUrl,
    autoStopAt,
    lastDeployment,
  );

  @override
  String toString() {
    return 'GitLabEnvironment(id: $id, name: $name, state: $state, slug: $slug, tier: $tier, description: $description, externalUrl: $externalUrl, autoStopAt: $autoStopAt, lastDeployment: $lastDeployment)';
  }
}

/// @nodoc
abstract mixin class $GitLabEnvironmentCopyWith<$Res> {
  factory $GitLabEnvironmentCopyWith(
    GitLabEnvironment value,
    $Res Function(GitLabEnvironment) _then,
  ) = _$GitLabEnvironmentCopyWithImpl;
  @useResult
  $Res call({
    int id,
    String name,
    String state,
    String? slug,
    String? tier,
    String? description,
    @JsonKey(name: 'external_url') String? externalUrl,
    @JsonKey(name: 'auto_stop_at') DateTime? autoStopAt,
    @JsonKey(name: 'last_deployment') EnvironmentDeployment? lastDeployment,
  });

  $EnvironmentDeploymentCopyWith<$Res>? get lastDeployment;
}

/// @nodoc
class _$GitLabEnvironmentCopyWithImpl<$Res>
    implements $GitLabEnvironmentCopyWith<$Res> {
  _$GitLabEnvironmentCopyWithImpl(this._self, this._then);

  final GitLabEnvironment _self;
  final $Res Function(GitLabEnvironment) _then;

  /// Create a copy of GitLabEnvironment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? state = null,
    Object? slug = freezed,
    Object? tier = freezed,
    Object? description = freezed,
    Object? externalUrl = freezed,
    Object? autoStopAt = freezed,
    Object? lastDeployment = freezed,
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
        state: null == state
            ? _self.state
            : state // ignore: cast_nullable_to_non_nullable
                  as String,
        slug: freezed == slug
            ? _self.slug
            : slug // ignore: cast_nullable_to_non_nullable
                  as String?,
        tier: freezed == tier
            ? _self.tier
            : tier // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _self.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        externalUrl: freezed == externalUrl
            ? _self.externalUrl
            : externalUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        autoStopAt: freezed == autoStopAt
            ? _self.autoStopAt
            : autoStopAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        lastDeployment: freezed == lastDeployment
            ? _self.lastDeployment
            : lastDeployment // ignore: cast_nullable_to_non_nullable
                  as EnvironmentDeployment?,
      ),
    );
  }

  /// Create a copy of GitLabEnvironment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EnvironmentDeploymentCopyWith<$Res>? get lastDeployment {
    if (_self.lastDeployment == null) {
      return null;
    }

    return $EnvironmentDeploymentCopyWith<$Res>(_self.lastDeployment!, (value) {
      return _then(_self.copyWith(lastDeployment: value));
    });
  }
}

/// Adds pattern-matching-related methods to [GitLabEnvironment].
extension GitLabEnvironmentPatterns on GitLabEnvironment {
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
    TResult Function(_GitLabEnvironment value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GitLabEnvironment() when $default != null:
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
    TResult Function(_GitLabEnvironment value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GitLabEnvironment():
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
    TResult? Function(_GitLabEnvironment value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GitLabEnvironment() when $default != null:
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
      String state,
      String? slug,
      String? tier,
      String? description,
      @JsonKey(name: 'external_url') String? externalUrl,
      @JsonKey(name: 'auto_stop_at') DateTime? autoStopAt,
      @JsonKey(name: 'last_deployment') EnvironmentDeployment? lastDeployment,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GitLabEnvironment() when $default != null:
        return $default(
          _that.id,
          _that.name,
          _that.state,
          _that.slug,
          _that.tier,
          _that.description,
          _that.externalUrl,
          _that.autoStopAt,
          _that.lastDeployment,
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
      String state,
      String? slug,
      String? tier,
      String? description,
      @JsonKey(name: 'external_url') String? externalUrl,
      @JsonKey(name: 'auto_stop_at') DateTime? autoStopAt,
      @JsonKey(name: 'last_deployment') EnvironmentDeployment? lastDeployment,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GitLabEnvironment():
        return $default(
          _that.id,
          _that.name,
          _that.state,
          _that.slug,
          _that.tier,
          _that.description,
          _that.externalUrl,
          _that.autoStopAt,
          _that.lastDeployment,
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
      String state,
      String? slug,
      String? tier,
      String? description,
      @JsonKey(name: 'external_url') String? externalUrl,
      @JsonKey(name: 'auto_stop_at') DateTime? autoStopAt,
      @JsonKey(name: 'last_deployment') EnvironmentDeployment? lastDeployment,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GitLabEnvironment() when $default != null:
        return $default(
          _that.id,
          _that.name,
          _that.state,
          _that.slug,
          _that.tier,
          _that.description,
          _that.externalUrl,
          _that.autoStopAt,
          _that.lastDeployment,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _GitLabEnvironment implements GitLabEnvironment {
  const _GitLabEnvironment({
    required this.id,
    required this.name,
    required this.state,
    this.slug,
    this.tier,
    this.description,
    @JsonKey(name: 'external_url') this.externalUrl,
    @JsonKey(name: 'auto_stop_at') this.autoStopAt,
    @JsonKey(name: 'last_deployment') this.lastDeployment,
  });
  factory _GitLabEnvironment.fromJson(Map<String, dynamic> json) =>
      _$GitLabEnvironmentFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String state;
  @override
  final String? slug;
  @override
  final String? tier;
  @override
  final String? description;
  @override
  @JsonKey(name: 'external_url')
  final String? externalUrl;
  @override
  @JsonKey(name: 'auto_stop_at')
  final DateTime? autoStopAt;
  @override
  @JsonKey(name: 'last_deployment')
  final EnvironmentDeployment? lastDeployment;

  /// Create a copy of GitLabEnvironment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GitLabEnvironmentCopyWith<_GitLabEnvironment> get copyWith =>
      __$GitLabEnvironmentCopyWithImpl<_GitLabEnvironment>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$GitLabEnvironmentToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GitLabEnvironment &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.externalUrl, externalUrl) ||
                other.externalUrl == externalUrl) &&
            (identical(other.autoStopAt, autoStopAt) ||
                other.autoStopAt == autoStopAt) &&
            (identical(other.lastDeployment, lastDeployment) ||
                other.lastDeployment == lastDeployment));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    state,
    slug,
    tier,
    description,
    externalUrl,
    autoStopAt,
    lastDeployment,
  );

  @override
  String toString() {
    return 'GitLabEnvironment(id: $id, name: $name, state: $state, slug: $slug, tier: $tier, description: $description, externalUrl: $externalUrl, autoStopAt: $autoStopAt, lastDeployment: $lastDeployment)';
  }
}

/// @nodoc
abstract mixin class _$GitLabEnvironmentCopyWith<$Res>
    implements $GitLabEnvironmentCopyWith<$Res> {
  factory _$GitLabEnvironmentCopyWith(
    _GitLabEnvironment value,
    $Res Function(_GitLabEnvironment) _then,
  ) = __$GitLabEnvironmentCopyWithImpl;
  @override
  @useResult
  $Res call({
    int id,
    String name,
    String state,
    String? slug,
    String? tier,
    String? description,
    @JsonKey(name: 'external_url') String? externalUrl,
    @JsonKey(name: 'auto_stop_at') DateTime? autoStopAt,
    @JsonKey(name: 'last_deployment') EnvironmentDeployment? lastDeployment,
  });

  @override
  $EnvironmentDeploymentCopyWith<$Res>? get lastDeployment;
}

/// @nodoc
class __$GitLabEnvironmentCopyWithImpl<$Res>
    implements _$GitLabEnvironmentCopyWith<$Res> {
  __$GitLabEnvironmentCopyWithImpl(this._self, this._then);

  final _GitLabEnvironment _self;
  final $Res Function(_GitLabEnvironment) _then;

  /// Create a copy of GitLabEnvironment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? state = null,
    Object? slug = freezed,
    Object? tier = freezed,
    Object? description = freezed,
    Object? externalUrl = freezed,
    Object? autoStopAt = freezed,
    Object? lastDeployment = freezed,
  }) {
    return _then(
      _GitLabEnvironment(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        state: null == state
            ? _self.state
            : state // ignore: cast_nullable_to_non_nullable
                  as String,
        slug: freezed == slug
            ? _self.slug
            : slug // ignore: cast_nullable_to_non_nullable
                  as String?,
        tier: freezed == tier
            ? _self.tier
            : tier // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _self.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        externalUrl: freezed == externalUrl
            ? _self.externalUrl
            : externalUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        autoStopAt: freezed == autoStopAt
            ? _self.autoStopAt
            : autoStopAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        lastDeployment: freezed == lastDeployment
            ? _self.lastDeployment
            : lastDeployment // ignore: cast_nullable_to_non_nullable
                  as EnvironmentDeployment?,
      ),
    );
  }

  /// Create a copy of GitLabEnvironment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EnvironmentDeploymentCopyWith<$Res>? get lastDeployment {
    if (_self.lastDeployment == null) {
      return null;
    }

    return $EnvironmentDeploymentCopyWith<$Res>(_self.lastDeployment!, (value) {
      return _then(_self.copyWith(lastDeployment: value));
    });
  }
}

/// @nodoc
mixin _$EnvironmentDeployment {
  int get id;
  int? get iid;
  String? get ref;
  String? get sha;
  String? get status;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;

  /// Create a copy of EnvironmentDeployment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $EnvironmentDeploymentCopyWith<EnvironmentDeployment> get copyWith =>
      _$EnvironmentDeploymentCopyWithImpl<EnvironmentDeployment>(
        this as EnvironmentDeployment,
        _$identity,
      );

  /// Serializes this EnvironmentDeployment to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is EnvironmentDeployment &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.iid, iid) || other.iid == iid) &&
            (identical(other.ref, ref) || other.ref == ref) &&
            (identical(other.sha, sha) || other.sha == sha) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, iid, ref, sha, status, createdAt);

  @override
  String toString() {
    return 'EnvironmentDeployment(id: $id, iid: $iid, ref: $ref, sha: $sha, status: $status, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $EnvironmentDeploymentCopyWith<$Res> {
  factory $EnvironmentDeploymentCopyWith(
    EnvironmentDeployment value,
    $Res Function(EnvironmentDeployment) _then,
  ) = _$EnvironmentDeploymentCopyWithImpl;
  @useResult
  $Res call({
    int id,
    int? iid,
    String? ref,
    String? sha,
    String? status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class _$EnvironmentDeploymentCopyWithImpl<$Res>
    implements $EnvironmentDeploymentCopyWith<$Res> {
  _$EnvironmentDeploymentCopyWithImpl(this._self, this._then);

  final EnvironmentDeployment _self;
  final $Res Function(EnvironmentDeployment) _then;

  /// Create a copy of EnvironmentDeployment
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
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [EnvironmentDeployment].
extension EnvironmentDeploymentPatterns on EnvironmentDeployment {
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
    TResult Function(_EnvironmentDeployment value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EnvironmentDeployment() when $default != null:
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
    TResult Function(_EnvironmentDeployment value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EnvironmentDeployment():
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
    TResult? Function(_EnvironmentDeployment value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EnvironmentDeployment() when $default != null:
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
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EnvironmentDeployment() when $default != null:
        return $default(
          _that.id,
          _that.iid,
          _that.ref,
          _that.sha,
          _that.status,
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
      int? iid,
      String? ref,
      String? sha,
      String? status,
      @JsonKey(name: 'created_at') DateTime? createdAt,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EnvironmentDeployment():
        return $default(
          _that.id,
          _that.iid,
          _that.ref,
          _that.sha,
          _that.status,
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
      int? iid,
      String? ref,
      String? sha,
      String? status,
      @JsonKey(name: 'created_at') DateTime? createdAt,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EnvironmentDeployment() when $default != null:
        return $default(
          _that.id,
          _that.iid,
          _that.ref,
          _that.sha,
          _that.status,
          _that.createdAt,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _EnvironmentDeployment implements EnvironmentDeployment {
  const _EnvironmentDeployment({
    required this.id,
    this.iid,
    this.ref,
    this.sha,
    this.status,
    @JsonKey(name: 'created_at') this.createdAt,
  });
  factory _EnvironmentDeployment.fromJson(Map<String, dynamic> json) =>
      _$EnvironmentDeploymentFromJson(json);

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

  /// Create a copy of EnvironmentDeployment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$EnvironmentDeploymentCopyWith<_EnvironmentDeployment> get copyWith =>
      __$EnvironmentDeploymentCopyWithImpl<_EnvironmentDeployment>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$EnvironmentDeploymentToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _EnvironmentDeployment &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.iid, iid) || other.iid == iid) &&
            (identical(other.ref, ref) || other.ref == ref) &&
            (identical(other.sha, sha) || other.sha == sha) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, iid, ref, sha, status, createdAt);

  @override
  String toString() {
    return 'EnvironmentDeployment(id: $id, iid: $iid, ref: $ref, sha: $sha, status: $status, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$EnvironmentDeploymentCopyWith<$Res>
    implements $EnvironmentDeploymentCopyWith<$Res> {
  factory _$EnvironmentDeploymentCopyWith(
    _EnvironmentDeployment value,
    $Res Function(_EnvironmentDeployment) _then,
  ) = __$EnvironmentDeploymentCopyWithImpl;
  @override
  @useResult
  $Res call({
    int id,
    int? iid,
    String? ref,
    String? sha,
    String? status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class __$EnvironmentDeploymentCopyWithImpl<$Res>
    implements _$EnvironmentDeploymentCopyWith<$Res> {
  __$EnvironmentDeploymentCopyWithImpl(this._self, this._then);

  final _EnvironmentDeployment _self;
  final $Res Function(_EnvironmentDeployment) _then;

  /// Create a copy of EnvironmentDeployment
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
  }) {
    return _then(
      _EnvironmentDeployment(
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
      ),
    );
  }
}

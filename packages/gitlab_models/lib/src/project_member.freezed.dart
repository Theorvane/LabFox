// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'project_member.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProjectMember {
  int get id;
  String get username;
  String get name;
  @JsonKey(name: 'access_level')
  int get accessLevel;
  String? get state;
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl;
  @JsonKey(name: 'web_url')
  String? get webUrl;
  @JsonKey(name: 'expires_at')
  DateTime? get expiresAt;

  /// Create a copy of ProjectMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ProjectMemberCopyWith<ProjectMember> get copyWith =>
      _$ProjectMemberCopyWithImpl<ProjectMember>(
        this as ProjectMember,
        _$identity,
      );

  /// Serializes this ProjectMember to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ProjectMember &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.accessLevel, accessLevel) ||
                other.accessLevel == accessLevel) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.webUrl, webUrl) || other.webUrl == webUrl) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    username,
    name,
    accessLevel,
    state,
    avatarUrl,
    webUrl,
    expiresAt,
  );

  @override
  String toString() {
    return 'ProjectMember(id: $id, username: $username, name: $name, accessLevel: $accessLevel, state: $state, avatarUrl: $avatarUrl, webUrl: $webUrl, expiresAt: $expiresAt)';
  }
}

/// @nodoc
abstract mixin class $ProjectMemberCopyWith<$Res> {
  factory $ProjectMemberCopyWith(
    ProjectMember value,
    $Res Function(ProjectMember) _then,
  ) = _$ProjectMemberCopyWithImpl;
  @useResult
  $Res call({
    int id,
    String username,
    String name,
    @JsonKey(name: 'access_level') int accessLevel,
    String? state,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'web_url') String? webUrl,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
  });
}

/// @nodoc
class _$ProjectMemberCopyWithImpl<$Res>
    implements $ProjectMemberCopyWith<$Res> {
  _$ProjectMemberCopyWithImpl(this._self, this._then);

  final ProjectMember _self;
  final $Res Function(ProjectMember) _then;

  /// Create a copy of ProjectMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? name = null,
    Object? accessLevel = null,
    Object? state = freezed,
    Object? avatarUrl = freezed,
    Object? webUrl = freezed,
    Object? expiresAt = freezed,
  }) {
    return _then(
      _self.copyWith(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        username: null == username
            ? _self.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        accessLevel: null == accessLevel
            ? _self.accessLevel
            : accessLevel // ignore: cast_nullable_to_non_nullable
                  as int,
        state: freezed == state
            ? _self.state
            : state // ignore: cast_nullable_to_non_nullable
                  as String?,
        avatarUrl: freezed == avatarUrl
            ? _self.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        webUrl: freezed == webUrl
            ? _self.webUrl
            : webUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        expiresAt: freezed == expiresAt
            ? _self.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [ProjectMember].
extension ProjectMemberPatterns on ProjectMember {
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
    TResult Function(_ProjectMember value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProjectMember() when $default != null:
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
    TResult Function(_ProjectMember value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProjectMember():
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
    TResult? Function(_ProjectMember value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProjectMember() when $default != null:
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
      String username,
      String name,
      @JsonKey(name: 'access_level') int accessLevel,
      String? state,
      @JsonKey(name: 'avatar_url') String? avatarUrl,
      @JsonKey(name: 'web_url') String? webUrl,
      @JsonKey(name: 'expires_at') DateTime? expiresAt,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProjectMember() when $default != null:
        return $default(
          _that.id,
          _that.username,
          _that.name,
          _that.accessLevel,
          _that.state,
          _that.avatarUrl,
          _that.webUrl,
          _that.expiresAt,
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
      String username,
      String name,
      @JsonKey(name: 'access_level') int accessLevel,
      String? state,
      @JsonKey(name: 'avatar_url') String? avatarUrl,
      @JsonKey(name: 'web_url') String? webUrl,
      @JsonKey(name: 'expires_at') DateTime? expiresAt,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProjectMember():
        return $default(
          _that.id,
          _that.username,
          _that.name,
          _that.accessLevel,
          _that.state,
          _that.avatarUrl,
          _that.webUrl,
          _that.expiresAt,
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
      String username,
      String name,
      @JsonKey(name: 'access_level') int accessLevel,
      String? state,
      @JsonKey(name: 'avatar_url') String? avatarUrl,
      @JsonKey(name: 'web_url') String? webUrl,
      @JsonKey(name: 'expires_at') DateTime? expiresAt,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProjectMember() when $default != null:
        return $default(
          _that.id,
          _that.username,
          _that.name,
          _that.accessLevel,
          _that.state,
          _that.avatarUrl,
          _that.webUrl,
          _that.expiresAt,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ProjectMember implements ProjectMember {
  const _ProjectMember({
    required this.id,
    required this.username,
    required this.name,
    @JsonKey(name: 'access_level') required this.accessLevel,
    this.state,
    @JsonKey(name: 'avatar_url') this.avatarUrl,
    @JsonKey(name: 'web_url') this.webUrl,
    @JsonKey(name: 'expires_at') this.expiresAt,
  });
  factory _ProjectMember.fromJson(Map<String, dynamic> json) =>
      _$ProjectMemberFromJson(json);

  @override
  final int id;
  @override
  final String username;
  @override
  final String name;
  @override
  @JsonKey(name: 'access_level')
  final int accessLevel;
  @override
  final String? state;
  @override
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  @override
  @JsonKey(name: 'web_url')
  final String? webUrl;
  @override
  @JsonKey(name: 'expires_at')
  final DateTime? expiresAt;

  /// Create a copy of ProjectMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ProjectMemberCopyWith<_ProjectMember> get copyWith =>
      __$ProjectMemberCopyWithImpl<_ProjectMember>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ProjectMemberToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ProjectMember &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.accessLevel, accessLevel) ||
                other.accessLevel == accessLevel) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.webUrl, webUrl) || other.webUrl == webUrl) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    username,
    name,
    accessLevel,
    state,
    avatarUrl,
    webUrl,
    expiresAt,
  );

  @override
  String toString() {
    return 'ProjectMember(id: $id, username: $username, name: $name, accessLevel: $accessLevel, state: $state, avatarUrl: $avatarUrl, webUrl: $webUrl, expiresAt: $expiresAt)';
  }
}

/// @nodoc
abstract mixin class _$ProjectMemberCopyWith<$Res>
    implements $ProjectMemberCopyWith<$Res> {
  factory _$ProjectMemberCopyWith(
    _ProjectMember value,
    $Res Function(_ProjectMember) _then,
  ) = __$ProjectMemberCopyWithImpl;
  @override
  @useResult
  $Res call({
    int id,
    String username,
    String name,
    @JsonKey(name: 'access_level') int accessLevel,
    String? state,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'web_url') String? webUrl,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
  });
}

/// @nodoc
class __$ProjectMemberCopyWithImpl<$Res>
    implements _$ProjectMemberCopyWith<$Res> {
  __$ProjectMemberCopyWithImpl(this._self, this._then);

  final _ProjectMember _self;
  final $Res Function(_ProjectMember) _then;

  /// Create a copy of ProjectMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? name = null,
    Object? accessLevel = null,
    Object? state = freezed,
    Object? avatarUrl = freezed,
    Object? webUrl = freezed,
    Object? expiresAt = freezed,
  }) {
    return _then(
      _ProjectMember(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        username: null == username
            ? _self.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        accessLevel: null == accessLevel
            ? _self.accessLevel
            : accessLevel // ignore: cast_nullable_to_non_nullable
                  as int,
        state: freezed == state
            ? _self.state
            : state // ignore: cast_nullable_to_non_nullable
                  as String?,
        avatarUrl: freezed == avatarUrl
            ? _self.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        webUrl: freezed == webUrl
            ? _self.webUrl
            : webUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        expiresAt: freezed == expiresAt
            ? _self.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

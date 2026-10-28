// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'oauth_token.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OAuthToken {
  @JsonKey(name: 'access_token')
  String get accessToken;
  @JsonKey(name: 'refresh_token')
  String? get refreshToken;
  @JsonKey(name: 'token_type')
  String get tokenType;
  @JsonKey(name: 'expires_in')
  int? get expiresIn;
  @JsonKey(name: 'created_at')
  int? get createdAt;
  String? get scope;

  /// Create a copy of OAuthToken
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OAuthTokenCopyWith<OAuthToken> get copyWith =>
      _$OAuthTokenCopyWithImpl<OAuthToken>(this as OAuthToken, _$identity);

  /// Serializes this OAuthToken to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OAuthToken &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken) &&
            (identical(other.tokenType, tokenType) ||
                other.tokenType == tokenType) &&
            (identical(other.expiresIn, expiresIn) ||
                other.expiresIn == expiresIn) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.scope, scope) || other.scope == scope));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    accessToken,
    refreshToken,
    tokenType,
    expiresIn,
    createdAt,
    scope,
  );

  @override
  String toString() {
    return 'OAuthToken(accessToken: $accessToken, refreshToken: $refreshToken, tokenType: $tokenType, expiresIn: $expiresIn, createdAt: $createdAt, scope: $scope)';
  }
}

/// @nodoc
abstract mixin class $OAuthTokenCopyWith<$Res> {
  factory $OAuthTokenCopyWith(
    OAuthToken value,
    $Res Function(OAuthToken) _then,
  ) = _$OAuthTokenCopyWithImpl;
  @useResult
  $Res call({
    @JsonKey(name: 'access_token') String accessToken,
    @JsonKey(name: 'refresh_token') String? refreshToken,
    @JsonKey(name: 'token_type') String tokenType,
    @JsonKey(name: 'expires_in') int? expiresIn,
    @JsonKey(name: 'created_at') int? createdAt,
    String? scope,
  });
}

/// @nodoc
class _$OAuthTokenCopyWithImpl<$Res> implements $OAuthTokenCopyWith<$Res> {
  _$OAuthTokenCopyWithImpl(this._self, this._then);

  final OAuthToken _self;
  final $Res Function(OAuthToken) _then;

  /// Create a copy of OAuthToken
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? refreshToken = freezed,
    Object? tokenType = null,
    Object? expiresIn = freezed,
    Object? createdAt = freezed,
    Object? scope = freezed,
  }) {
    return _then(
      _self.copyWith(
        accessToken: null == accessToken
            ? _self.accessToken
            : accessToken // ignore: cast_nullable_to_non_nullable
                  as String,
        refreshToken: freezed == refreshToken
            ? _self.refreshToken
            : refreshToken // ignore: cast_nullable_to_non_nullable
                  as String?,
        tokenType: null == tokenType
            ? _self.tokenType
            : tokenType // ignore: cast_nullable_to_non_nullable
                  as String,
        expiresIn: freezed == expiresIn
            ? _self.expiresIn
            : expiresIn // ignore: cast_nullable_to_non_nullable
                  as int?,
        createdAt: freezed == createdAt
            ? _self.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as int?,
        scope: freezed == scope
            ? _self.scope
            : scope // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [OAuthToken].
extension OAuthTokenPatterns on OAuthToken {
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
    TResult Function(_OAuthToken value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OAuthToken() when $default != null:
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
    TResult Function(_OAuthToken value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OAuthToken():
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
    TResult? Function(_OAuthToken value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OAuthToken() when $default != null:
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
      @JsonKey(name: 'access_token') String accessToken,
      @JsonKey(name: 'refresh_token') String? refreshToken,
      @JsonKey(name: 'token_type') String tokenType,
      @JsonKey(name: 'expires_in') int? expiresIn,
      @JsonKey(name: 'created_at') int? createdAt,
      String? scope,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OAuthToken() when $default != null:
        return $default(
          _that.accessToken,
          _that.refreshToken,
          _that.tokenType,
          _that.expiresIn,
          _that.createdAt,
          _that.scope,
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
      @JsonKey(name: 'access_token') String accessToken,
      @JsonKey(name: 'refresh_token') String? refreshToken,
      @JsonKey(name: 'token_type') String tokenType,
      @JsonKey(name: 'expires_in') int? expiresIn,
      @JsonKey(name: 'created_at') int? createdAt,
      String? scope,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OAuthToken():
        return $default(
          _that.accessToken,
          _that.refreshToken,
          _that.tokenType,
          _that.expiresIn,
          _that.createdAt,
          _that.scope,
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
      @JsonKey(name: 'access_token') String accessToken,
      @JsonKey(name: 'refresh_token') String? refreshToken,
      @JsonKey(name: 'token_type') String tokenType,
      @JsonKey(name: 'expires_in') int? expiresIn,
      @JsonKey(name: 'created_at') int? createdAt,
      String? scope,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OAuthToken() when $default != null:
        return $default(
          _that.accessToken,
          _that.refreshToken,
          _that.tokenType,
          _that.expiresIn,
          _that.createdAt,
          _that.scope,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _OAuthToken extends OAuthToken {
  const _OAuthToken({
    @JsonKey(name: 'access_token') required this.accessToken,
    @JsonKey(name: 'refresh_token') this.refreshToken,
    @JsonKey(name: 'token_type') this.tokenType = 'bearer',
    @JsonKey(name: 'expires_in') this.expiresIn,
    @JsonKey(name: 'created_at') this.createdAt,
    this.scope,
  }) : super._();
  factory _OAuthToken.fromJson(Map<String, dynamic> json) =>
      _$OAuthTokenFromJson(json);

  @override
  @JsonKey(name: 'access_token')
  final String accessToken;
  @override
  @JsonKey(name: 'refresh_token')
  final String? refreshToken;
  @override
  @JsonKey(name: 'token_type')
  final String tokenType;
  @override
  @JsonKey(name: 'expires_in')
  final int? expiresIn;
  @override
  @JsonKey(name: 'created_at')
  final int? createdAt;
  @override
  final String? scope;

  /// Create a copy of OAuthToken
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$OAuthTokenCopyWith<_OAuthToken> get copyWith =>
      __$OAuthTokenCopyWithImpl<_OAuthToken>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$OAuthTokenToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _OAuthToken &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken) &&
            (identical(other.tokenType, tokenType) ||
                other.tokenType == tokenType) &&
            (identical(other.expiresIn, expiresIn) ||
                other.expiresIn == expiresIn) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.scope, scope) || other.scope == scope));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    accessToken,
    refreshToken,
    tokenType,
    expiresIn,
    createdAt,
    scope,
  );

  @override
  String toString() {
    return 'OAuthToken(accessToken: $accessToken, refreshToken: $refreshToken, tokenType: $tokenType, expiresIn: $expiresIn, createdAt: $createdAt, scope: $scope)';
  }
}

/// @nodoc
abstract mixin class _$OAuthTokenCopyWith<$Res>
    implements $OAuthTokenCopyWith<$Res> {
  factory _$OAuthTokenCopyWith(
    _OAuthToken value,
    $Res Function(_OAuthToken) _then,
  ) = __$OAuthTokenCopyWithImpl;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'access_token') String accessToken,
    @JsonKey(name: 'refresh_token') String? refreshToken,
    @JsonKey(name: 'token_type') String tokenType,
    @JsonKey(name: 'expires_in') int? expiresIn,
    @JsonKey(name: 'created_at') int? createdAt,
    String? scope,
  });
}

/// @nodoc
class __$OAuthTokenCopyWithImpl<$Res> implements _$OAuthTokenCopyWith<$Res> {
  __$OAuthTokenCopyWithImpl(this._self, this._then);

  final _OAuthToken _self;
  final $Res Function(_OAuthToken) _then;

  /// Create a copy of OAuthToken
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? accessToken = null,
    Object? refreshToken = freezed,
    Object? tokenType = null,
    Object? expiresIn = freezed,
    Object? createdAt = freezed,
    Object? scope = freezed,
  }) {
    return _then(
      _OAuthToken(
        accessToken: null == accessToken
            ? _self.accessToken
            : accessToken // ignore: cast_nullable_to_non_nullable
                  as String,
        refreshToken: freezed == refreshToken
            ? _self.refreshToken
            : refreshToken // ignore: cast_nullable_to_non_nullable
                  as String?,
        tokenType: null == tokenType
            ? _self.tokenType
            : tokenType // ignore: cast_nullable_to_non_nullable
                  as String,
        expiresIn: freezed == expiresIn
            ? _self.expiresIn
            : expiresIn // ignore: cast_nullable_to_non_nullable
                  as int?,
        createdAt: freezed == createdAt
            ? _self.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as int?,
        scope: freezed == scope
            ? _self.scope
            : scope // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

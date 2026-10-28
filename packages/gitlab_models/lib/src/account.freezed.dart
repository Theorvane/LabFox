// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Account {
  String get instanceUrl;
  User
  get user; // Defaulted so accounts persisted before OAuth existed read back as PAT.
  AuthMethod
  get authMethod; // The OAuth application id, kept for token refresh. Not a secret, so it may
  // live in ordinary account metadata; null for PAT accounts.
  @JsonKey(name: 'oauth_client_id')
  String? get oauthClientId;

  /// Create a copy of Account
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AccountCopyWith<Account> get copyWith =>
      _$AccountCopyWithImpl<Account>(this as Account, _$identity);

  /// Serializes this Account to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Account &&
            (identical(other.instanceUrl, instanceUrl) ||
                other.instanceUrl == instanceUrl) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.authMethod, authMethod) ||
                other.authMethod == authMethod) &&
            (identical(other.oauthClientId, oauthClientId) ||
                other.oauthClientId == oauthClientId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, instanceUrl, user, authMethod, oauthClientId);

  @override
  String toString() {
    return 'Account(instanceUrl: $instanceUrl, user: $user, authMethod: $authMethod, oauthClientId: $oauthClientId)';
  }
}

/// @nodoc
abstract mixin class $AccountCopyWith<$Res> {
  factory $AccountCopyWith(Account value, $Res Function(Account) _then) =
      _$AccountCopyWithImpl;
  @useResult
  $Res call({
    String instanceUrl,
    User user,
    AuthMethod authMethod,
    @JsonKey(name: 'oauth_client_id') String? oauthClientId,
  });

  $UserCopyWith<$Res> get user;
}

/// @nodoc
class _$AccountCopyWithImpl<$Res> implements $AccountCopyWith<$Res> {
  _$AccountCopyWithImpl(this._self, this._then);

  final Account _self;
  final $Res Function(Account) _then;

  /// Create a copy of Account
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? instanceUrl = null,
    Object? user = null,
    Object? authMethod = null,
    Object? oauthClientId = freezed,
  }) {
    return _then(
      _self.copyWith(
        instanceUrl: null == instanceUrl
            ? _self.instanceUrl
            : instanceUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        user: null == user
            ? _self.user
            : user // ignore: cast_nullable_to_non_nullable
                  as User,
        authMethod: null == authMethod
            ? _self.authMethod
            : authMethod // ignore: cast_nullable_to_non_nullable
                  as AuthMethod,
        oauthClientId: freezed == oauthClientId
            ? _self.oauthClientId
            : oauthClientId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }

  /// Create a copy of Account
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res> get user {
    return $UserCopyWith<$Res>(_self.user, (value) {
      return _then(_self.copyWith(user: value));
    });
  }
}

/// Adds pattern-matching-related methods to [Account].
extension AccountPatterns on Account {
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
    TResult Function(_Account value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Account() when $default != null:
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
    TResult Function(_Account value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Account():
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
    TResult? Function(_Account value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Account() when $default != null:
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
      String instanceUrl,
      User user,
      AuthMethod authMethod,
      @JsonKey(name: 'oauth_client_id') String? oauthClientId,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Account() when $default != null:
        return $default(
          _that.instanceUrl,
          _that.user,
          _that.authMethod,
          _that.oauthClientId,
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
      String instanceUrl,
      User user,
      AuthMethod authMethod,
      @JsonKey(name: 'oauth_client_id') String? oauthClientId,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Account():
        return $default(
          _that.instanceUrl,
          _that.user,
          _that.authMethod,
          _that.oauthClientId,
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
      String instanceUrl,
      User user,
      AuthMethod authMethod,
      @JsonKey(name: 'oauth_client_id') String? oauthClientId,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Account() when $default != null:
        return $default(
          _that.instanceUrl,
          _that.user,
          _that.authMethod,
          _that.oauthClientId,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Account extends Account {
  const _Account({
    required this.instanceUrl,
    required this.user,
    this.authMethod = AuthMethod.pat,
    @JsonKey(name: 'oauth_client_id') this.oauthClientId,
  }) : super._();
  factory _Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);

  @override
  final String instanceUrl;
  @override
  final User user;
  // Defaulted so accounts persisted before OAuth existed read back as PAT.
  @override
  @JsonKey()
  final AuthMethod authMethod;
  // The OAuth application id, kept for token refresh. Not a secret, so it may
  // live in ordinary account metadata; null for PAT accounts.
  @override
  @JsonKey(name: 'oauth_client_id')
  final String? oauthClientId;

  /// Create a copy of Account
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AccountCopyWith<_Account> get copyWith =>
      __$AccountCopyWithImpl<_Account>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AccountToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Account &&
            (identical(other.instanceUrl, instanceUrl) ||
                other.instanceUrl == instanceUrl) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.authMethod, authMethod) ||
                other.authMethod == authMethod) &&
            (identical(other.oauthClientId, oauthClientId) ||
                other.oauthClientId == oauthClientId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, instanceUrl, user, authMethod, oauthClientId);

  @override
  String toString() {
    return 'Account(instanceUrl: $instanceUrl, user: $user, authMethod: $authMethod, oauthClientId: $oauthClientId)';
  }
}

/// @nodoc
abstract mixin class _$AccountCopyWith<$Res> implements $AccountCopyWith<$Res> {
  factory _$AccountCopyWith(_Account value, $Res Function(_Account) _then) =
      __$AccountCopyWithImpl;
  @override
  @useResult
  $Res call({
    String instanceUrl,
    User user,
    AuthMethod authMethod,
    @JsonKey(name: 'oauth_client_id') String? oauthClientId,
  });

  @override
  $UserCopyWith<$Res> get user;
}

/// @nodoc
class __$AccountCopyWithImpl<$Res> implements _$AccountCopyWith<$Res> {
  __$AccountCopyWithImpl(this._self, this._then);

  final _Account _self;
  final $Res Function(_Account) _then;

  /// Create a copy of Account
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? instanceUrl = null,
    Object? user = null,
    Object? authMethod = null,
    Object? oauthClientId = freezed,
  }) {
    return _then(
      _Account(
        instanceUrl: null == instanceUrl
            ? _self.instanceUrl
            : instanceUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        user: null == user
            ? _self.user
            : user // ignore: cast_nullable_to_non_nullable
                  as User,
        authMethod: null == authMethod
            ? _self.authMethod
            : authMethod // ignore: cast_nullable_to_non_nullable
                  as AuthMethod,
        oauthClientId: freezed == oauthClientId
            ? _self.oauthClientId
            : oauthClientId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }

  /// Create a copy of Account
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res> get user {
    return $UserCopyWith<$Res>(_self.user, (value) {
      return _then(_self.copyWith(user: value));
    });
  }
}

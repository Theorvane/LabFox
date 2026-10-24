// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'merge_request_reviewer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MergeRequestReviewer {
  User get user;
  String get state;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;

  /// Create a copy of MergeRequestReviewer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MergeRequestReviewerCopyWith<MergeRequestReviewer> get copyWith =>
      _$MergeRequestReviewerCopyWithImpl<MergeRequestReviewer>(
        this as MergeRequestReviewer,
        _$identity,
      );

  /// Serializes this MergeRequestReviewer to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MergeRequestReviewer &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, user, state, createdAt);

  @override
  String toString() {
    return 'MergeRequestReviewer(user: $user, state: $state, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $MergeRequestReviewerCopyWith<$Res> {
  factory $MergeRequestReviewerCopyWith(
    MergeRequestReviewer value,
    $Res Function(MergeRequestReviewer) _then,
  ) = _$MergeRequestReviewerCopyWithImpl;
  @useResult
  $Res call({
    User user,
    String state,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });

  $UserCopyWith<$Res> get user;
}

/// @nodoc
class _$MergeRequestReviewerCopyWithImpl<$Res>
    implements $MergeRequestReviewerCopyWith<$Res> {
  _$MergeRequestReviewerCopyWithImpl(this._self, this._then);

  final MergeRequestReviewer _self;
  final $Res Function(MergeRequestReviewer) _then;

  /// Create a copy of MergeRequestReviewer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? state = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _self.copyWith(
        user: null == user
            ? _self.user
            : user // ignore: cast_nullable_to_non_nullable
                  as User,
        state: null == state
            ? _self.state
            : state // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: freezed == createdAt
            ? _self.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }

  /// Create a copy of MergeRequestReviewer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res> get user {
    return $UserCopyWith<$Res>(_self.user, (value) {
      return _then(_self.copyWith(user: value));
    });
  }
}

/// Adds pattern-matching-related methods to [MergeRequestReviewer].
extension MergeRequestReviewerPatterns on MergeRequestReviewer {
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
    TResult Function(_MergeRequestReviewer value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MergeRequestReviewer() when $default != null:
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
    TResult Function(_MergeRequestReviewer value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MergeRequestReviewer():
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
    TResult? Function(_MergeRequestReviewer value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MergeRequestReviewer() when $default != null:
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
      User user,
      String state,
      @JsonKey(name: 'created_at') DateTime? createdAt,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MergeRequestReviewer() when $default != null:
        return $default(_that.user, _that.state, _that.createdAt);
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
      User user,
      String state,
      @JsonKey(name: 'created_at') DateTime? createdAt,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MergeRequestReviewer():
        return $default(_that.user, _that.state, _that.createdAt);
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
      User user,
      String state,
      @JsonKey(name: 'created_at') DateTime? createdAt,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MergeRequestReviewer() when $default != null:
        return $default(_that.user, _that.state, _that.createdAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _MergeRequestReviewer implements MergeRequestReviewer {
  const _MergeRequestReviewer({
    required this.user,
    required this.state,
    @JsonKey(name: 'created_at') this.createdAt,
  });
  factory _MergeRequestReviewer.fromJson(Map<String, dynamic> json) =>
      _$MergeRequestReviewerFromJson(json);

  @override
  final User user;
  @override
  final String state;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  /// Create a copy of MergeRequestReviewer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MergeRequestReviewerCopyWith<_MergeRequestReviewer> get copyWith =>
      __$MergeRequestReviewerCopyWithImpl<_MergeRequestReviewer>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$MergeRequestReviewerToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MergeRequestReviewer &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, user, state, createdAt);

  @override
  String toString() {
    return 'MergeRequestReviewer(user: $user, state: $state, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$MergeRequestReviewerCopyWith<$Res>
    implements $MergeRequestReviewerCopyWith<$Res> {
  factory _$MergeRequestReviewerCopyWith(
    _MergeRequestReviewer value,
    $Res Function(_MergeRequestReviewer) _then,
  ) = __$MergeRequestReviewerCopyWithImpl;
  @override
  @useResult
  $Res call({
    User user,
    String state,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });

  @override
  $UserCopyWith<$Res> get user;
}

/// @nodoc
class __$MergeRequestReviewerCopyWithImpl<$Res>
    implements _$MergeRequestReviewerCopyWith<$Res> {
  __$MergeRequestReviewerCopyWithImpl(this._self, this._then);

  final _MergeRequestReviewer _self;
  final $Res Function(_MergeRequestReviewer) _then;

  /// Create a copy of MergeRequestReviewer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? user = null,
    Object? state = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _MergeRequestReviewer(
        user: null == user
            ? _self.user
            : user // ignore: cast_nullable_to_non_nullable
                  as User,
        state: null == state
            ? _self.state
            : state // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: freezed == createdAt
            ? _self.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }

  /// Create a copy of MergeRequestReviewer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res> get user {
    return $UserCopyWith<$Res>(_self.user, (value) {
      return _then(_self.copyWith(user: value));
    });
  }
}

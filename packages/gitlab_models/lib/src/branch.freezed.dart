// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'branch.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Branch {
  String get name;
  @JsonKey(name: 'default')
  bool get isDefault;
  @JsonKey(name: 'protected')
  bool get isProtected;
  Commit? get commit;

  /// Create a copy of Branch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $BranchCopyWith<Branch> get copyWith =>
      _$BranchCopyWithImpl<Branch>(this as Branch, _$identity);

  /// Serializes this Branch to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Branch &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault) &&
            (identical(other.isProtected, isProtected) ||
                other.isProtected == isProtected) &&
            (identical(other.commit, commit) || other.commit == commit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, isDefault, isProtected, commit);

  @override
  String toString() {
    return 'Branch(name: $name, isDefault: $isDefault, isProtected: $isProtected, commit: $commit)';
  }
}

/// @nodoc
abstract mixin class $BranchCopyWith<$Res> {
  factory $BranchCopyWith(Branch value, $Res Function(Branch) _then) =
      _$BranchCopyWithImpl;
  @useResult
  $Res call({
    String name,
    @JsonKey(name: 'default') bool isDefault,
    @JsonKey(name: 'protected') bool isProtected,
    Commit? commit,
  });

  $CommitCopyWith<$Res>? get commit;
}

/// @nodoc
class _$BranchCopyWithImpl<$Res> implements $BranchCopyWith<$Res> {
  _$BranchCopyWithImpl(this._self, this._then);

  final Branch _self;
  final $Res Function(Branch) _then;

  /// Create a copy of Branch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? isDefault = null,
    Object? isProtected = null,
    Object? commit = freezed,
  }) {
    return _then(
      _self.copyWith(
        name: null == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        isDefault: null == isDefault
            ? _self.isDefault
            : isDefault // ignore: cast_nullable_to_non_nullable
                  as bool,
        isProtected: null == isProtected
            ? _self.isProtected
            : isProtected // ignore: cast_nullable_to_non_nullable
                  as bool,
        commit: freezed == commit
            ? _self.commit
            : commit // ignore: cast_nullable_to_non_nullable
                  as Commit?,
      ),
    );
  }

  /// Create a copy of Branch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CommitCopyWith<$Res>? get commit {
    if (_self.commit == null) {
      return null;
    }

    return $CommitCopyWith<$Res>(_self.commit!, (value) {
      return _then(_self.copyWith(commit: value));
    });
  }
}

/// Adds pattern-matching-related methods to [Branch].
extension BranchPatterns on Branch {
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
    TResult Function(_Branch value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Branch() when $default != null:
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
    TResult Function(_Branch value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Branch():
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
    TResult? Function(_Branch value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Branch() when $default != null:
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
      @JsonKey(name: 'default') bool isDefault,
      @JsonKey(name: 'protected') bool isProtected,
      Commit? commit,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Branch() when $default != null:
        return $default(
          _that.name,
          _that.isDefault,
          _that.isProtected,
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
      String name,
      @JsonKey(name: 'default') bool isDefault,
      @JsonKey(name: 'protected') bool isProtected,
      Commit? commit,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Branch():
        return $default(
          _that.name,
          _that.isDefault,
          _that.isProtected,
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
      String name,
      @JsonKey(name: 'default') bool isDefault,
      @JsonKey(name: 'protected') bool isProtected,
      Commit? commit,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Branch() when $default != null:
        return $default(
          _that.name,
          _that.isDefault,
          _that.isProtected,
          _that.commit,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Branch implements Branch {
  const _Branch({
    required this.name,
    @JsonKey(name: 'default') this.isDefault = false,
    @JsonKey(name: 'protected') this.isProtected = false,
    this.commit,
  });
  factory _Branch.fromJson(Map<String, dynamic> json) => _$BranchFromJson(json);

  @override
  final String name;
  @override
  @JsonKey(name: 'default')
  final bool isDefault;
  @override
  @JsonKey(name: 'protected')
  final bool isProtected;
  @override
  final Commit? commit;

  /// Create a copy of Branch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$BranchCopyWith<_Branch> get copyWith =>
      __$BranchCopyWithImpl<_Branch>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$BranchToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Branch &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault) &&
            (identical(other.isProtected, isProtected) ||
                other.isProtected == isProtected) &&
            (identical(other.commit, commit) || other.commit == commit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, isDefault, isProtected, commit);

  @override
  String toString() {
    return 'Branch(name: $name, isDefault: $isDefault, isProtected: $isProtected, commit: $commit)';
  }
}

/// @nodoc
abstract mixin class _$BranchCopyWith<$Res> implements $BranchCopyWith<$Res> {
  factory _$BranchCopyWith(_Branch value, $Res Function(_Branch) _then) =
      __$BranchCopyWithImpl;
  @override
  @useResult
  $Res call({
    String name,
    @JsonKey(name: 'default') bool isDefault,
    @JsonKey(name: 'protected') bool isProtected,
    Commit? commit,
  });

  @override
  $CommitCopyWith<$Res>? get commit;
}

/// @nodoc
class __$BranchCopyWithImpl<$Res> implements _$BranchCopyWith<$Res> {
  __$BranchCopyWithImpl(this._self, this._then);

  final _Branch _self;
  final $Res Function(_Branch) _then;

  /// Create a copy of Branch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? name = null,
    Object? isDefault = null,
    Object? isProtected = null,
    Object? commit = freezed,
  }) {
    return _then(
      _Branch(
        name: null == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        isDefault: null == isDefault
            ? _self.isDefault
            : isDefault // ignore: cast_nullable_to_non_nullable
                  as bool,
        isProtected: null == isProtected
            ? _self.isProtected
            : isProtected // ignore: cast_nullable_to_non_nullable
                  as bool,
        commit: freezed == commit
            ? _self.commit
            : commit // ignore: cast_nullable_to_non_nullable
                  as Commit?,
      ),
    );
  }

  /// Create a copy of Branch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CommitCopyWith<$Res>? get commit {
    if (_self.commit == null) {
      return null;
    }

    return $CommitCopyWith<$Res>(_self.commit!, (value) {
      return _then(_self.copyWith(commit: value));
    });
  }
}

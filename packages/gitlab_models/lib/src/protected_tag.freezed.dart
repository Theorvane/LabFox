// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'protected_tag.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProtectedTag {
  String get name;
  @JsonKey(name: 'create_access_levels')
  List<ProtectedBranchAccess> get createAccessLevels;

  /// Create a copy of ProtectedTag
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ProtectedTagCopyWith<ProtectedTag> get copyWith =>
      _$ProtectedTagCopyWithImpl<ProtectedTag>(
        this as ProtectedTag,
        _$identity,
      );

  /// Serializes this ProtectedTag to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ProtectedTag &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(
              other.createAccessLevels,
              createAccessLevels,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    const DeepCollectionEquality().hash(createAccessLevels),
  );

  @override
  String toString() {
    return 'ProtectedTag(name: $name, createAccessLevels: $createAccessLevels)';
  }
}

/// @nodoc
abstract mixin class $ProtectedTagCopyWith<$Res> {
  factory $ProtectedTagCopyWith(
    ProtectedTag value,
    $Res Function(ProtectedTag) _then,
  ) = _$ProtectedTagCopyWithImpl;
  @useResult
  $Res call({
    String name,
    @JsonKey(name: 'create_access_levels')
    List<ProtectedBranchAccess> createAccessLevels,
  });
}

/// @nodoc
class _$ProtectedTagCopyWithImpl<$Res> implements $ProtectedTagCopyWith<$Res> {
  _$ProtectedTagCopyWithImpl(this._self, this._then);

  final ProtectedTag _self;
  final $Res Function(ProtectedTag) _then;

  /// Create a copy of ProtectedTag
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? createAccessLevels = null}) {
    return _then(
      _self.copyWith(
        name: null == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        createAccessLevels: null == createAccessLevels
            ? _self.createAccessLevels
            : createAccessLevels // ignore: cast_nullable_to_non_nullable
                  as List<ProtectedBranchAccess>,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [ProtectedTag].
extension ProtectedTagPatterns on ProtectedTag {
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
    TResult Function(_ProtectedTag value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProtectedTag() when $default != null:
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
    TResult Function(_ProtectedTag value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProtectedTag():
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
    TResult? Function(_ProtectedTag value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProtectedTag() when $default != null:
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
      @JsonKey(name: 'create_access_levels')
      List<ProtectedBranchAccess> createAccessLevels,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProtectedTag() when $default != null:
        return $default(_that.name, _that.createAccessLevels);
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
      @JsonKey(name: 'create_access_levels')
      List<ProtectedBranchAccess> createAccessLevels,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProtectedTag():
        return $default(_that.name, _that.createAccessLevels);
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
      @JsonKey(name: 'create_access_levels')
      List<ProtectedBranchAccess> createAccessLevels,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProtectedTag() when $default != null:
        return $default(_that.name, _that.createAccessLevels);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ProtectedTag implements ProtectedTag {
  const _ProtectedTag({
    required this.name,
    @JsonKey(name: 'create_access_levels')
    final List<ProtectedBranchAccess> createAccessLevels =
        const <ProtectedBranchAccess>[],
  }) : _createAccessLevels = createAccessLevels;
  factory _ProtectedTag.fromJson(Map<String, dynamic> json) =>
      _$ProtectedTagFromJson(json);

  @override
  final String name;
  final List<ProtectedBranchAccess> _createAccessLevels;
  @override
  @JsonKey(name: 'create_access_levels')
  List<ProtectedBranchAccess> get createAccessLevels {
    if (_createAccessLevels is EqualUnmodifiableListView)
      return _createAccessLevels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_createAccessLevels);
  }

  /// Create a copy of ProtectedTag
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ProtectedTagCopyWith<_ProtectedTag> get copyWith =>
      __$ProtectedTagCopyWithImpl<_ProtectedTag>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ProtectedTagToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ProtectedTag &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(
              other._createAccessLevels,
              _createAccessLevels,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    const DeepCollectionEquality().hash(_createAccessLevels),
  );

  @override
  String toString() {
    return 'ProtectedTag(name: $name, createAccessLevels: $createAccessLevels)';
  }
}

/// @nodoc
abstract mixin class _$ProtectedTagCopyWith<$Res>
    implements $ProtectedTagCopyWith<$Res> {
  factory _$ProtectedTagCopyWith(
    _ProtectedTag value,
    $Res Function(_ProtectedTag) _then,
  ) = __$ProtectedTagCopyWithImpl;
  @override
  @useResult
  $Res call({
    String name,
    @JsonKey(name: 'create_access_levels')
    List<ProtectedBranchAccess> createAccessLevels,
  });
}

/// @nodoc
class __$ProtectedTagCopyWithImpl<$Res>
    implements _$ProtectedTagCopyWith<$Res> {
  __$ProtectedTagCopyWithImpl(this._self, this._then);

  final _ProtectedTag _self;
  final $Res Function(_ProtectedTag) _then;

  /// Create a copy of ProtectedTag
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({Object? name = null, Object? createAccessLevels = null}) {
    return _then(
      _ProtectedTag(
        name: null == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        createAccessLevels: null == createAccessLevels
            ? _self._createAccessLevels
            : createAccessLevels // ignore: cast_nullable_to_non_nullable
                  as List<ProtectedBranchAccess>,
      ),
    );
  }
}

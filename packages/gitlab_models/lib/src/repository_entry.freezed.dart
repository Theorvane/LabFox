// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'repository_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RepositoryEntry {
  String get id;
  String get name;
  String get type;
  String get path;

  /// Create a copy of RepositoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RepositoryEntryCopyWith<RepositoryEntry> get copyWith =>
      _$RepositoryEntryCopyWithImpl<RepositoryEntry>(
        this as RepositoryEntry,
        _$identity,
      );

  /// Serializes this RepositoryEntry to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RepositoryEntry &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.path, path) || other.path == path));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, type, path);

  @override
  String toString() {
    return 'RepositoryEntry(id: $id, name: $name, type: $type, path: $path)';
  }
}

/// @nodoc
abstract mixin class $RepositoryEntryCopyWith<$Res> {
  factory $RepositoryEntryCopyWith(
    RepositoryEntry value,
    $Res Function(RepositoryEntry) _then,
  ) = _$RepositoryEntryCopyWithImpl;
  @useResult
  $Res call({String id, String name, String type, String path});
}

/// @nodoc
class _$RepositoryEntryCopyWithImpl<$Res>
    implements $RepositoryEntryCopyWith<$Res> {
  _$RepositoryEntryCopyWithImpl(this._self, this._then);

  final RepositoryEntry _self;
  final $Res Function(RepositoryEntry) _then;

  /// Create a copy of RepositoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? path = null,
  }) {
    return _then(
      _self.copyWith(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _self.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        path: null == path
            ? _self.path
            : path // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [RepositoryEntry].
extension RepositoryEntryPatterns on RepositoryEntry {
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
    TResult Function(_RepositoryEntry value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RepositoryEntry() when $default != null:
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
    TResult Function(_RepositoryEntry value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RepositoryEntry():
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
    TResult? Function(_RepositoryEntry value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RepositoryEntry() when $default != null:
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
    TResult Function(String id, String name, String type, String path)?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RepositoryEntry() when $default != null:
        return $default(_that.id, _that.name, _that.type, _that.path);
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
    TResult Function(String id, String name, String type, String path) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RepositoryEntry():
        return $default(_that.id, _that.name, _that.type, _that.path);
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
    TResult? Function(String id, String name, String type, String path)?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RepositoryEntry() when $default != null:
        return $default(_that.id, _that.name, _that.type, _that.path);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _RepositoryEntry extends RepositoryEntry {
  const _RepositoryEntry({
    required this.id,
    required this.name,
    required this.type,
    required this.path,
  }) : super._();
  factory _RepositoryEntry.fromJson(Map<String, dynamic> json) =>
      _$RepositoryEntryFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String type;
  @override
  final String path;

  /// Create a copy of RepositoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RepositoryEntryCopyWith<_RepositoryEntry> get copyWith =>
      __$RepositoryEntryCopyWithImpl<_RepositoryEntry>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$RepositoryEntryToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _RepositoryEntry &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.path, path) || other.path == path));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, type, path);

  @override
  String toString() {
    return 'RepositoryEntry(id: $id, name: $name, type: $type, path: $path)';
  }
}

/// @nodoc
abstract mixin class _$RepositoryEntryCopyWith<$Res>
    implements $RepositoryEntryCopyWith<$Res> {
  factory _$RepositoryEntryCopyWith(
    _RepositoryEntry value,
    $Res Function(_RepositoryEntry) _then,
  ) = __$RepositoryEntryCopyWithImpl;
  @override
  @useResult
  $Res call({String id, String name, String type, String path});
}

/// @nodoc
class __$RepositoryEntryCopyWithImpl<$Res>
    implements _$RepositoryEntryCopyWith<$Res> {
  __$RepositoryEntryCopyWithImpl(this._self, this._then);

  final _RepositoryEntry _self;
  final $Res Function(_RepositoryEntry) _then;

  /// Create a copy of RepositoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? path = null,
  }) {
    return _then(
      _RepositoryEntry(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _self.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        path: null == path
            ? _self.path
            : path // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

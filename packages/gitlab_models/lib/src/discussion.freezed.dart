// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'discussion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Discussion {
  String get id;
  @JsonKey(name: 'individual_note')
  bool get individualNote;
  List<Note> get notes;

  /// Create a copy of Discussion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DiscussionCopyWith<Discussion> get copyWith =>
      _$DiscussionCopyWithImpl<Discussion>(this as Discussion, _$identity);

  /// Serializes this Discussion to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Discussion &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.individualNote, individualNote) ||
                other.individualNote == individualNote) &&
            const DeepCollectionEquality().equals(other.notes, notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    individualNote,
    const DeepCollectionEquality().hash(notes),
  );

  @override
  String toString() {
    return 'Discussion(id: $id, individualNote: $individualNote, notes: $notes)';
  }
}

/// @nodoc
abstract mixin class $DiscussionCopyWith<$Res> {
  factory $DiscussionCopyWith(
    Discussion value,
    $Res Function(Discussion) _then,
  ) = _$DiscussionCopyWithImpl;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'individual_note') bool individualNote,
    List<Note> notes,
  });
}

/// @nodoc
class _$DiscussionCopyWithImpl<$Res> implements $DiscussionCopyWith<$Res> {
  _$DiscussionCopyWithImpl(this._self, this._then);

  final Discussion _self;
  final $Res Function(Discussion) _then;

  /// Create a copy of Discussion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? individualNote = null,
    Object? notes = null,
  }) {
    return _then(
      _self.copyWith(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        individualNote: null == individualNote
            ? _self.individualNote
            : individualNote // ignore: cast_nullable_to_non_nullable
                  as bool,
        notes: null == notes
            ? _self.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as List<Note>,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [Discussion].
extension DiscussionPatterns on Discussion {
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
    TResult Function(_Discussion value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Discussion() when $default != null:
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
    TResult Function(_Discussion value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Discussion():
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
    TResult? Function(_Discussion value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Discussion() when $default != null:
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
      String id,
      @JsonKey(name: 'individual_note') bool individualNote,
      List<Note> notes,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Discussion() when $default != null:
        return $default(_that.id, _that.individualNote, _that.notes);
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
      String id,
      @JsonKey(name: 'individual_note') bool individualNote,
      List<Note> notes,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Discussion():
        return $default(_that.id, _that.individualNote, _that.notes);
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
      String id,
      @JsonKey(name: 'individual_note') bool individualNote,
      List<Note> notes,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Discussion() when $default != null:
        return $default(_that.id, _that.individualNote, _that.notes);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Discussion implements Discussion {
  const _Discussion({
    required this.id,
    @JsonKey(name: 'individual_note') required this.individualNote,
    required final List<Note> notes,
  }) : _notes = notes;
  factory _Discussion.fromJson(Map<String, dynamic> json) =>
      _$DiscussionFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'individual_note')
  final bool individualNote;
  final List<Note> _notes;
  @override
  List<Note> get notes {
    if (_notes is EqualUnmodifiableListView) return _notes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notes);
  }

  /// Create a copy of Discussion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DiscussionCopyWith<_Discussion> get copyWith =>
      __$DiscussionCopyWithImpl<_Discussion>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DiscussionToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Discussion &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.individualNote, individualNote) ||
                other.individualNote == individualNote) &&
            const DeepCollectionEquality().equals(other._notes, _notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    individualNote,
    const DeepCollectionEquality().hash(_notes),
  );

  @override
  String toString() {
    return 'Discussion(id: $id, individualNote: $individualNote, notes: $notes)';
  }
}

/// @nodoc
abstract mixin class _$DiscussionCopyWith<$Res>
    implements $DiscussionCopyWith<$Res> {
  factory _$DiscussionCopyWith(
    _Discussion value,
    $Res Function(_Discussion) _then,
  ) = __$DiscussionCopyWithImpl;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'individual_note') bool individualNote,
    List<Note> notes,
  });
}

/// @nodoc
class __$DiscussionCopyWithImpl<$Res> implements _$DiscussionCopyWith<$Res> {
  __$DiscussionCopyWithImpl(this._self, this._then);

  final _Discussion _self;
  final $Res Function(_Discussion) _then;

  /// Create a copy of Discussion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? individualNote = null,
    Object? notes = null,
  }) {
    return _then(
      _Discussion(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        individualNote: null == individualNote
            ? _self.individualNote
            : individualNote // ignore: cast_nullable_to_non_nullable
                  as bool,
        notes: null == notes
            ? _self._notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as List<Note>,
      ),
    );
  }
}

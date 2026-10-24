// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'note.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Note {
  int get id;
  String get body;
  @JsonKey(name: 'system')
  bool get isSystem;
  User? get author;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  String? get type;
  DiffNotePosition? get position;
  List<Suggestion>? get suggestions;
  bool? get resolvable;
  bool? get resolved;
  @JsonKey(name: 'resolved_by')
  User? get resolvedBy;
  @JsonKey(name: 'resolved_at')
  DateTime? get resolvedAt;

  /// Create a copy of Note
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $NoteCopyWith<Note> get copyWith =>
      _$NoteCopyWithImpl<Note>(this as Note, _$identity);

  /// Serializes this Note to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Note &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.isSystem, isSystem) ||
                other.isSystem == isSystem) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.position, position) ||
                other.position == position) &&
            const DeepCollectionEquality().equals(
              other.suggestions,
              suggestions,
            ) &&
            (identical(other.resolvable, resolvable) ||
                other.resolvable == resolvable) &&
            (identical(other.resolved, resolved) ||
                other.resolved == resolved) &&
            (identical(other.resolvedBy, resolvedBy) ||
                other.resolvedBy == resolvedBy) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    body,
    isSystem,
    author,
    createdAt,
    updatedAt,
    type,
    position,
    const DeepCollectionEquality().hash(suggestions),
    resolvable,
    resolved,
    resolvedBy,
    resolvedAt,
  );

  @override
  String toString() {
    return 'Note(id: $id, body: $body, isSystem: $isSystem, author: $author, createdAt: $createdAt, updatedAt: $updatedAt, type: $type, position: $position, suggestions: $suggestions, resolvable: $resolvable, resolved: $resolved, resolvedBy: $resolvedBy, resolvedAt: $resolvedAt)';
  }
}

/// @nodoc
abstract mixin class $NoteCopyWith<$Res> {
  factory $NoteCopyWith(Note value, $Res Function(Note) _then) =
      _$NoteCopyWithImpl;
  @useResult
  $Res call({
    int id,
    String body,
    @JsonKey(name: 'system') bool isSystem,
    User? author,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    String? type,
    DiffNotePosition? position,
    List<Suggestion>? suggestions,
    bool? resolvable,
    bool? resolved,
    @JsonKey(name: 'resolved_by') User? resolvedBy,
    @JsonKey(name: 'resolved_at') DateTime? resolvedAt,
  });

  $UserCopyWith<$Res>? get author;
  $DiffNotePositionCopyWith<$Res>? get position;
  $UserCopyWith<$Res>? get resolvedBy;
}

/// @nodoc
class _$NoteCopyWithImpl<$Res> implements $NoteCopyWith<$Res> {
  _$NoteCopyWithImpl(this._self, this._then);

  final Note _self;
  final $Res Function(Note) _then;

  /// Create a copy of Note
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? body = null,
    Object? isSystem = null,
    Object? author = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? type = freezed,
    Object? position = freezed,
    Object? suggestions = freezed,
    Object? resolvable = freezed,
    Object? resolved = freezed,
    Object? resolvedBy = freezed,
    Object? resolvedAt = freezed,
  }) {
    return _then(
      _self.copyWith(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        body: null == body
            ? _self.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String,
        isSystem: null == isSystem
            ? _self.isSystem
            : isSystem // ignore: cast_nullable_to_non_nullable
                  as bool,
        author: freezed == author
            ? _self.author
            : author // ignore: cast_nullable_to_non_nullable
                  as User?,
        createdAt: freezed == createdAt
            ? _self.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _self.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        type: freezed == type
            ? _self.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String?,
        position: freezed == position
            ? _self.position
            : position // ignore: cast_nullable_to_non_nullable
                  as DiffNotePosition?,
        suggestions: freezed == suggestions
            ? _self.suggestions
            : suggestions // ignore: cast_nullable_to_non_nullable
                  as List<Suggestion>?,
        resolvable: freezed == resolvable
            ? _self.resolvable
            : resolvable // ignore: cast_nullable_to_non_nullable
                  as bool?,
        resolved: freezed == resolved
            ? _self.resolved
            : resolved // ignore: cast_nullable_to_non_nullable
                  as bool?,
        resolvedBy: freezed == resolvedBy
            ? _self.resolvedBy
            : resolvedBy // ignore: cast_nullable_to_non_nullable
                  as User?,
        resolvedAt: freezed == resolvedAt
            ? _self.resolvedAt
            : resolvedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }

  /// Create a copy of Note
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res>? get author {
    if (_self.author == null) {
      return null;
    }

    return $UserCopyWith<$Res>(_self.author!, (value) {
      return _then(_self.copyWith(author: value));
    });
  }

  /// Create a copy of Note
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DiffNotePositionCopyWith<$Res>? get position {
    if (_self.position == null) {
      return null;
    }

    return $DiffNotePositionCopyWith<$Res>(_self.position!, (value) {
      return _then(_self.copyWith(position: value));
    });
  }

  /// Create a copy of Note
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res>? get resolvedBy {
    if (_self.resolvedBy == null) {
      return null;
    }

    return $UserCopyWith<$Res>(_self.resolvedBy!, (value) {
      return _then(_self.copyWith(resolvedBy: value));
    });
  }
}

/// Adds pattern-matching-related methods to [Note].
extension NotePatterns on Note {
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
    TResult Function(_Note value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Note() when $default != null:
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
  TResult map<TResult extends Object?>(TResult Function(_Note value) $default) {
    final _that = this;
    switch (_that) {
      case _Note():
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
    TResult? Function(_Note value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Note() when $default != null:
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
      String body,
      @JsonKey(name: 'system') bool isSystem,
      User? author,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      String? type,
      DiffNotePosition? position,
      List<Suggestion>? suggestions,
      bool? resolvable,
      bool? resolved,
      @JsonKey(name: 'resolved_by') User? resolvedBy,
      @JsonKey(name: 'resolved_at') DateTime? resolvedAt,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Note() when $default != null:
        return $default(
          _that.id,
          _that.body,
          _that.isSystem,
          _that.author,
          _that.createdAt,
          _that.updatedAt,
          _that.type,
          _that.position,
          _that.suggestions,
          _that.resolvable,
          _that.resolved,
          _that.resolvedBy,
          _that.resolvedAt,
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
      String body,
      @JsonKey(name: 'system') bool isSystem,
      User? author,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      String? type,
      DiffNotePosition? position,
      List<Suggestion>? suggestions,
      bool? resolvable,
      bool? resolved,
      @JsonKey(name: 'resolved_by') User? resolvedBy,
      @JsonKey(name: 'resolved_at') DateTime? resolvedAt,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Note():
        return $default(
          _that.id,
          _that.body,
          _that.isSystem,
          _that.author,
          _that.createdAt,
          _that.updatedAt,
          _that.type,
          _that.position,
          _that.suggestions,
          _that.resolvable,
          _that.resolved,
          _that.resolvedBy,
          _that.resolvedAt,
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
      String body,
      @JsonKey(name: 'system') bool isSystem,
      User? author,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      String? type,
      DiffNotePosition? position,
      List<Suggestion>? suggestions,
      bool? resolvable,
      bool? resolved,
      @JsonKey(name: 'resolved_by') User? resolvedBy,
      @JsonKey(name: 'resolved_at') DateTime? resolvedAt,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Note() when $default != null:
        return $default(
          _that.id,
          _that.body,
          _that.isSystem,
          _that.author,
          _that.createdAt,
          _that.updatedAt,
          _that.type,
          _that.position,
          _that.suggestions,
          _that.resolvable,
          _that.resolved,
          _that.resolvedBy,
          _that.resolvedAt,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Note implements Note {
  const _Note({
    required this.id,
    required this.body,
    @JsonKey(name: 'system') this.isSystem = false,
    this.author,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
    this.type,
    this.position,
    final List<Suggestion>? suggestions,
    this.resolvable,
    this.resolved,
    @JsonKey(name: 'resolved_by') this.resolvedBy,
    @JsonKey(name: 'resolved_at') this.resolvedAt,
  }) : _suggestions = suggestions;
  factory _Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);

  @override
  final int id;
  @override
  final String body;
  @override
  @JsonKey(name: 'system')
  final bool isSystem;
  @override
  final User? author;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @override
  final String? type;
  @override
  final DiffNotePosition? position;
  final List<Suggestion>? _suggestions;
  @override
  List<Suggestion>? get suggestions {
    final value = _suggestions;
    if (value == null) return null;
    if (_suggestions is EqualUnmodifiableListView) return _suggestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final bool? resolvable;
  @override
  final bool? resolved;
  @override
  @JsonKey(name: 'resolved_by')
  final User? resolvedBy;
  @override
  @JsonKey(name: 'resolved_at')
  final DateTime? resolvedAt;

  /// Create a copy of Note
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$NoteCopyWith<_Note> get copyWith =>
      __$NoteCopyWithImpl<_Note>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$NoteToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Note &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.isSystem, isSystem) ||
                other.isSystem == isSystem) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.position, position) ||
                other.position == position) &&
            const DeepCollectionEquality().equals(
              other._suggestions,
              _suggestions,
            ) &&
            (identical(other.resolvable, resolvable) ||
                other.resolvable == resolvable) &&
            (identical(other.resolved, resolved) ||
                other.resolved == resolved) &&
            (identical(other.resolvedBy, resolvedBy) ||
                other.resolvedBy == resolvedBy) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    body,
    isSystem,
    author,
    createdAt,
    updatedAt,
    type,
    position,
    const DeepCollectionEquality().hash(_suggestions),
    resolvable,
    resolved,
    resolvedBy,
    resolvedAt,
  );

  @override
  String toString() {
    return 'Note(id: $id, body: $body, isSystem: $isSystem, author: $author, createdAt: $createdAt, updatedAt: $updatedAt, type: $type, position: $position, suggestions: $suggestions, resolvable: $resolvable, resolved: $resolved, resolvedBy: $resolvedBy, resolvedAt: $resolvedAt)';
  }
}

/// @nodoc
abstract mixin class _$NoteCopyWith<$Res> implements $NoteCopyWith<$Res> {
  factory _$NoteCopyWith(_Note value, $Res Function(_Note) _then) =
      __$NoteCopyWithImpl;
  @override
  @useResult
  $Res call({
    int id,
    String body,
    @JsonKey(name: 'system') bool isSystem,
    User? author,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    String? type,
    DiffNotePosition? position,
    List<Suggestion>? suggestions,
    bool? resolvable,
    bool? resolved,
    @JsonKey(name: 'resolved_by') User? resolvedBy,
    @JsonKey(name: 'resolved_at') DateTime? resolvedAt,
  });

  @override
  $UserCopyWith<$Res>? get author;
  @override
  $DiffNotePositionCopyWith<$Res>? get position;
  @override
  $UserCopyWith<$Res>? get resolvedBy;
}

/// @nodoc
class __$NoteCopyWithImpl<$Res> implements _$NoteCopyWith<$Res> {
  __$NoteCopyWithImpl(this._self, this._then);

  final _Note _self;
  final $Res Function(_Note) _then;

  /// Create a copy of Note
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? body = null,
    Object? isSystem = null,
    Object? author = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? type = freezed,
    Object? position = freezed,
    Object? suggestions = freezed,
    Object? resolvable = freezed,
    Object? resolved = freezed,
    Object? resolvedBy = freezed,
    Object? resolvedAt = freezed,
  }) {
    return _then(
      _Note(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        body: null == body
            ? _self.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String,
        isSystem: null == isSystem
            ? _self.isSystem
            : isSystem // ignore: cast_nullable_to_non_nullable
                  as bool,
        author: freezed == author
            ? _self.author
            : author // ignore: cast_nullable_to_non_nullable
                  as User?,
        createdAt: freezed == createdAt
            ? _self.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _self.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        type: freezed == type
            ? _self.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String?,
        position: freezed == position
            ? _self.position
            : position // ignore: cast_nullable_to_non_nullable
                  as DiffNotePosition?,
        suggestions: freezed == suggestions
            ? _self._suggestions
            : suggestions // ignore: cast_nullable_to_non_nullable
                  as List<Suggestion>?,
        resolvable: freezed == resolvable
            ? _self.resolvable
            : resolvable // ignore: cast_nullable_to_non_nullable
                  as bool?,
        resolved: freezed == resolved
            ? _self.resolved
            : resolved // ignore: cast_nullable_to_non_nullable
                  as bool?,
        resolvedBy: freezed == resolvedBy
            ? _self.resolvedBy
            : resolvedBy // ignore: cast_nullable_to_non_nullable
                  as User?,
        resolvedAt: freezed == resolvedAt
            ? _self.resolvedAt
            : resolvedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }

  /// Create a copy of Note
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res>? get author {
    if (_self.author == null) {
      return null;
    }

    return $UserCopyWith<$Res>(_self.author!, (value) {
      return _then(_self.copyWith(author: value));
    });
  }

  /// Create a copy of Note
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DiffNotePositionCopyWith<$Res>? get position {
    if (_self.position == null) {
      return null;
    }

    return $DiffNotePositionCopyWith<$Res>(_self.position!, (value) {
      return _then(_self.copyWith(position: value));
    });
  }

  /// Create a copy of Note
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res>? get resolvedBy {
    if (_self.resolvedBy == null) {
      return null;
    }

    return $UserCopyWith<$Res>(_self.resolvedBy!, (value) {
      return _then(_self.copyWith(resolvedBy: value));
    });
  }
}

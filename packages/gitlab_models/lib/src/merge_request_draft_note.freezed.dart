// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'merge_request_draft_note.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MergeRequestDraftNote {
  int get id;
  @JsonKey(name: 'author_id')
  int get authorId;
  @JsonKey(name: 'merge_request_id')
  int get mergeRequestId;
  String get note;
  @JsonKey(name: 'resolve_discussion')
  bool? get resolveDiscussion;
  @JsonKey(name: 'discussion_id')
  String? get discussionId;
  @JsonKey(name: 'commit_id')
  String? get commitId;
  @JsonKey(name: 'line_code')
  String? get lineCode;
  DiffNotePosition? get position;

  /// Create a copy of MergeRequestDraftNote
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MergeRequestDraftNoteCopyWith<MergeRequestDraftNote> get copyWith =>
      _$MergeRequestDraftNoteCopyWithImpl<MergeRequestDraftNote>(
        this as MergeRequestDraftNote,
        _$identity,
      );

  /// Serializes this MergeRequestDraftNote to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MergeRequestDraftNote &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.authorId, authorId) ||
                other.authorId == authorId) &&
            (identical(other.mergeRequestId, mergeRequestId) ||
                other.mergeRequestId == mergeRequestId) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.resolveDiscussion, resolveDiscussion) ||
                other.resolveDiscussion == resolveDiscussion) &&
            (identical(other.discussionId, discussionId) ||
                other.discussionId == discussionId) &&
            (identical(other.commitId, commitId) ||
                other.commitId == commitId) &&
            (identical(other.lineCode, lineCode) ||
                other.lineCode == lineCode) &&
            (identical(other.position, position) ||
                other.position == position));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    authorId,
    mergeRequestId,
    note,
    resolveDiscussion,
    discussionId,
    commitId,
    lineCode,
    position,
  );

  @override
  String toString() {
    return 'MergeRequestDraftNote(id: $id, authorId: $authorId, mergeRequestId: $mergeRequestId, note: $note, resolveDiscussion: $resolveDiscussion, discussionId: $discussionId, commitId: $commitId, lineCode: $lineCode, position: $position)';
  }
}

/// @nodoc
abstract mixin class $MergeRequestDraftNoteCopyWith<$Res> {
  factory $MergeRequestDraftNoteCopyWith(
    MergeRequestDraftNote value,
    $Res Function(MergeRequestDraftNote) _then,
  ) = _$MergeRequestDraftNoteCopyWithImpl;
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'author_id') int authorId,
    @JsonKey(name: 'merge_request_id') int mergeRequestId,
    String note,
    @JsonKey(name: 'resolve_discussion') bool? resolveDiscussion,
    @JsonKey(name: 'discussion_id') String? discussionId,
    @JsonKey(name: 'commit_id') String? commitId,
    @JsonKey(name: 'line_code') String? lineCode,
    DiffNotePosition? position,
  });

  $DiffNotePositionCopyWith<$Res>? get position;
}

/// @nodoc
class _$MergeRequestDraftNoteCopyWithImpl<$Res>
    implements $MergeRequestDraftNoteCopyWith<$Res> {
  _$MergeRequestDraftNoteCopyWithImpl(this._self, this._then);

  final MergeRequestDraftNote _self;
  final $Res Function(MergeRequestDraftNote) _then;

  /// Create a copy of MergeRequestDraftNote
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? authorId = null,
    Object? mergeRequestId = null,
    Object? note = null,
    Object? resolveDiscussion = freezed,
    Object? discussionId = freezed,
    Object? commitId = freezed,
    Object? lineCode = freezed,
    Object? position = freezed,
  }) {
    return _then(
      _self.copyWith(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        authorId: null == authorId
            ? _self.authorId
            : authorId // ignore: cast_nullable_to_non_nullable
                  as int,
        mergeRequestId: null == mergeRequestId
            ? _self.mergeRequestId
            : mergeRequestId // ignore: cast_nullable_to_non_nullable
                  as int,
        note: null == note
            ? _self.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String,
        resolveDiscussion: freezed == resolveDiscussion
            ? _self.resolveDiscussion
            : resolveDiscussion // ignore: cast_nullable_to_non_nullable
                  as bool?,
        discussionId: freezed == discussionId
            ? _self.discussionId
            : discussionId // ignore: cast_nullable_to_non_nullable
                  as String?,
        commitId: freezed == commitId
            ? _self.commitId
            : commitId // ignore: cast_nullable_to_non_nullable
                  as String?,
        lineCode: freezed == lineCode
            ? _self.lineCode
            : lineCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        position: freezed == position
            ? _self.position
            : position // ignore: cast_nullable_to_non_nullable
                  as DiffNotePosition?,
      ),
    );
  }

  /// Create a copy of MergeRequestDraftNote
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
}

/// Adds pattern-matching-related methods to [MergeRequestDraftNote].
extension MergeRequestDraftNotePatterns on MergeRequestDraftNote {
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
    TResult Function(_MergeRequestDraftNote value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MergeRequestDraftNote() when $default != null:
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
    TResult Function(_MergeRequestDraftNote value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MergeRequestDraftNote():
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
    TResult? Function(_MergeRequestDraftNote value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MergeRequestDraftNote() when $default != null:
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
      @JsonKey(name: 'author_id') int authorId,
      @JsonKey(name: 'merge_request_id') int mergeRequestId,
      String note,
      @JsonKey(name: 'resolve_discussion') bool? resolveDiscussion,
      @JsonKey(name: 'discussion_id') String? discussionId,
      @JsonKey(name: 'commit_id') String? commitId,
      @JsonKey(name: 'line_code') String? lineCode,
      DiffNotePosition? position,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MergeRequestDraftNote() when $default != null:
        return $default(
          _that.id,
          _that.authorId,
          _that.mergeRequestId,
          _that.note,
          _that.resolveDiscussion,
          _that.discussionId,
          _that.commitId,
          _that.lineCode,
          _that.position,
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
      @JsonKey(name: 'author_id') int authorId,
      @JsonKey(name: 'merge_request_id') int mergeRequestId,
      String note,
      @JsonKey(name: 'resolve_discussion') bool? resolveDiscussion,
      @JsonKey(name: 'discussion_id') String? discussionId,
      @JsonKey(name: 'commit_id') String? commitId,
      @JsonKey(name: 'line_code') String? lineCode,
      DiffNotePosition? position,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MergeRequestDraftNote():
        return $default(
          _that.id,
          _that.authorId,
          _that.mergeRequestId,
          _that.note,
          _that.resolveDiscussion,
          _that.discussionId,
          _that.commitId,
          _that.lineCode,
          _that.position,
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
      @JsonKey(name: 'author_id') int authorId,
      @JsonKey(name: 'merge_request_id') int mergeRequestId,
      String note,
      @JsonKey(name: 'resolve_discussion') bool? resolveDiscussion,
      @JsonKey(name: 'discussion_id') String? discussionId,
      @JsonKey(name: 'commit_id') String? commitId,
      @JsonKey(name: 'line_code') String? lineCode,
      DiffNotePosition? position,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MergeRequestDraftNote() when $default != null:
        return $default(
          _that.id,
          _that.authorId,
          _that.mergeRequestId,
          _that.note,
          _that.resolveDiscussion,
          _that.discussionId,
          _that.commitId,
          _that.lineCode,
          _that.position,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _MergeRequestDraftNote implements MergeRequestDraftNote {
  const _MergeRequestDraftNote({
    required this.id,
    @JsonKey(name: 'author_id') required this.authorId,
    @JsonKey(name: 'merge_request_id') required this.mergeRequestId,
    required this.note,
    @JsonKey(name: 'resolve_discussion') this.resolveDiscussion,
    @JsonKey(name: 'discussion_id') this.discussionId,
    @JsonKey(name: 'commit_id') this.commitId,
    @JsonKey(name: 'line_code') this.lineCode,
    this.position,
  });
  factory _MergeRequestDraftNote.fromJson(Map<String, dynamic> json) =>
      _$MergeRequestDraftNoteFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'author_id')
  final int authorId;
  @override
  @JsonKey(name: 'merge_request_id')
  final int mergeRequestId;
  @override
  final String note;
  @override
  @JsonKey(name: 'resolve_discussion')
  final bool? resolveDiscussion;
  @override
  @JsonKey(name: 'discussion_id')
  final String? discussionId;
  @override
  @JsonKey(name: 'commit_id')
  final String? commitId;
  @override
  @JsonKey(name: 'line_code')
  final String? lineCode;
  @override
  final DiffNotePosition? position;

  /// Create a copy of MergeRequestDraftNote
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MergeRequestDraftNoteCopyWith<_MergeRequestDraftNote> get copyWith =>
      __$MergeRequestDraftNoteCopyWithImpl<_MergeRequestDraftNote>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$MergeRequestDraftNoteToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MergeRequestDraftNote &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.authorId, authorId) ||
                other.authorId == authorId) &&
            (identical(other.mergeRequestId, mergeRequestId) ||
                other.mergeRequestId == mergeRequestId) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.resolveDiscussion, resolveDiscussion) ||
                other.resolveDiscussion == resolveDiscussion) &&
            (identical(other.discussionId, discussionId) ||
                other.discussionId == discussionId) &&
            (identical(other.commitId, commitId) ||
                other.commitId == commitId) &&
            (identical(other.lineCode, lineCode) ||
                other.lineCode == lineCode) &&
            (identical(other.position, position) ||
                other.position == position));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    authorId,
    mergeRequestId,
    note,
    resolveDiscussion,
    discussionId,
    commitId,
    lineCode,
    position,
  );

  @override
  String toString() {
    return 'MergeRequestDraftNote(id: $id, authorId: $authorId, mergeRequestId: $mergeRequestId, note: $note, resolveDiscussion: $resolveDiscussion, discussionId: $discussionId, commitId: $commitId, lineCode: $lineCode, position: $position)';
  }
}

/// @nodoc
abstract mixin class _$MergeRequestDraftNoteCopyWith<$Res>
    implements $MergeRequestDraftNoteCopyWith<$Res> {
  factory _$MergeRequestDraftNoteCopyWith(
    _MergeRequestDraftNote value,
    $Res Function(_MergeRequestDraftNote) _then,
  ) = __$MergeRequestDraftNoteCopyWithImpl;
  @override
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'author_id') int authorId,
    @JsonKey(name: 'merge_request_id') int mergeRequestId,
    String note,
    @JsonKey(name: 'resolve_discussion') bool? resolveDiscussion,
    @JsonKey(name: 'discussion_id') String? discussionId,
    @JsonKey(name: 'commit_id') String? commitId,
    @JsonKey(name: 'line_code') String? lineCode,
    DiffNotePosition? position,
  });

  @override
  $DiffNotePositionCopyWith<$Res>? get position;
}

/// @nodoc
class __$MergeRequestDraftNoteCopyWithImpl<$Res>
    implements _$MergeRequestDraftNoteCopyWith<$Res> {
  __$MergeRequestDraftNoteCopyWithImpl(this._self, this._then);

  final _MergeRequestDraftNote _self;
  final $Res Function(_MergeRequestDraftNote) _then;

  /// Create a copy of MergeRequestDraftNote
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? authorId = null,
    Object? mergeRequestId = null,
    Object? note = null,
    Object? resolveDiscussion = freezed,
    Object? discussionId = freezed,
    Object? commitId = freezed,
    Object? lineCode = freezed,
    Object? position = freezed,
  }) {
    return _then(
      _MergeRequestDraftNote(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        authorId: null == authorId
            ? _self.authorId
            : authorId // ignore: cast_nullable_to_non_nullable
                  as int,
        mergeRequestId: null == mergeRequestId
            ? _self.mergeRequestId
            : mergeRequestId // ignore: cast_nullable_to_non_nullable
                  as int,
        note: null == note
            ? _self.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String,
        resolveDiscussion: freezed == resolveDiscussion
            ? _self.resolveDiscussion
            : resolveDiscussion // ignore: cast_nullable_to_non_nullable
                  as bool?,
        discussionId: freezed == discussionId
            ? _self.discussionId
            : discussionId // ignore: cast_nullable_to_non_nullable
                  as String?,
        commitId: freezed == commitId
            ? _self.commitId
            : commitId // ignore: cast_nullable_to_non_nullable
                  as String?,
        lineCode: freezed == lineCode
            ? _self.lineCode
            : lineCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        position: freezed == position
            ? _self.position
            : position // ignore: cast_nullable_to_non_nullable
                  as DiffNotePosition?,
      ),
    );
  }

  /// Create a copy of MergeRequestDraftNote
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
}

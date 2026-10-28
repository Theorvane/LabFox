// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'commit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CommitStats {
  int get additions;
  int get deletions;
  int get total;

  /// Create a copy of CommitStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CommitStatsCopyWith<CommitStats> get copyWith =>
      _$CommitStatsCopyWithImpl<CommitStats>(this as CommitStats, _$identity);

  /// Serializes this CommitStats to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CommitStats &&
            (identical(other.additions, additions) ||
                other.additions == additions) &&
            (identical(other.deletions, deletions) ||
                other.deletions == deletions) &&
            (identical(other.total, total) || other.total == total));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, additions, deletions, total);

  @override
  String toString() {
    return 'CommitStats(additions: $additions, deletions: $deletions, total: $total)';
  }
}

/// @nodoc
abstract mixin class $CommitStatsCopyWith<$Res> {
  factory $CommitStatsCopyWith(
    CommitStats value,
    $Res Function(CommitStats) _then,
  ) = _$CommitStatsCopyWithImpl;
  @useResult
  $Res call({int additions, int deletions, int total});
}

/// @nodoc
class _$CommitStatsCopyWithImpl<$Res> implements $CommitStatsCopyWith<$Res> {
  _$CommitStatsCopyWithImpl(this._self, this._then);

  final CommitStats _self;
  final $Res Function(CommitStats) _then;

  /// Create a copy of CommitStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? additions = null,
    Object? deletions = null,
    Object? total = null,
  }) {
    return _then(
      _self.copyWith(
        additions: null == additions
            ? _self.additions
            : additions // ignore: cast_nullable_to_non_nullable
                  as int,
        deletions: null == deletions
            ? _self.deletions
            : deletions // ignore: cast_nullable_to_non_nullable
                  as int,
        total: null == total
            ? _self.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [CommitStats].
extension CommitStatsPatterns on CommitStats {
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
    TResult Function(_CommitStats value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CommitStats() when $default != null:
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
    TResult Function(_CommitStats value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CommitStats():
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
    TResult? Function(_CommitStats value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CommitStats() when $default != null:
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
    TResult Function(int additions, int deletions, int total)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CommitStats() when $default != null:
        return $default(_that.additions, _that.deletions, _that.total);
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
    TResult Function(int additions, int deletions, int total) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CommitStats():
        return $default(_that.additions, _that.deletions, _that.total);
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
    TResult? Function(int additions, int deletions, int total)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CommitStats() when $default != null:
        return $default(_that.additions, _that.deletions, _that.total);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _CommitStats implements CommitStats {
  const _CommitStats({this.additions = 0, this.deletions = 0, this.total = 0});
  factory _CommitStats.fromJson(Map<String, dynamic> json) =>
      _$CommitStatsFromJson(json);

  @override
  @JsonKey()
  final int additions;
  @override
  @JsonKey()
  final int deletions;
  @override
  @JsonKey()
  final int total;

  /// Create a copy of CommitStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CommitStatsCopyWith<_CommitStats> get copyWith =>
      __$CommitStatsCopyWithImpl<_CommitStats>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CommitStatsToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CommitStats &&
            (identical(other.additions, additions) ||
                other.additions == additions) &&
            (identical(other.deletions, deletions) ||
                other.deletions == deletions) &&
            (identical(other.total, total) || other.total == total));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, additions, deletions, total);

  @override
  String toString() {
    return 'CommitStats(additions: $additions, deletions: $deletions, total: $total)';
  }
}

/// @nodoc
abstract mixin class _$CommitStatsCopyWith<$Res>
    implements $CommitStatsCopyWith<$Res> {
  factory _$CommitStatsCopyWith(
    _CommitStats value,
    $Res Function(_CommitStats) _then,
  ) = __$CommitStatsCopyWithImpl;
  @override
  @useResult
  $Res call({int additions, int deletions, int total});
}

/// @nodoc
class __$CommitStatsCopyWithImpl<$Res> implements _$CommitStatsCopyWith<$Res> {
  __$CommitStatsCopyWithImpl(this._self, this._then);

  final _CommitStats _self;
  final $Res Function(_CommitStats) _then;

  /// Create a copy of CommitStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? additions = null,
    Object? deletions = null,
    Object? total = null,
  }) {
    return _then(
      _CommitStats(
        additions: null == additions
            ? _self.additions
            : additions // ignore: cast_nullable_to_non_nullable
                  as int,
        deletions: null == deletions
            ? _self.deletions
            : deletions // ignore: cast_nullable_to_non_nullable
                  as int,
        total: null == total
            ? _self.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
mixin _$Commit {
  String get id;

  /// Null means unreported; an empty list explicitly identifies a root commit.
  @JsonKey(name: 'parent_ids')
  List<String>? get parentIds;
  @JsonKey(name: 'short_id')
  String? get rawShortId;
  String get title;
  String? get message;
  @JsonKey(name: 'author_name')
  String? get authorName;
  @JsonKey(name: 'web_url')
  String? get webUrl;
  @JsonKey(name: 'authored_date')
  DateTime? get authoredDate;
  CommitStats? get stats;

  /// Create a copy of Commit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CommitCopyWith<Commit> get copyWith =>
      _$CommitCopyWithImpl<Commit>(this as Commit, _$identity);

  /// Serializes this Commit to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Commit &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(other.parentIds, parentIds) &&
            (identical(other.rawShortId, rawShortId) ||
                other.rawShortId == rawShortId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.authorName, authorName) ||
                other.authorName == authorName) &&
            (identical(other.webUrl, webUrl) || other.webUrl == webUrl) &&
            (identical(other.authoredDate, authoredDate) ||
                other.authoredDate == authoredDate) &&
            (identical(other.stats, stats) || other.stats == stats));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    const DeepCollectionEquality().hash(parentIds),
    rawShortId,
    title,
    message,
    authorName,
    webUrl,
    authoredDate,
    stats,
  );

  @override
  String toString() {
    return 'Commit(id: $id, parentIds: $parentIds, rawShortId: $rawShortId, title: $title, message: $message, authorName: $authorName, webUrl: $webUrl, authoredDate: $authoredDate, stats: $stats)';
  }
}

/// @nodoc
abstract mixin class $CommitCopyWith<$Res> {
  factory $CommitCopyWith(Commit value, $Res Function(Commit) _then) =
      _$CommitCopyWithImpl;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'parent_ids') List<String>? parentIds,
    @JsonKey(name: 'short_id') String? rawShortId,
    String title,
    String? message,
    @JsonKey(name: 'author_name') String? authorName,
    @JsonKey(name: 'web_url') String? webUrl,
    @JsonKey(name: 'authored_date') DateTime? authoredDate,
    CommitStats? stats,
  });

  $CommitStatsCopyWith<$Res>? get stats;
}

/// @nodoc
class _$CommitCopyWithImpl<$Res> implements $CommitCopyWith<$Res> {
  _$CommitCopyWithImpl(this._self, this._then);

  final Commit _self;
  final $Res Function(Commit) _then;

  /// Create a copy of Commit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? parentIds = freezed,
    Object? rawShortId = freezed,
    Object? title = null,
    Object? message = freezed,
    Object? authorName = freezed,
    Object? webUrl = freezed,
    Object? authoredDate = freezed,
    Object? stats = freezed,
  }) {
    return _then(
      _self.copyWith(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        parentIds: freezed == parentIds
            ? _self.parentIds
            : parentIds // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        rawShortId: freezed == rawShortId
            ? _self.rawShortId
            : rawShortId // ignore: cast_nullable_to_non_nullable
                  as String?,
        title: null == title
            ? _self.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        message: freezed == message
            ? _self.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
        authorName: freezed == authorName
            ? _self.authorName
            : authorName // ignore: cast_nullable_to_non_nullable
                  as String?,
        webUrl: freezed == webUrl
            ? _self.webUrl
            : webUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        authoredDate: freezed == authoredDate
            ? _self.authoredDate
            : authoredDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        stats: freezed == stats
            ? _self.stats
            : stats // ignore: cast_nullable_to_non_nullable
                  as CommitStats?,
      ),
    );
  }

  /// Create a copy of Commit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CommitStatsCopyWith<$Res>? get stats {
    if (_self.stats == null) {
      return null;
    }

    return $CommitStatsCopyWith<$Res>(_self.stats!, (value) {
      return _then(_self.copyWith(stats: value));
    });
  }
}

/// Adds pattern-matching-related methods to [Commit].
extension CommitPatterns on Commit {
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
    TResult Function(_Commit value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Commit() when $default != null:
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
    TResult Function(_Commit value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Commit():
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
    TResult? Function(_Commit value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Commit() when $default != null:
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
      @JsonKey(name: 'parent_ids') List<String>? parentIds,
      @JsonKey(name: 'short_id') String? rawShortId,
      String title,
      String? message,
      @JsonKey(name: 'author_name') String? authorName,
      @JsonKey(name: 'web_url') String? webUrl,
      @JsonKey(name: 'authored_date') DateTime? authoredDate,
      CommitStats? stats,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Commit() when $default != null:
        return $default(
          _that.id,
          _that.parentIds,
          _that.rawShortId,
          _that.title,
          _that.message,
          _that.authorName,
          _that.webUrl,
          _that.authoredDate,
          _that.stats,
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
      String id,
      @JsonKey(name: 'parent_ids') List<String>? parentIds,
      @JsonKey(name: 'short_id') String? rawShortId,
      String title,
      String? message,
      @JsonKey(name: 'author_name') String? authorName,
      @JsonKey(name: 'web_url') String? webUrl,
      @JsonKey(name: 'authored_date') DateTime? authoredDate,
      CommitStats? stats,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Commit():
        return $default(
          _that.id,
          _that.parentIds,
          _that.rawShortId,
          _that.title,
          _that.message,
          _that.authorName,
          _that.webUrl,
          _that.authoredDate,
          _that.stats,
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
      String id,
      @JsonKey(name: 'parent_ids') List<String>? parentIds,
      @JsonKey(name: 'short_id') String? rawShortId,
      String title,
      String? message,
      @JsonKey(name: 'author_name') String? authorName,
      @JsonKey(name: 'web_url') String? webUrl,
      @JsonKey(name: 'authored_date') DateTime? authoredDate,
      CommitStats? stats,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Commit() when $default != null:
        return $default(
          _that.id,
          _that.parentIds,
          _that.rawShortId,
          _that.title,
          _that.message,
          _that.authorName,
          _that.webUrl,
          _that.authoredDate,
          _that.stats,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Commit extends Commit {
  const _Commit({
    required this.id,
    @JsonKey(name: 'parent_ids') final List<String>? parentIds,
    @JsonKey(name: 'short_id') this.rawShortId,
    required this.title,
    this.message,
    @JsonKey(name: 'author_name') this.authorName,
    @JsonKey(name: 'web_url') this.webUrl,
    @JsonKey(name: 'authored_date') this.authoredDate,
    this.stats,
  }) : _parentIds = parentIds,
       super._();
  factory _Commit.fromJson(Map<String, dynamic> json) => _$CommitFromJson(json);

  @override
  final String id;

  /// Null means unreported; an empty list explicitly identifies a root commit.
  final List<String>? _parentIds;

  /// Null means unreported; an empty list explicitly identifies a root commit.
  @override
  @JsonKey(name: 'parent_ids')
  List<String>? get parentIds {
    final value = _parentIds;
    if (value == null) return null;
    if (_parentIds is EqualUnmodifiableListView) return _parentIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'short_id')
  final String? rawShortId;
  @override
  final String title;
  @override
  final String? message;
  @override
  @JsonKey(name: 'author_name')
  final String? authorName;
  @override
  @JsonKey(name: 'web_url')
  final String? webUrl;
  @override
  @JsonKey(name: 'authored_date')
  final DateTime? authoredDate;
  @override
  final CommitStats? stats;

  /// Create a copy of Commit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CommitCopyWith<_Commit> get copyWith =>
      __$CommitCopyWithImpl<_Commit>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CommitToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Commit &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(
              other._parentIds,
              _parentIds,
            ) &&
            (identical(other.rawShortId, rawShortId) ||
                other.rawShortId == rawShortId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.authorName, authorName) ||
                other.authorName == authorName) &&
            (identical(other.webUrl, webUrl) || other.webUrl == webUrl) &&
            (identical(other.authoredDate, authoredDate) ||
                other.authoredDate == authoredDate) &&
            (identical(other.stats, stats) || other.stats == stats));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    const DeepCollectionEquality().hash(_parentIds),
    rawShortId,
    title,
    message,
    authorName,
    webUrl,
    authoredDate,
    stats,
  );

  @override
  String toString() {
    return 'Commit(id: $id, parentIds: $parentIds, rawShortId: $rawShortId, title: $title, message: $message, authorName: $authorName, webUrl: $webUrl, authoredDate: $authoredDate, stats: $stats)';
  }
}

/// @nodoc
abstract mixin class _$CommitCopyWith<$Res> implements $CommitCopyWith<$Res> {
  factory _$CommitCopyWith(_Commit value, $Res Function(_Commit) _then) =
      __$CommitCopyWithImpl;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'parent_ids') List<String>? parentIds,
    @JsonKey(name: 'short_id') String? rawShortId,
    String title,
    String? message,
    @JsonKey(name: 'author_name') String? authorName,
    @JsonKey(name: 'web_url') String? webUrl,
    @JsonKey(name: 'authored_date') DateTime? authoredDate,
    CommitStats? stats,
  });

  @override
  $CommitStatsCopyWith<$Res>? get stats;
}

/// @nodoc
class __$CommitCopyWithImpl<$Res> implements _$CommitCopyWith<$Res> {
  __$CommitCopyWithImpl(this._self, this._then);

  final _Commit _self;
  final $Res Function(_Commit) _then;

  /// Create a copy of Commit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? parentIds = freezed,
    Object? rawShortId = freezed,
    Object? title = null,
    Object? message = freezed,
    Object? authorName = freezed,
    Object? webUrl = freezed,
    Object? authoredDate = freezed,
    Object? stats = freezed,
  }) {
    return _then(
      _Commit(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        parentIds: freezed == parentIds
            ? _self._parentIds
            : parentIds // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        rawShortId: freezed == rawShortId
            ? _self.rawShortId
            : rawShortId // ignore: cast_nullable_to_non_nullable
                  as String?,
        title: null == title
            ? _self.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        message: freezed == message
            ? _self.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
        authorName: freezed == authorName
            ? _self.authorName
            : authorName // ignore: cast_nullable_to_non_nullable
                  as String?,
        webUrl: freezed == webUrl
            ? _self.webUrl
            : webUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        authoredDate: freezed == authoredDate
            ? _self.authoredDate
            : authoredDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        stats: freezed == stats
            ? _self.stats
            : stats // ignore: cast_nullable_to_non_nullable
                  as CommitStats?,
      ),
    );
  }

  /// Create a copy of Commit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CommitStatsCopyWith<$Res>? get stats {
    if (_self.stats == null) {
      return null;
    }

    return $CommitStatsCopyWith<$Res>(_self.stats!, (value) {
      return _then(_self.copyWith(stats: value));
    });
  }
}

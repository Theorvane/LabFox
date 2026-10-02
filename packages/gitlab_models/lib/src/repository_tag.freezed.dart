// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'repository_tag.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TagRelease {
  @JsonKey(name: 'tag_name')
  String get tagName;
  String? get description;

  /// Create a copy of TagRelease
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TagReleaseCopyWith<TagRelease> get copyWith =>
      _$TagReleaseCopyWithImpl<TagRelease>(this as TagRelease, _$identity);

  /// Serializes this TagRelease to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TagRelease &&
            (identical(other.tagName, tagName) || other.tagName == tagName) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, tagName, description);

  @override
  String toString() {
    return 'TagRelease(tagName: $tagName, description: $description)';
  }
}

/// @nodoc
abstract mixin class $TagReleaseCopyWith<$Res> {
  factory $TagReleaseCopyWith(
    TagRelease value,
    $Res Function(TagRelease) _then,
  ) = _$TagReleaseCopyWithImpl;
  @useResult
  $Res call({@JsonKey(name: 'tag_name') String tagName, String? description});
}

/// @nodoc
class _$TagReleaseCopyWithImpl<$Res> implements $TagReleaseCopyWith<$Res> {
  _$TagReleaseCopyWithImpl(this._self, this._then);

  final TagRelease _self;
  final $Res Function(TagRelease) _then;

  /// Create a copy of TagRelease
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? tagName = null, Object? description = freezed}) {
    return _then(
      _self.copyWith(
        tagName: null == tagName
            ? _self.tagName
            : tagName // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _self.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [TagRelease].
extension TagReleasePatterns on TagRelease {
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
    TResult Function(_TagRelease value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TagRelease() when $default != null:
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
    TResult Function(_TagRelease value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TagRelease():
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
    TResult? Function(_TagRelease value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TagRelease() when $default != null:
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
      @JsonKey(name: 'tag_name') String tagName,
      String? description,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TagRelease() when $default != null:
        return $default(_that.tagName, _that.description);
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
      @JsonKey(name: 'tag_name') String tagName,
      String? description,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TagRelease():
        return $default(_that.tagName, _that.description);
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
      @JsonKey(name: 'tag_name') String tagName,
      String? description,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TagRelease() when $default != null:
        return $default(_that.tagName, _that.description);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _TagRelease implements TagRelease {
  const _TagRelease({
    @JsonKey(name: 'tag_name') required this.tagName,
    this.description,
  });
  factory _TagRelease.fromJson(Map<String, dynamic> json) =>
      _$TagReleaseFromJson(json);

  @override
  @JsonKey(name: 'tag_name')
  final String tagName;
  @override
  final String? description;

  /// Create a copy of TagRelease
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TagReleaseCopyWith<_TagRelease> get copyWith =>
      __$TagReleaseCopyWithImpl<_TagRelease>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TagReleaseToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TagRelease &&
            (identical(other.tagName, tagName) || other.tagName == tagName) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, tagName, description);

  @override
  String toString() {
    return 'TagRelease(tagName: $tagName, description: $description)';
  }
}

/// @nodoc
abstract mixin class _$TagReleaseCopyWith<$Res>
    implements $TagReleaseCopyWith<$Res> {
  factory _$TagReleaseCopyWith(
    _TagRelease value,
    $Res Function(_TagRelease) _then,
  ) = __$TagReleaseCopyWithImpl;
  @override
  @useResult
  $Res call({@JsonKey(name: 'tag_name') String tagName, String? description});
}

/// @nodoc
class __$TagReleaseCopyWithImpl<$Res> implements _$TagReleaseCopyWith<$Res> {
  __$TagReleaseCopyWithImpl(this._self, this._then);

  final _TagRelease _self;
  final $Res Function(_TagRelease) _then;

  /// Create a copy of TagRelease
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({Object? tagName = null, Object? description = freezed}) {
    return _then(
      _TagRelease(
        tagName: null == tagName
            ? _self.tagName
            : tagName // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _self.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
mixin _$RepositoryTag {
  String get name;
  String? get message;
  String? get target;
  @JsonKey(name: 'protected')
  bool get isProtected;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  Commit? get commit;
  TagRelease? get release;

  /// Create a copy of RepositoryTag
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RepositoryTagCopyWith<RepositoryTag> get copyWith =>
      _$RepositoryTagCopyWithImpl<RepositoryTag>(
        this as RepositoryTag,
        _$identity,
      );

  /// Serializes this RepositoryTag to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RepositoryTag &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.target, target) || other.target == target) &&
            (identical(other.isProtected, isProtected) ||
                other.isProtected == isProtected) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.commit, commit) || other.commit == commit) &&
            (identical(other.release, release) || other.release == release));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    message,
    target,
    isProtected,
    createdAt,
    commit,
    release,
  );

  @override
  String toString() {
    return 'RepositoryTag(name: $name, message: $message, target: $target, isProtected: $isProtected, createdAt: $createdAt, commit: $commit, release: $release)';
  }
}

/// @nodoc
abstract mixin class $RepositoryTagCopyWith<$Res> {
  factory $RepositoryTagCopyWith(
    RepositoryTag value,
    $Res Function(RepositoryTag) _then,
  ) = _$RepositoryTagCopyWithImpl;
  @useResult
  $Res call({
    String name,
    String? message,
    String? target,
    @JsonKey(name: 'protected') bool isProtected,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    Commit? commit,
    TagRelease? release,
  });

  $CommitCopyWith<$Res>? get commit;
  $TagReleaseCopyWith<$Res>? get release;
}

/// @nodoc
class _$RepositoryTagCopyWithImpl<$Res>
    implements $RepositoryTagCopyWith<$Res> {
  _$RepositoryTagCopyWithImpl(this._self, this._then);

  final RepositoryTag _self;
  final $Res Function(RepositoryTag) _then;

  /// Create a copy of RepositoryTag
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? message = freezed,
    Object? target = freezed,
    Object? isProtected = null,
    Object? createdAt = freezed,
    Object? commit = freezed,
    Object? release = freezed,
  }) {
    return _then(
      _self.copyWith(
        name: null == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        message: freezed == message
            ? _self.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
        target: freezed == target
            ? _self.target
            : target // ignore: cast_nullable_to_non_nullable
                  as String?,
        isProtected: null == isProtected
            ? _self.isProtected
            : isProtected // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: freezed == createdAt
            ? _self.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        commit: freezed == commit
            ? _self.commit
            : commit // ignore: cast_nullable_to_non_nullable
                  as Commit?,
        release: freezed == release
            ? _self.release
            : release // ignore: cast_nullable_to_non_nullable
                  as TagRelease?,
      ),
    );
  }

  /// Create a copy of RepositoryTag
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

  /// Create a copy of RepositoryTag
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TagReleaseCopyWith<$Res>? get release {
    if (_self.release == null) {
      return null;
    }

    return $TagReleaseCopyWith<$Res>(_self.release!, (value) {
      return _then(_self.copyWith(release: value));
    });
  }
}

/// Adds pattern-matching-related methods to [RepositoryTag].
extension RepositoryTagPatterns on RepositoryTag {
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
    TResult Function(_RepositoryTag value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RepositoryTag() when $default != null:
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
    TResult Function(_RepositoryTag value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RepositoryTag():
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
    TResult? Function(_RepositoryTag value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RepositoryTag() when $default != null:
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
      String? message,
      String? target,
      @JsonKey(name: 'protected') bool isProtected,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      Commit? commit,
      TagRelease? release,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RepositoryTag() when $default != null:
        return $default(
          _that.name,
          _that.message,
          _that.target,
          _that.isProtected,
          _that.createdAt,
          _that.commit,
          _that.release,
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
      String? message,
      String? target,
      @JsonKey(name: 'protected') bool isProtected,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      Commit? commit,
      TagRelease? release,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RepositoryTag():
        return $default(
          _that.name,
          _that.message,
          _that.target,
          _that.isProtected,
          _that.createdAt,
          _that.commit,
          _that.release,
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
      String? message,
      String? target,
      @JsonKey(name: 'protected') bool isProtected,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      Commit? commit,
      TagRelease? release,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RepositoryTag() when $default != null:
        return $default(
          _that.name,
          _that.message,
          _that.target,
          _that.isProtected,
          _that.createdAt,
          _that.commit,
          _that.release,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _RepositoryTag implements RepositoryTag {
  const _RepositoryTag({
    required this.name,
    this.message,
    this.target,
    @JsonKey(name: 'protected') this.isProtected = false,
    @JsonKey(name: 'created_at') this.createdAt,
    this.commit,
    this.release,
  });
  factory _RepositoryTag.fromJson(Map<String, dynamic> json) =>
      _$RepositoryTagFromJson(json);

  @override
  final String name;
  @override
  final String? message;
  @override
  final String? target;
  @override
  @JsonKey(name: 'protected')
  final bool isProtected;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  final Commit? commit;
  @override
  final TagRelease? release;

  /// Create a copy of RepositoryTag
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RepositoryTagCopyWith<_RepositoryTag> get copyWith =>
      __$RepositoryTagCopyWithImpl<_RepositoryTag>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$RepositoryTagToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _RepositoryTag &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.target, target) || other.target == target) &&
            (identical(other.isProtected, isProtected) ||
                other.isProtected == isProtected) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.commit, commit) || other.commit == commit) &&
            (identical(other.release, release) || other.release == release));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    message,
    target,
    isProtected,
    createdAt,
    commit,
    release,
  );

  @override
  String toString() {
    return 'RepositoryTag(name: $name, message: $message, target: $target, isProtected: $isProtected, createdAt: $createdAt, commit: $commit, release: $release)';
  }
}

/// @nodoc
abstract mixin class _$RepositoryTagCopyWith<$Res>
    implements $RepositoryTagCopyWith<$Res> {
  factory _$RepositoryTagCopyWith(
    _RepositoryTag value,
    $Res Function(_RepositoryTag) _then,
  ) = __$RepositoryTagCopyWithImpl;
  @override
  @useResult
  $Res call({
    String name,
    String? message,
    String? target,
    @JsonKey(name: 'protected') bool isProtected,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    Commit? commit,
    TagRelease? release,
  });

  @override
  $CommitCopyWith<$Res>? get commit;
  @override
  $TagReleaseCopyWith<$Res>? get release;
}

/// @nodoc
class __$RepositoryTagCopyWithImpl<$Res>
    implements _$RepositoryTagCopyWith<$Res> {
  __$RepositoryTagCopyWithImpl(this._self, this._then);

  final _RepositoryTag _self;
  final $Res Function(_RepositoryTag) _then;

  /// Create a copy of RepositoryTag
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? name = null,
    Object? message = freezed,
    Object? target = freezed,
    Object? isProtected = null,
    Object? createdAt = freezed,
    Object? commit = freezed,
    Object? release = freezed,
  }) {
    return _then(
      _RepositoryTag(
        name: null == name
            ? _self.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        message: freezed == message
            ? _self.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
        target: freezed == target
            ? _self.target
            : target // ignore: cast_nullable_to_non_nullable
                  as String?,
        isProtected: null == isProtected
            ? _self.isProtected
            : isProtected // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: freezed == createdAt
            ? _self.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        commit: freezed == commit
            ? _self.commit
            : commit // ignore: cast_nullable_to_non_nullable
                  as Commit?,
        release: freezed == release
            ? _self.release
            : release // ignore: cast_nullable_to_non_nullable
                  as TagRelease?,
      ),
    );
  }

  /// Create a copy of RepositoryTag
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

  /// Create a copy of RepositoryTag
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TagReleaseCopyWith<$Res>? get release {
    if (_self.release == null) {
      return null;
    }

    return $TagReleaseCopyWith<$Res>(_self.release!, (value) {
      return _then(_self.copyWith(release: value));
    });
  }
}

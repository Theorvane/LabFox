// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'commit_diff_file.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CommitDiffFile {
  @JsonKey(name: 'old_path')
  String get oldPath;
  @JsonKey(name: 'new_path')
  String get newPath;
  @JsonKey(name: 'new_file')
  bool get isNew;
  @JsonKey(name: 'deleted_file')
  bool get isDeleted;
  @JsonKey(name: 'renamed_file')
  bool get isRenamed;
  String? get diff;
  @JsonKey(name: 'a_mode')
  String? get oldMode;
  @JsonKey(name: 'b_mode')
  String? get newMode;
  @JsonKey(name: 'collapsed')
  bool? get isCollapsed;
  @JsonKey(name: 'too_large')
  bool? get isTooLarge;
  @JsonKey(name: 'generated_file')
  bool? get isGenerated;

  /// Create a copy of CommitDiffFile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CommitDiffFileCopyWith<CommitDiffFile> get copyWith =>
      _$CommitDiffFileCopyWithImpl<CommitDiffFile>(
        this as CommitDiffFile,
        _$identity,
      );

  /// Serializes this CommitDiffFile to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CommitDiffFile &&
            (identical(other.oldPath, oldPath) || other.oldPath == oldPath) &&
            (identical(other.newPath, newPath) || other.newPath == newPath) &&
            (identical(other.isNew, isNew) || other.isNew == isNew) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            (identical(other.isRenamed, isRenamed) ||
                other.isRenamed == isRenamed) &&
            (identical(other.diff, diff) || other.diff == diff) &&
            (identical(other.oldMode, oldMode) || other.oldMode == oldMode) &&
            (identical(other.newMode, newMode) || other.newMode == newMode) &&
            (identical(other.isCollapsed, isCollapsed) ||
                other.isCollapsed == isCollapsed) &&
            (identical(other.isTooLarge, isTooLarge) ||
                other.isTooLarge == isTooLarge) &&
            (identical(other.isGenerated, isGenerated) ||
                other.isGenerated == isGenerated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    oldPath,
    newPath,
    isNew,
    isDeleted,
    isRenamed,
    diff,
    oldMode,
    newMode,
    isCollapsed,
    isTooLarge,
    isGenerated,
  );

  @override
  String toString() {
    return 'CommitDiffFile(oldPath: $oldPath, newPath: $newPath, isNew: $isNew, isDeleted: $isDeleted, isRenamed: $isRenamed, diff: $diff, oldMode: $oldMode, newMode: $newMode, isCollapsed: $isCollapsed, isTooLarge: $isTooLarge, isGenerated: $isGenerated)';
  }
}

/// @nodoc
abstract mixin class $CommitDiffFileCopyWith<$Res> {
  factory $CommitDiffFileCopyWith(
    CommitDiffFile value,
    $Res Function(CommitDiffFile) _then,
  ) = _$CommitDiffFileCopyWithImpl;
  @useResult
  $Res call({
    @JsonKey(name: 'old_path') String oldPath,
    @JsonKey(name: 'new_path') String newPath,
    @JsonKey(name: 'new_file') bool isNew,
    @JsonKey(name: 'deleted_file') bool isDeleted,
    @JsonKey(name: 'renamed_file') bool isRenamed,
    String? diff,
    @JsonKey(name: 'a_mode') String? oldMode,
    @JsonKey(name: 'b_mode') String? newMode,
    @JsonKey(name: 'collapsed') bool? isCollapsed,
    @JsonKey(name: 'too_large') bool? isTooLarge,
    @JsonKey(name: 'generated_file') bool? isGenerated,
  });
}

/// @nodoc
class _$CommitDiffFileCopyWithImpl<$Res>
    implements $CommitDiffFileCopyWith<$Res> {
  _$CommitDiffFileCopyWithImpl(this._self, this._then);

  final CommitDiffFile _self;
  final $Res Function(CommitDiffFile) _then;

  /// Create a copy of CommitDiffFile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? oldPath = null,
    Object? newPath = null,
    Object? isNew = null,
    Object? isDeleted = null,
    Object? isRenamed = null,
    Object? diff = freezed,
    Object? oldMode = freezed,
    Object? newMode = freezed,
    Object? isCollapsed = freezed,
    Object? isTooLarge = freezed,
    Object? isGenerated = freezed,
  }) {
    return _then(
      _self.copyWith(
        oldPath: null == oldPath
            ? _self.oldPath
            : oldPath // ignore: cast_nullable_to_non_nullable
                  as String,
        newPath: null == newPath
            ? _self.newPath
            : newPath // ignore: cast_nullable_to_non_nullable
                  as String,
        isNew: null == isNew
            ? _self.isNew
            : isNew // ignore: cast_nullable_to_non_nullable
                  as bool,
        isDeleted: null == isDeleted
            ? _self.isDeleted
            : isDeleted // ignore: cast_nullable_to_non_nullable
                  as bool,
        isRenamed: null == isRenamed
            ? _self.isRenamed
            : isRenamed // ignore: cast_nullable_to_non_nullable
                  as bool,
        diff: freezed == diff
            ? _self.diff
            : diff // ignore: cast_nullable_to_non_nullable
                  as String?,
        oldMode: freezed == oldMode
            ? _self.oldMode
            : oldMode // ignore: cast_nullable_to_non_nullable
                  as String?,
        newMode: freezed == newMode
            ? _self.newMode
            : newMode // ignore: cast_nullable_to_non_nullable
                  as String?,
        isCollapsed: freezed == isCollapsed
            ? _self.isCollapsed
            : isCollapsed // ignore: cast_nullable_to_non_nullable
                  as bool?,
        isTooLarge: freezed == isTooLarge
            ? _self.isTooLarge
            : isTooLarge // ignore: cast_nullable_to_non_nullable
                  as bool?,
        isGenerated: freezed == isGenerated
            ? _self.isGenerated
            : isGenerated // ignore: cast_nullable_to_non_nullable
                  as bool?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [CommitDiffFile].
extension CommitDiffFilePatterns on CommitDiffFile {
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
    TResult Function(_CommitDiffFile value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CommitDiffFile() when $default != null:
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
    TResult Function(_CommitDiffFile value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CommitDiffFile():
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
    TResult? Function(_CommitDiffFile value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CommitDiffFile() when $default != null:
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
      @JsonKey(name: 'old_path') String oldPath,
      @JsonKey(name: 'new_path') String newPath,
      @JsonKey(name: 'new_file') bool isNew,
      @JsonKey(name: 'deleted_file') bool isDeleted,
      @JsonKey(name: 'renamed_file') bool isRenamed,
      String? diff,
      @JsonKey(name: 'a_mode') String? oldMode,
      @JsonKey(name: 'b_mode') String? newMode,
      @JsonKey(name: 'collapsed') bool? isCollapsed,
      @JsonKey(name: 'too_large') bool? isTooLarge,
      @JsonKey(name: 'generated_file') bool? isGenerated,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CommitDiffFile() when $default != null:
        return $default(
          _that.oldPath,
          _that.newPath,
          _that.isNew,
          _that.isDeleted,
          _that.isRenamed,
          _that.diff,
          _that.oldMode,
          _that.newMode,
          _that.isCollapsed,
          _that.isTooLarge,
          _that.isGenerated,
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
      @JsonKey(name: 'old_path') String oldPath,
      @JsonKey(name: 'new_path') String newPath,
      @JsonKey(name: 'new_file') bool isNew,
      @JsonKey(name: 'deleted_file') bool isDeleted,
      @JsonKey(name: 'renamed_file') bool isRenamed,
      String? diff,
      @JsonKey(name: 'a_mode') String? oldMode,
      @JsonKey(name: 'b_mode') String? newMode,
      @JsonKey(name: 'collapsed') bool? isCollapsed,
      @JsonKey(name: 'too_large') bool? isTooLarge,
      @JsonKey(name: 'generated_file') bool? isGenerated,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CommitDiffFile():
        return $default(
          _that.oldPath,
          _that.newPath,
          _that.isNew,
          _that.isDeleted,
          _that.isRenamed,
          _that.diff,
          _that.oldMode,
          _that.newMode,
          _that.isCollapsed,
          _that.isTooLarge,
          _that.isGenerated,
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
      @JsonKey(name: 'old_path') String oldPath,
      @JsonKey(name: 'new_path') String newPath,
      @JsonKey(name: 'new_file') bool isNew,
      @JsonKey(name: 'deleted_file') bool isDeleted,
      @JsonKey(name: 'renamed_file') bool isRenamed,
      String? diff,
      @JsonKey(name: 'a_mode') String? oldMode,
      @JsonKey(name: 'b_mode') String? newMode,
      @JsonKey(name: 'collapsed') bool? isCollapsed,
      @JsonKey(name: 'too_large') bool? isTooLarge,
      @JsonKey(name: 'generated_file') bool? isGenerated,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CommitDiffFile() when $default != null:
        return $default(
          _that.oldPath,
          _that.newPath,
          _that.isNew,
          _that.isDeleted,
          _that.isRenamed,
          _that.diff,
          _that.oldMode,
          _that.newMode,
          _that.isCollapsed,
          _that.isTooLarge,
          _that.isGenerated,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _CommitDiffFile implements CommitDiffFile {
  const _CommitDiffFile({
    @JsonKey(name: 'old_path') required this.oldPath,
    @JsonKey(name: 'new_path') required this.newPath,
    @JsonKey(name: 'new_file') required this.isNew,
    @JsonKey(name: 'deleted_file') required this.isDeleted,
    @JsonKey(name: 'renamed_file') required this.isRenamed,
    this.diff,
    @JsonKey(name: 'a_mode') this.oldMode,
    @JsonKey(name: 'b_mode') this.newMode,
    @JsonKey(name: 'collapsed') this.isCollapsed,
    @JsonKey(name: 'too_large') this.isTooLarge,
    @JsonKey(name: 'generated_file') this.isGenerated,
  });
  factory _CommitDiffFile.fromJson(Map<String, dynamic> json) =>
      _$CommitDiffFileFromJson(json);

  @override
  @JsonKey(name: 'old_path')
  final String oldPath;
  @override
  @JsonKey(name: 'new_path')
  final String newPath;
  @override
  @JsonKey(name: 'new_file')
  final bool isNew;
  @override
  @JsonKey(name: 'deleted_file')
  final bool isDeleted;
  @override
  @JsonKey(name: 'renamed_file')
  final bool isRenamed;
  @override
  final String? diff;
  @override
  @JsonKey(name: 'a_mode')
  final String? oldMode;
  @override
  @JsonKey(name: 'b_mode')
  final String? newMode;
  @override
  @JsonKey(name: 'collapsed')
  final bool? isCollapsed;
  @override
  @JsonKey(name: 'too_large')
  final bool? isTooLarge;
  @override
  @JsonKey(name: 'generated_file')
  final bool? isGenerated;

  /// Create a copy of CommitDiffFile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CommitDiffFileCopyWith<_CommitDiffFile> get copyWith =>
      __$CommitDiffFileCopyWithImpl<_CommitDiffFile>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CommitDiffFileToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CommitDiffFile &&
            (identical(other.oldPath, oldPath) || other.oldPath == oldPath) &&
            (identical(other.newPath, newPath) || other.newPath == newPath) &&
            (identical(other.isNew, isNew) || other.isNew == isNew) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            (identical(other.isRenamed, isRenamed) ||
                other.isRenamed == isRenamed) &&
            (identical(other.diff, diff) || other.diff == diff) &&
            (identical(other.oldMode, oldMode) || other.oldMode == oldMode) &&
            (identical(other.newMode, newMode) || other.newMode == newMode) &&
            (identical(other.isCollapsed, isCollapsed) ||
                other.isCollapsed == isCollapsed) &&
            (identical(other.isTooLarge, isTooLarge) ||
                other.isTooLarge == isTooLarge) &&
            (identical(other.isGenerated, isGenerated) ||
                other.isGenerated == isGenerated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    oldPath,
    newPath,
    isNew,
    isDeleted,
    isRenamed,
    diff,
    oldMode,
    newMode,
    isCollapsed,
    isTooLarge,
    isGenerated,
  );

  @override
  String toString() {
    return 'CommitDiffFile(oldPath: $oldPath, newPath: $newPath, isNew: $isNew, isDeleted: $isDeleted, isRenamed: $isRenamed, diff: $diff, oldMode: $oldMode, newMode: $newMode, isCollapsed: $isCollapsed, isTooLarge: $isTooLarge, isGenerated: $isGenerated)';
  }
}

/// @nodoc
abstract mixin class _$CommitDiffFileCopyWith<$Res>
    implements $CommitDiffFileCopyWith<$Res> {
  factory _$CommitDiffFileCopyWith(
    _CommitDiffFile value,
    $Res Function(_CommitDiffFile) _then,
  ) = __$CommitDiffFileCopyWithImpl;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'old_path') String oldPath,
    @JsonKey(name: 'new_path') String newPath,
    @JsonKey(name: 'new_file') bool isNew,
    @JsonKey(name: 'deleted_file') bool isDeleted,
    @JsonKey(name: 'renamed_file') bool isRenamed,
    String? diff,
    @JsonKey(name: 'a_mode') String? oldMode,
    @JsonKey(name: 'b_mode') String? newMode,
    @JsonKey(name: 'collapsed') bool? isCollapsed,
    @JsonKey(name: 'too_large') bool? isTooLarge,
    @JsonKey(name: 'generated_file') bool? isGenerated,
  });
}

/// @nodoc
class __$CommitDiffFileCopyWithImpl<$Res>
    implements _$CommitDiffFileCopyWith<$Res> {
  __$CommitDiffFileCopyWithImpl(this._self, this._then);

  final _CommitDiffFile _self;
  final $Res Function(_CommitDiffFile) _then;

  /// Create a copy of CommitDiffFile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? oldPath = null,
    Object? newPath = null,
    Object? isNew = null,
    Object? isDeleted = null,
    Object? isRenamed = null,
    Object? diff = freezed,
    Object? oldMode = freezed,
    Object? newMode = freezed,
    Object? isCollapsed = freezed,
    Object? isTooLarge = freezed,
    Object? isGenerated = freezed,
  }) {
    return _then(
      _CommitDiffFile(
        oldPath: null == oldPath
            ? _self.oldPath
            : oldPath // ignore: cast_nullable_to_non_nullable
                  as String,
        newPath: null == newPath
            ? _self.newPath
            : newPath // ignore: cast_nullable_to_non_nullable
                  as String,
        isNew: null == isNew
            ? _self.isNew
            : isNew // ignore: cast_nullable_to_non_nullable
                  as bool,
        isDeleted: null == isDeleted
            ? _self.isDeleted
            : isDeleted // ignore: cast_nullable_to_non_nullable
                  as bool,
        isRenamed: null == isRenamed
            ? _self.isRenamed
            : isRenamed // ignore: cast_nullable_to_non_nullable
                  as bool,
        diff: freezed == diff
            ? _self.diff
            : diff // ignore: cast_nullable_to_non_nullable
                  as String?,
        oldMode: freezed == oldMode
            ? _self.oldMode
            : oldMode // ignore: cast_nullable_to_non_nullable
                  as String?,
        newMode: freezed == newMode
            ? _self.newMode
            : newMode // ignore: cast_nullable_to_non_nullable
                  as String?,
        isCollapsed: freezed == isCollapsed
            ? _self.isCollapsed
            : isCollapsed // ignore: cast_nullable_to_non_nullable
                  as bool?,
        isTooLarge: freezed == isTooLarge
            ? _self.isTooLarge
            : isTooLarge // ignore: cast_nullable_to_non_nullable
                  as bool?,
        isGenerated: freezed == isGenerated
            ? _self.isGenerated
            : isGenerated // ignore: cast_nullable_to_non_nullable
                  as bool?,
      ),
    );
  }
}
